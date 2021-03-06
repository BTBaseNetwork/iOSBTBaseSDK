//
//  BTSessionAPI.swift
//  iOSSDK
//
//  Created by Alex Chow on 2018/6/3.
//  Copyright © 2018年 btbase. All rights reserved.
//

import Foundation

class CheckDeviceAccountActivedResult: Codable {
    public var accountId: String!
    public var userName: String!
    public var nick: String!
}

class CheckDeviceAccountActivedRequest: BTAPIRequest<CheckDeviceAccountActivedResult> {
    override init() {
        super.init()
        api = "api/v1/Sessions/DeviceAccount"
    }

    var reactive: Bool = false {
        didSet {
            addParameter(name: "active", value: "\(reactive)")
        }
    }
}

class LoginAccountResult: Codable {
    public var accountId: String!
    public var session: String!
    public var token: String!
    public var tokenExpires: Double!
    public var sessionToken: String!
    public var sessionTokenExpires: Double!
    public var kickedDevices: [String]!
}

class LoginAccountRequest: BTAPIRequest<LoginAccountResult> {
    override init() {
        super.init()
        method = .post
        api = "api/v1/Sessions"
    }

    var userstring: String! {
        get { return parameters["userstring"] }
        set { parameters["userstring"] = newValue }
    }

    var password: String! {
        get { return parameters["password"] }
        set { parameters["password"] = newValue }
    }

    var audience: String! {
        get { return parameters["audience"] }
        set { parameters["audience"] = newValue }
    }
}

class RefreshTokenResult: Codable {
    public var accountId: String!
    public var token: String!
    public var expires: Double!
}

class RefreshTokenRequest: BTAPIRequest<RefreshTokenResult> {
    override init() {
        super.init()
        method = .post
        api = "api/v1/Sessions/RefreshingToken"
    }

    var audience: String! {
        get { return parameters["audience"] }
        set { parameters["audience"] = newValue }
    }
}

class LogoutDeviceRequest: BTAPIRequest<Int> {
    override init() {
        super.init()
        method = .delete
        api = "api/v1/Sessions"
    }
}
