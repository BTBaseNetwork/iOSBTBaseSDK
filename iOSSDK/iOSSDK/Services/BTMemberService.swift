//
//  BTMemberService.swift
//  iOSSDK
//
//  Created by Alex Chow on 2018/6/3.
//  Copyright © 2018年 btbase. All rights reserved.
//

import Foundation

public class BTMemberProfile
{
    public var accountId = BTServiceConst.ACCOUNT_ID_UNLOGIN
    public var members = [BTMember]()
}

public class BTMemberService {
    var host = "http://localhost:6000"
    var dbContext: BTServiceDBContext!
    
    private(set) var localProfile = BTMemberProfile()
    
    func configure(serverHost: String, db: BTServiceDBContext) {
        initDB(db: db)
        host = serverHost
    }

    private func initDB(db: BTServiceDBContext) {
        dbContext = db
        dbContext.tableMember.createTable()
    }

    func fetchMemberProfile() {
        let req = GetBTMemberProfileRequest()
        req.response = { _, _ in
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
        localProfile = BTMemberProfile()
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
