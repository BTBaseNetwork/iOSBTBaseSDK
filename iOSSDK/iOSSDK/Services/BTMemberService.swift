//
//  BTMemberService.swift
//  iOSSDK
//
//  Created by Alex Chow on 2018/6/3.
//  Copyright © 2018年 btbase. All rights reserved.
//
import Foundation
import StoreKit

class BTMemberProfile {
    public var accountId = BTServiceConst.ACCOUNT_ID_UNLOGIN
    public var members = [BTMember]()
    public var preferredMember: BTMember? {
        return self.members.first
    }
}

let kBTMemberPurchaseEvent = "kBTMemberPurchaseEvent"
let BTMemberPurchaseEventStartValidate = 0
let BTMemberPurchaseEventPurchaseFailed = 1
let BTMemberPurchaseEventValidateSuccess = 2
let BTMemberPurchaseEventValidateFailed = 3

class BTMemberService {
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
    private var memberConfigUrl: String { return self.config.getString(key: "BTMemberConfigUrl")! }
    static var cachedMemberConfigJsonPathUrl: URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent("BTMemberMemberConfig.json")
        return fileURL
    }

    static let cachedMemberConfigDownloadDestination: DownloadRequest.DownloadFileDestination = { _, _ in
        (cachedMemberConfigJsonPathUrl, [.removePreviousFile, .createIntermediateDirectories])
    }
    
    private var paymentTransactionObserver: BTMemberPaymentTransactionObserver!
    fileprivate(set) var productIdentifiers: Set<String>!
    fileprivate(set) var products: Set<MemberProduct>! {
        didSet {
            NotificationCenter.default.postWithMainQueue(name: BTMemberService.onMemberProductsUpdated, object: self)
        }
    }

    fileprivate(set) var messages = [String]() {
        didSet {
            NotificationCenter.default.postWithMainQueue(name: BTMemberService.onMemberMessagesUpdated, object: self)
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

    func configure(config: BTBaseConfig) {
        self.config = config
        self.host = config.getString(key: "BTMemberServiceHost")!
        self.loadCachedMemberConfig()
        self.fetchMemberConfig()
        self.setUnloginProfile()
    }
}

extension BTMemberService {
    fileprivate func setUnloginProfile() {
        let profile = BTMemberProfile()
        profile.accountId = BTServiceConst.ACCOUNT_ID_UNLOGIN
        if let gmember = getGuestMemberProfile() {
            profile.members = [gmember]
        }
        self.localProfile = profile
    }

    func loadLocalProfile(accountId: String) {
        let profile = BTMemberProfile()
        profile.accountId = accountId
        let dbContext = BTBaseSDK.getDbContext()
        if let table = dbContext.tableMember {
            profile.members = table.query(sql: SQLiteHelper.selectSql(tableName: table.tableName, query: "accountId=?"), parameters: [accountId])
        }
        dbContext.close()
        self.localProfile = profile
    }

    func fetchMemberProfile() {
        let req = GetBTMemberProfileRequest()
        req.response = { _, res in
            if res.isHttpOK {
                let dbContext = BTBaseSDK.getDbContext()
                res.content?.members?.forEach({ m in
                    dbContext.tableMember.update(model: m, upsert: true)
                })
                dbContext.close()
                if let accountId = self.localProfile?.accountId, accountId == res.content.accountId {
                    let profile = BTMemberProfile()
                    profile.accountId = accountId
                    profile.members = res.content?.members ?? []
                    self.localProfile = profile
                }
            }
        }
        let clientProfile = BTAPIClientProfile(host: host)
        clientProfile.useAccountId().useAuthorizationAPIToken()
        req.request(profile: clientProfile)
    }

    func setLogout() {
        self.setUnloginProfile()
    }
}

let kBTRefreshMemberProductsStateKey = "kBTRefreshMemberProductsState"
let BTRefreshMemberProductsStateStart = 0
let BTRefreshMemberProductsStateFetched = 1
let BTRefreshMemberProductsStateFailed = 2

fileprivate class IAPInfo: Codable {
    var id: String!
    var enabled = false
}

fileprivate class MemberConfig: Codable {
    var locMessages: [String: [String]]!
    var products: [IAPInfo]!
}

extension BTMemberService {
    public static let onMemberMessagesUpdated = Notification.Name("BTMemberService_onMemberMessagesUpdated")
    public static let onMemberProductsUpdated = Notification.Name("BTMemberService_onMemberProductsUpdated")
    public static let onRefreshProductsEvent = Notification.Name("BTMemberService_onRefreshProductsEvent")

    func paymentQueue(_: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased, .restored: self.verifyTransactionAndRechargeMember(transaction)
            case .failed: NotificationCenter.default.post(name: BTMemberService.onPurchaseEvent, object: self, userInfo: [kBTMemberPurchaseEvent: BTMemberPurchaseEventPurchaseFailed])
            case .deferred, .purchasing: break
            }
        }
    }

    class BTMemberValidator: ReceiptValidator {
        var service: BTMemberService
        var transactionId: String!
        var productId: String!
        var transactionDate: Date!
        var quantity: Int = 0

        init(service: BTMemberService, iapOrder order: BTIAPOrder) {
            self.service = service
            self.transactionId = order.transactionId
            self.productId = order.productId
            self.transactionDate = order.date
            self.quantity = order.quantity
        }

        init(service: BTMemberService, transaction t: SKPaymentTransaction) {
            self.service = service
            self.transactionId = t.transactionIdentifier
            self.productId = t.payment.productIdentifier
            self.transactionDate = t.transactionDate
            self.quantity = t.payment.quantity
        }

        func validate(receiptData receipt: Data, completion: @escaping (VerifyReceiptResult) -> Void) {
            let receiptStr = receipt.base64EncodedString()

            let parameters = [transactionId!]
            let dbContext = BTBaseSDK.getDbContext()
            let tbName = dbContext.tableIAPOrder.tableName
            let field = "transactionId"
            var order: BTIAPOrder!
            if let first = dbContext.tableIAPOrder.query(sql: "SELECT * FROM \(tbName) WHERE \(field)=?", parameters: parameters).first {
                order = first
            } else {
                order = BTIAPOrder()
                order.receipt = receiptStr
                order.accountId = self.service.localProfile.accountId
                order.productId = productId // self.transaction.payment.productIdentifier
                order.store = BTServiceConst.CHANNEL_APP_STORE
                order.transactionId = self.transactionId // self.transaction.transactionIdentifier!
                order.date = self.transactionDate ?? Date()
                order.quantity = quantity
                order.state = BTIAPOrder.STATE_PAY_SUC
                for p in self.service.products {
                    if p.productId == order.productId {
                        order.locPrice = p.product.localizedPrice
                        order.locTitle = p.product.localizedTitle
                        break
                    }
                }

                dbContext.tableIAPOrder.add(model: order)
            }
            dbContext.close()

            // Guest Mode Purchase
            if order.accountId == BTServiceConst.ACCOUNT_ID_UNLOGIN {
                let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: nil)
                appleValidator.validate(receiptData: receipt) { r in
                    let dbContext = BTBaseSDK.getDbContext()
                    switch r {
                    case .error(error: let err):
                        order.state = BTIAPOrder.STATE_VERIFY_FAILED
                        order.verifyCode = 400
                        order.verifyMsg = err.localizedDescription
                    case .success(receipt: _):
                        var gmember: BTMember! = self.service.getGuestMemberProfile()
                        if nil == gmember {
                            gmember = BTMember()
                            gmember.accountId = order.accountId
                        }

                        let memberIapIdPattern = "^[0-9a-zA-Z-_.]+\\.iap.member\\.[0-9]\\.[0-9]+$"
                        if String.regexTestStringWithPattern(value: order.productId, pattern: memberIapIdPattern) {
                            let productInfos = order.productId.split(".")

                            let memberTypeStr = productInfos[productInfos.count - 2]
                            let timeStr = productInfos.last!
                            let time = Double(timeStr)!
                            let memberType = Int(memberTypeStr)!

                            if gmember.expiredDateTs > Date().timeIntervalSince1970 {
                                gmember.expiredDateTs += time
                            } else {
                                gmember.expiredDateTs = Date().timeIntervalSince1970 + time
                            }

                            gmember.memberType = memberType
                            dbContext.tableMember.update(model: gmember, upsert: true)
                            order.state = BTIAPOrder.STATE_VERIFY_SUC
                            order.verifyCode = 200
                        } else {
                            order.state = BTIAPOrder.STATE_VERIFY_FAILED
                            order.verifyCode = 400
                            order.verifyMsg = "Unmatched Product Id"
                        }
                        dbContext.tableIAPOrder.update(model: order, upsert: false)
                    }
                    dbContext.close()
                    completion(r)
                }

                return
            }

            // Logined Member Purchase
            var rinfo = ReceiptInfo()
            rinfo["product_id"] = NSString(string: order.productId)
            rinfo["quantity"] = NSString(string: "\(order.quantity)")
            rinfo["transaction_id"] = NSString(string: "\(order.transactionId)")

            if order.state == BTIAPOrder.STATE_PAY_SUC || order.state == BTIAPOrder.STATE_VERIFY_SERVER_NETWORK_ERROR {
                self.RechargeMember(productId: self.productId, channel: BTServiceConst.CHANNEL_APP_STORE, receipt: receiptStr, sandBox: false) { _, res in
                    let dbContext = BTBaseSDK.getDbContext()
                    if res.isHttpOK {
                        order.state = BTIAPOrder.STATE_VERIFY_SUC
                        order.verifyCode = 200
                        order.verifyMsg = res.msg
                        dbContext.tableIAPOrder.update(model: order, upsert: false)
                        completion(.success(receipt: rinfo))
                    } else if let code = res.error?.code {
                        order.state = BTIAPOrder.STATE_VERIFY_FAILED
                        order.verifyCode = code
                        order.verifyMsg = res.error?.msg
                        dbContext.tableIAPOrder.update(model: order, upsert: false)
                        completion(.error(error: ReceiptError.receiptInvalid(receipt: rinfo, status: ReceiptStatus.receiptCouldNotBeAuthenticated)))
                    } else {
                        order.state = BTIAPOrder.STATE_VERIFY_SERVER_NETWORK_ERROR
                        dbContext.tableIAPOrder.update(model: order, upsert: false)
                        let err = NSError(domain: "Network Error", code: 500, userInfo: nil)
                        completion(.error(error: ReceiptError.networkError(error: err)))
                    }
                    dbContext.close()
                    
                }
            } else if order.state == BTIAPOrder.STATE_VERIFY_SUC {
                completion(.success(receipt: rinfo))
            } else {
                completion(.error(error: ReceiptError.receiptInvalid(receipt: rinfo, status: ReceiptStatus.receiptCouldNotBeAuthenticated)))
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

    private func verifyTransactionAndRechargeMember(_ transaction: SKPaymentTransaction) {
        let validator = BTMemberValidator(service: self, transaction: transaction)
        verifyTransactionAndRechargeMember(validator: validator)
    }

    func verifyTransactionAndRechargeMember(order: BTIAPOrder) {
        let validator = BTMemberValidator(service: self, iapOrder: order)
        verifyTransactionAndRechargeMember(validator: validator)
    }

    private func verifyTransactionAndRechargeMember(validator: BTMemberValidator) {
        NotificationCenter.default.post(name: BTMemberService.onPurchaseEvent, object: self, userInfo: [kBTMemberPurchaseEvent: BTMemberPurchaseEventStartValidate])
        SwiftyStoreKit.verifyReceipt(using: validator) { r in
            switch r {
            case .error(error: _):
                NotificationCenter.default.post(name: BTMemberService.onPurchaseEvent, object: self, userInfo: [kBTMemberPurchaseEvent: BTMemberPurchaseEventValidateFailed])
            case .success(receipt: _):
                if self.localProfile.accountId == BTServiceConst.ACCOUNT_ID_UNLOGIN {
                    self.setUnloginProfile()
                } else {
                    self.fetchMemberProfile()
                }

                NotificationCenter.default.post(name: BTMemberService.onPurchaseEvent, object: self, userInfo: [kBTMemberPurchaseEvent: BTMemberPurchaseEventValidateSuccess])
            }
        }
    }

    @discardableResult
    func loadCachedMemberConfig() -> Bool {
        if let json = try? String(contentsOfFile: BTMemberService.cachedMemberConfigJsonPathUrl.path), let data = json.data(using: String.Encoding.utf8) {
            if let configModel = try? JSONDecoder().decode(MemberConfig.self, from: data) {
                self.retrieveProductsInfo(configModel.products)
                if let msgdict = configModel.locMessages {
                    if let msgs = msgdict[Locale.preferredLangCodeUnderlined], msgs.count > 0 {
                        self.messages = msgs
                    } else if let msgs = msgdict["default"], msgs.count > 0 {
                        self.messages = msgs
                    }
                }
                return true
            }
        }
        return false
    }

    func fetchMemberConfig() {
        self.postRefreshState(state: BTRefreshMemberProductsStateStart)
        download(self.memberConfigUrl, to: BTMemberService.cachedMemberConfigDownloadDestination).response { resp in
            if resp.error == nil, let _ = resp.destinationURL?.path {
                if self.loadCachedMemberConfig() {
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

extension BTMemberService {
    fileprivate func getGuestMemberProfile() -> BTMember? {
        let dbContext = BTBaseSDK.getDbContext()
        let sql = SQLiteHelper.selectSql(tableName: dbContext.tableMember.tableName, query: "accountId=?")
        let result = dbContext.tableMember.query(sql: sql, parameters: [BTServiceConst.ACCOUNT_ID_UNLOGIN]).first
        dbContext.close()
        return result
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
    public static func useBTMemberService(_ config: BTBaseConfig) {
        let service = BTMemberService()
        addService(name: "BTMemberService", service: service)
        service.configure(config: config)
    }

    public static func getBTMemberService() -> BTMemberService? {
        return getService(name: "BTMemberService") as? BTMemberService
    }
}
