//
//  BTMemberService.swift
//  iOSSDK
//
//  Created by Alex Chow on 2018/6/3.
//  Copyright © 2018年 btbase. All rights reserved.
//

import Foundation
public class BTMemberService {
    var host = "http://localhost:6000"
    var dbContext: BTServiceDBContext!
    func configure(serverHost: String) {
        host = serverHost
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
        let clientProfile = BTAPIClientProfile(host: host)
        clientProfile.useAccountId().useAuthorizationAPIToken()
        req.request(profile: clientProfile)
    }
}

extension BTServiceContainer {
    public static func useBTMemberService(serverHost: String) {
        let service = BTMemberService()
        service.configure(serverHost: serverHost)
        addService(name: "BTMemberService", service: service)
    }

    public static func getBTMemberService() -> BTMemberService? {
        return getService(name: "BTMemberService") as? BTMemberService
    }
}
