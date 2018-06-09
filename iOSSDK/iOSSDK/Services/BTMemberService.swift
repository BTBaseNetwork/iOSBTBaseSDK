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

public class BTMemberService {
    public static let onLocalMemberProfileUpdated = Notification.Name("BTMemberService_onLocalMemberProfileUpdated")

    private var config: BTBaseConfig!
    private var host = "http://localhost:6000"
    private var iapListUrl: String { return self.config.getString(key: "BTMemberIAPListUrl")! }
    private var dbContext: BTServiceDBContext!
    private var paymentTransactionObserver: BTMemberPaymentTransactionObserver!
    fileprivate(set) var productIdentifiers: Set<String>!
    fileprivate(set) var products: Set<SKProduct>! {
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
        self.loadIAPList()
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

let kBTRefreshMemberProductsState = "kBTRefreshMemberProductsState"

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

        let v = AppleReceiptValidator(service: .production, sharedSecret: nil)

        init(service: BTMemberService, transaction: SKPaymentTransaction) {
            self.service = service
            self.transaction = transaction
        }

        func validate(receiptData receipt: Data, completion: @escaping (VerifyReceiptResult) -> Void) {
            let receiptDataStr = receipt.base64EncodedString()

            self.RechargeMember(productId: transaction.payment.productIdentifier, channel: BTServiceConst.CHANNEL_APP_STORE, unityReceiptData: receiptDataStr, sandBox: false) { _, res in
                if res.isHttpOK {
                    completion(.success(receipt: ReceiptInfo()))
                } else {
                    completion(.error(error: ReceiptError.jsonDecodeError(string: res.error.msg)))
                }
            }
        }

        func RechargeMember(productId: String, channel: String, unityReceiptData: String, sandBox: Bool, respAction: RechargeMemberRequest.ResponseAction?) {
            let req = RechargeMemberRequest()
            req.productId = productId
            req.receiptData = unityReceiptData
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

    func loadIAPList() {
        Alamofire.request(self.iapListUrl).responseJSON { (resp) in
            if resp.error == nil, let data = resp.data{
                if let result = try? JSONDecoder().decode(IAPResult.self, from: data), let products = result.products {
                    let productIdentifiers = products.filter { $0.enabled }.map { $0.id! }
                    let idSet = Set<String>(productIdentifiers)
                    self.loadIAPProducts(idSet)
                    return
                }
            }
            NotificationCenter.default.postWithMainQueue(name: BTMemberService.onRefreshProductsEvent, object: self, userInfo: [kBTRefreshMemberProductsState: false])
        }
    }

    func purchaseMemberProduct(p: SKProduct,completion:@escaping (Bool)->Void) {
        SwiftyStoreKit.purchaseProduct(p.productIdentifier) { r in
            switch r{
            case .success(let purchase):
                completion(true)
            case .error(let error):
                completion(false)
            }
        }
    }

    private func loadIAPProducts(_ productIdentifiers: Set<String>) {
        self.productIdentifiers = productIdentifiers
        SwiftyStoreKit.retrieveProductsInfo(productIdentifiers) { results in
            if results.error == nil {
                self.products = results.retrievedProducts
                NotificationCenter.default.postWithMainQueue(name: BTMemberService.onRefreshProductsEvent, object: self, userInfo: [kBTRefreshMemberProductsState: true])
            } else {
                NotificationCenter.default.postWithMainQueue(name: BTMemberService.onRefreshProductsEvent, object: self, userInfo: [kBTRefreshMemberProductsState: false])
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
