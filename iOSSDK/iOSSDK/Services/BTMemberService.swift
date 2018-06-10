//
//  BTMemberService.swift
//  iOSSDK
//
//  Created by Alex Chow on 2018/6/3.
//  Copyright © 2018年 btbase. All rights reserved.
//

import Alamofire
import Foundation
import StoreKit
import SwiftyStoreKit

public class BTMemberProfile {
    public var accountId = BTServiceConst.ACCOUNT_ID_UNLOGIN
    public var members = [BTMember]()
    public var preferredMember: BTMember? {
        return self.members.first
    }
}

let BTMemberPurchaseEvent = 0

public class BTMemberService {
    public class MemberProduct: Hashable {
        public var hashValue: Int {
            return self.product.hashValue
        }

        public static func == (lhs: BTMemberService.MemberProduct, rhs: BTMemberService.MemberProduct) -> Bool {
            return lhs.productId == rhs.productId
        }

        public var product: SKProduct
        public var productId: String {
            return self.product.productIdentifier
        }

        public var enabled: Bool = false

        init(product: SKProduct, enabled: Bool) {
            self.product = product
            self.enabled = enabled
        }
    }

    public static let onLocalMemberProfileUpdated = Notification.Name("BTMemberService_onLocalMemberProfileUpdated")

    public static let onPurchaseEvent = Notification.Name("BTMemberService_onPurchaseEvent")

    private var config: BTBaseConfig!
    private var host = "http://localhost:6000"
    private var iapListUrl: String { return self.config.getString(key: "BTMemberIAPListUrl")! }
    static var cachedIAPListJsonPathUrl: URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent("BTMemberIAPList.json")
        return fileURL
    }

    static let cachedIAPListDownloadDestination: DownloadRequest.DownloadFileDestination = { _, _ in
        (cachedIAPListJsonPathUrl, [.removePreviousFile, .createIntermediateDirectories])
    }
    private var dbContext: BTServiceDBContext!
    private var paymentTransactionObserver: BTMemberPaymentTransactionObserver!
    fileprivate(set) var productIdentifiers: Set<String>!
    fileprivate(set) var products: Set<MemberProduct>! {
        didSet {
            NotificationCenter.default.postWithMainQueue(name: BTMemberService.onMemberProductsUpdated, object: self)
        }
    }

    init() {
        self.paymentTransactionObserver = BTMemberPaymentTransactionObserver(memberService: self)
    }

    private(set) var localProfile: BTMemberProfile! {
        didSet {
            NotificationCenter.default.postWithMainQueue(name: BTMemberService.onLocalMemberProfileUpdated, object: self)
        }
    }

    func configure(config: BTBaseConfig, db: BTServiceDBContext) {
        self.config = config
        self.host = config.getString(key: "BTMemberServiceHost")!
        self.initDB(db: db)
        self.loadCachedIAPList()
        self.fetchIAPList()
    }
}

extension BTMemberService {
    func loadLocalProfile(accountId: String) {
        let profile = BTMemberProfile()
        profile.accountId = accountId
        if let table = dbContext.tableMember {
            profile.members = table.query(sql: SQLiteHelper.selectSql(tableName: table.tableName, query: "accountId=?"), parameters: [accountId])
        }
        self.localProfile = profile
    }

    private func initDB(db: BTServiceDBContext) {
        self.dbContext = db
        self.dbContext.tableMember.createTable()
    }

    func fetchMemberProfile() {
        let req = GetBTMemberProfileRequest()
        req.response = { _, res in
            if res.isHttpOK {
                res.content.members.forEach({ m in
                    self.dbContext.tableMember.update(model: m, upsert: true)
                })

                if let accountId = self.localProfile?.accountId, accountId == res.content.accountId {
                    let profile = BTMemberProfile()
                    profile.accountId = accountId
                    profile.members = res.content.members ?? []
                    self.localProfile = profile
                }
            }
        }
        let clientProfile = BTAPIClientProfile(host: host)
        clientProfile.useAccountId().useAuthorizationAPIToken()
        req.request(profile: clientProfile)
    }

    func setLogout() {
        self.localProfile = BTMemberProfile()
    }
}

let kBTRefreshMemberProductsStateKey = "kBTRefreshMemberProductsState"
let BTRefreshMemberProductsStateStart = 0
let BTRefreshMemberProductsStateFetched = 1
let BTRefreshMemberProductsStateFailed = 2

extension BTMemberService {
    public static let onMemberProductsUpdated = Notification.Name("BTMemberService_onMemberProductsUpdated")
    public static let onRefreshProductsEvent = Notification.Name("BTMemberService_onRefreshProductsEvent")

    fileprivate class IAPInfo: Codable {
        var id: String!
        var enabled = false
    }

    fileprivate class IAPResult: Codable {
        var products: [IAPInfo]!
    }

    func paymentQueue(_: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased, .restored: self.verifyTransactionAndRechargeMember(transaction)
            case .deferred, .failed, .purchasing: break
            }
        }
    }

    class BTMemberValidator: ReceiptValidator {
        var transaction: SKPaymentTransaction
        var service: BTMemberService

        init(service: BTMemberService, transaction: SKPaymentTransaction) {
            self.service = service
            self.transaction = transaction
        }

        func validate(receiptData receipt: Data, completion: @escaping (VerifyReceiptResult) -> Void) {
            let receiptStr = receipt.base64EncodedString()

            let order = BTIAPOrder()
            order.receipt = receiptStr
            order.productId = transaction.payment.productIdentifier
            order.store = BTServiceConst.CHANNEL_APP_STORE
            order.transactionId = transaction.transactionIdentifier!
            order.date = transaction.transactionDate
            order.quantity = transaction.payment.quantity
            order.state = BTIAPOrder.STATE_PAY_SUC

            self.RechargeMember(productId: transaction.payment.productIdentifier, channel: BTServiceConst.CHANNEL_APP_STORE, receipt: receiptStr, sandBox: false) { _, res in
                if res.isHttpOK {
                    completion(.success(receipt: ReceiptInfo()))
                } else {
                    completion(.error(error: ReceiptError.jsonDecodeError(string: res.error.msg)))
                }
            }
        }

        func RechargeMember(productId: String, channel: String, receipt: String, sandBox: Bool, respAction: RechargeMemberRequest.ResponseAction?) {
            let req = RechargeMemberRequest()
            req.productId = productId
            req.receiptData = receipt
            req.channel = channel
            req.sandBox = sandBox
            req.response = respAction
            let clientProfile = BTAPIClientProfile(host: service.host)
            clientProfile.useAccountId().useAuthorizationAPIToken()
            req.request(profile: clientProfile)
        }
    }

    func verifyTransactionAndRechargeMember(_ transaction: SKPaymentTransaction) {
        let validator = BTMemberValidator(service: self, transaction: transaction)
        SwiftyStoreKit.verifyReceipt(using: validator) { r in
            switch r {
            case .error(error: _): break
            case .success(receipt: _): self.fetchMemberProfile()
            }
        }
    }

    @discardableResult
    func loadCachedIAPList() -> Bool {
        if let json = try? String(contentsOfFile: BTMemberService.cachedIAPListJsonPathUrl.path), let data = json.data(using: String.Encoding.utf8) {
            if let configModel = try? JSONDecoder().decode(IAPResult.self, from: data) {
                self.retrieveProductsInfo(configModel.products)
                return true
            }
        }
        return false
    }

    func fetchIAPList() {
        self.postRefreshState(state: BTRefreshMemberProductsStateStart)
        Alamofire.download(self.iapListUrl, to: BTMemberService.cachedIAPListDownloadDestination).response { resp in
            if resp.error == nil, let _ = resp.destinationURL?.path {
                if self.loadCachedIAPList() {
                    return
                }
            }
            self.postRefreshState(state: BTRefreshMemberProductsStateFailed)
        }
    }

    private func postRefreshState(state: Int) {
        NotificationCenter.default.postWithMainQueue(name: BTMemberService.onRefreshProductsEvent, object: self, userInfo: [kBTRefreshMemberProductsStateKey: state])
    }

    func purchaseMemberProduct(p: SKProduct, completion: @escaping (Bool) -> Void) {
        SwiftyStoreKit.purchaseProduct(p.productIdentifier) { r in
            switch r {
            case .success:
                completion(true)
            case .error:
                completion(false)
            }
        }
    }

    private func retrieveProductsInfo(_ iapInfoArr: [IAPInfo]) {
        self.productIdentifiers = Set<String>(iapInfoArr.map { $0.id })

        SwiftyStoreKit.retrieveProductsInfo(self.productIdentifiers) { results in
            if results.error == nil {
                let arr = results.retrievedProducts.map { p -> BTMemberService.MemberProduct in
                    let iap = iapInfoArr.first(where: { (i) -> Bool in
                        i.id == p.productIdentifier
                    })
                    return MemberProduct(product: p, enabled: iap!.enabled)
                }
                self.postRefreshState(state: BTRefreshMemberProductsStateFetched)
                self.products = Set<MemberProduct>(arr)
            } else {
                self.postRefreshState(state: BTRefreshMemberProductsStateFailed)
            }
        }
    }
}

class BTMemberPaymentTransactionObserver: NSObject, SKPaymentTransactionObserver {
    var service: BTMemberService
    init(memberService: BTMemberService) {
        self.service = memberService
        super.init()
        SKPaymentQueue.default().add(self)
    }

    deinit {
        SKPaymentQueue.default().remove(self)
    }

    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        self.service.paymentQueue(queue, updatedTransactions: transactions)
    }
}

extension BTServiceContainer {
    public static func useBTMemberService(_ config: BTBaseConfig, dbContext: BTServiceDBContext) {
        let service = BTMemberService()
        service.configure(config: config, db: dbContext)
        addService(name: "BTMemberService", service: service)
    }

    public static func getBTMemberService() -> BTMemberService? {
        return getService(name: "BTMemberService") as? BTMemberService
    }
}
