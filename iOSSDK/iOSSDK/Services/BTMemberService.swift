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
}

public class BTMemberService {
    public static let onLocalMemberProfileUpdated = Notification.Name("BTMemberService_onLocalMemberProfileUpdated")
    public static let onMemberProductsUpdated = Notification.Name("BTMemberService_onMemberProductsUpdated")
    private var config: BTBaseConfig!
    private var host = "http://localhost:6000"
    private var iapListUrl: String { return self.config.getString(key: "BTMemberIAPListUrl")! }
    private var dbContext: BTServiceDBContext!
    private var paymentTransactionObserver: BTMemberPaymentTransactionObserver!
    fileprivate(set) var productIdentifiers: Set<String>!
    fileprivate(set) var products: Set<SKProduct>! {
        didSet {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: BTMemberService.onMemberProductsUpdated, object: self)
            }
        }
    }

    init() {
        self.paymentTransactionObserver = BTMemberPaymentTransactionObserver(memberService: self)
    }

    private(set) var localProfile: BTMemberProfile! {
        didSet {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: BTMemberService.onLocalMemberProfileUpdated, object: self)
            }
        }
    }

    func configure(config: BTBaseConfig, db: BTServiceDBContext) {
        self.config = config
        self.host = config.getString(key: "BTMemberServiceHost")!
        self.initDB(db: db)
    }

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

    func RechargeMember(productId: String, channel: String, unityReceiptData: String, payload _: String, sandBox: Bool, respAction: RechargeMemberRequest.ResponseAction?) {
        let req = RechargeMemberRequest()
        req.productId = productId
        req.receiptData = unityReceiptData
        req.channel = channel
        req.sandBox = sandBox
        req.response = respAction
        req.queue = DispatchQueue.main
        let clientProfile = BTAPIClientProfile(host: host)
        clientProfile.useAccountId().useAuthorizationAPIToken()
        req.request(profile: clientProfile)
    }

    func setLogout() {
        self.localProfile = BTMemberProfile()
    }
}

extension BTMemberService {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
    }

    func loadIAPList() {
        Alamofire.download(self.iapListUrl).response(queue: DispatchQueue.utility) { _ in
        }
    }

    func purchaseMemberProduct(p: SKProduct) {
        
    }

    func loadIAPProducts(_ productIdentifiers: Set<String>) {
        self.productIdentifiers = productIdentifiers
        SwiftyStoreKit.retrieveProductsInfo(productIdentifiers) { results in
            if results.error == nil {
                self.products = results.retrievedProducts
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
