//
//  BTSessionAPI.swift
//  iOSSDK
//
//  Created by Alex Chow on 2018/6/3.
//  Copyright © 2018年 btbase. All rights reserved.
//

import Foundation

class GetBTMemberProfileResult: Codable {
    public var accountId: String!
    public var members: [BTMember]!
}

class GetBTMemberProfileRequest: BTAPIRequest<GetBTMemberProfileResult> {
    override init() {
        super.init()
        api = "api/v1/Members/Profile"
    }
}

class RechargeMemberRequest: BTAPIRequestEmptyContent {
    override init() {
        super.init()
        method = .post
        api = "api/v1/Members/ExpiredDate/Order"
    }

    var productId: String! {
        get { return parameters["productId"] }
        set { parameters["productId"] = newValue }
    }

    var receiptData: String! {
        get { return parameters["receiptData"] }
        set { parameters["receiptData"] = newValue }
    }

    var channel: String! {
        get { return parameters["channel"] }
        set { parameters["channel"] = newValue }
    }

    var sandBox: Bool! {
        didSet {
            parameters["sandBox"] = "\(sandBox!)"
        }
    }
}
