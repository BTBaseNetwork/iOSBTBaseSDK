//
//  BTMemberService.swift
//  iOSSDK
//
//  Created by Alex Chow on 2018/6/3.
//  Copyright © 2018年 btbase. All rights reserved.
//

import Foundation

public class BTMemberProfile {
    public var accountId = BTServiceConst.ACCOUNT_ID_UNLOGIN
    public var members = [BTMember]()
}

public class BTMemberService {
    public static let onLocalMemberProfileUpdated = Notification.Name("BTMemberService_onLocalMemberProfileUpdated")
    var host = "http://localhost:6000"
    var dbContext: BTServiceDBContext!

    private(set) var localProfile: BTMemberProfile! {
        didSet {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: BTMemberService.onLocalMemberProfileUpdated, object: self)
            }
        }
    }

    func configure(serverHost: String, db: BTServiceDBContext) {
        self.host = serverHost
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

extension BTServiceContainer {
    public static func useBTMemberService(serverHost: String, dbContext: BTServiceDBContext) {
        let service = BTMemberService()
        service.configure(serverHost: serverHost, db: dbContext)
        addService(name: "BTMemberService", service: service)
    }

    public static func getBTMemberService() -> BTMemberService? {
        return getService(name: "BTMemberService") as? BTMemberService
    }
}
