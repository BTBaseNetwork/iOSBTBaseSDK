//
//  BTAccountAPI.swift
//  iOSSDK
//
//  Created by Alex Chow on 2018/6/3.
//  Copyright © 2018年 btbase. All rights reserved.
//

import Foundation

class RegistAccountResult: Codable {
    public var accountId: String!
    public var userName: String!
}

class RegistAccountRequest: BTAPIRequest<RegistAccountResult> {
    override init() {
        super.init()
        method = .post
        api = "api/v1/Accounts"
    }

    var username: String! {
        get { return parameters["username"] }
        set { parameters["username"] = newValue }
    }

    var password: String! {
        get { return parameters["password"] }
        set { parameters["password"] = newValue }
    }

    var email: String! {
        get { return parameters["email"] }
        set { parameters["email"] = newValue }
    }
}

class GetAccountProfileRequest: BTAPIRequest<BTAccount> {
    override init() {
        super.init()
        api = "api/v1/Accounts/Profile"
    }
}

class CheckUsernameExistsRequest: BTAPIRequestEmptyContent {
    var username: String! {
        didSet {
            api = "api/v1/Accounts/Username/" + username
        }
    }
}

class UpdatePasswordRequest: BTAPIRequestEmptyContent {
    override init() {
        super.init()
        method = .post
        api = "api/v1/Accounts/Password"
    }

    var password: String! {
        get { return parameters["password"] }
        set { parameters["password"] = newValue }
    }

    var newPassword: String! {
        get { return parameters["newPassword"] }
        set { parameters["newPassword"] = newValue }
    }
}

class UpdateNickRequest: BTAPIRequestEmptyContent {
    override init() {
        super.init()
        method = .post
        api = "api/v1/Accounts/Nick"
    }

    var newNick: String! {
        get { return parameters["newNick"] }
        set { parameters["newNick"] = newValue }
    }
}

class SendCodeForUpdateEmailRequest: BTAPIRequestEmptyContent {
    override init() {
        super.init()
        method = .post
        api = "api/v1/Accounts/SecurityCode/NewEmail/Email"
    }

    var email: String! {
        get { return parameters["email"] }
        set { parameters["email"] = newValue }
    }
}

class UpdateEmailRequest: BTAPIRequestEmptyContent {
    override init() {
        super.init()
        method = .post
        api = "api/v1/Accounts/NewEmail"
    }

    var newEmail: String! {
        get { return parameters["newEmail"] }
        set { parameters["newEmail"] = newValue }
    }

    var securityCode: String! {
        get { return parameters["securityCode"] }
        set { parameters["securityCode"] = newValue }
    }
}

class SendCodeForResetPasswordRequest: BTAPIRequestEmptyContent {
    override init() {
        super.init()
        method = .post
        api = "api/v1/Accounts/SecurityCode/NewPassword/Email"
    }

    var email: String! {
        get { return parameters["email"] }
        set { parameters["email"] = newValue }
    }

    var accountId: String! {
        get { return parameters["accountId"] }
        set { parameters["accountId"] = newValue }
    }
}

class ResetPasswordRequest: BTAPIRequestEmptyContent {
    override init() {
        super.init()
        method = .post
        api = "api/v1/Accounts/NewPassword"
    }

    var accountId: String! {
        get { return parameters["accountId"] }
        set { parameters["accountId"] = newValue }
    }

    var securityCode: String! {
        get { return parameters["securityCode"] }
        set { parameters["securityCode"] = newValue }
    }

    var newPassword: String! {
        get { return parameters["newPassword"] }
        set { parameters["newPassword"] = newValue }
    }
}
