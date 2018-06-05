//
//  BTAccountService.swift
//  iOSSDK
//
//  Created by Alex Chow on 2018/6/3.
//  Copyright © 2018年 btbase. All rights reserved.
//

import FMDB
import Foundation

public class BTAccountService {
    public static let onLocalAccountUpdated = Notification.Name("BTAccountService_onLocalAccountUpdated")

    var host = "http://localhost:6000/"
    var dbContext: BTServiceDBContext!

    var localAccount: BTAccount! {
        didSet {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: BTAccountService.onLocalAccountUpdated, object: self)
            }
        }
    }

    func configure(serverHost: String, db: BTServiceDBContext) {
        self.initDB(db: db)
        self.host = serverHost
    }

    private func initDB(db: BTServiceDBContext) {
        self.dbContext = db
        self.dbContext.createTable(model: BTAccount())
    }

    func loadLocalAccount(accountId: String) {
        if let account = dbContext.select(model: BTAccount(), query: "AccountId = ?", parameters: [accountId]).first {
            self.localAccount = account
        } else {
            self.localAccount = BTAccount()
        }
    }

    func regist(username: String, password: String, email: String, respAction: RegistAccountRequest.ResponseAction?) {
        let req = RegistAccountRequest()
        req.email = email
        req.password = BTServiceConst.generateClientSaltPassword(password: password)
        req.username = username
        req.response = respAction
        let clientProfile = BTAPIClientProfile(host: host)
        clientProfile.useDeviceInfos().useLang()
        req.request(profile: clientProfile)
    }

    func fetchProfile() {
        let req = GetAccountProfileRequest()
        req.response = { _, result in
            if result.isHttpOK {
                let account = BTAccount()
                account.accountId = result.content.accountId
                account.accountTypes = result.content.accountTypes
                account.email = result.content.email
                account.mobile = result.content.mobile
                account.nick = result.content.nick
                account.signDateTs = result.content.signDateTs
                account.userName = result.content.userName
                self.localAccount = account
            }
        }
        let clientProfile = BTAPIClientProfile(host: host)
        clientProfile.useDeviceInfos().useAccountId().useAuthorizationAPIToken().useLang()
        req.request(profile: clientProfile)
    }

    func checkUserNameExists(username: String, respAction: CheckUsernameExistsRequest.ResponseAction?) {
        let req = CheckUsernameExistsRequest()
        req.username = username
        req.response = respAction
        req.queue = DispatchQueue.main
        let clientProfile = BTAPIClientProfile(host: host)
        req.request(profile: clientProfile)
    }

    func updatePassword(currentPassword: String, newPassword: String, respAction: UpdatePasswordRequest.ResponseAction?) {
        let req = UpdatePasswordRequest()
        req.newPassword = BTServiceConst.generateClientSaltPassword(password: newPassword)
        req.password = BTServiceConst.generateClientSaltPassword(password: currentPassword)
        req.response = respAction
        req.queue = DispatchQueue.main
        let clientProfile = BTAPIClientProfile(host: host)
        clientProfile.useAccountId().useAuthorizationAPIToken()
        req.request(profile: clientProfile)
    }

    func updateNick(newNick: String, respAction: UpdateNickRequest.ResponseAction?) {
        let req = UpdateNickRequest()
        req.newNick = newNick
        req.response = respAction
        req.queue = DispatchQueue.main
        let clientProfile = BTAPIClientProfile(host: host)
        clientProfile.useAccountId().useAuthorizationAPIToken()
        req.request(profile: clientProfile)
    }

    func sendUpdateEmailSecurityCode(email: String, respAction: SendCodeForUpdateEmailRequest.ResponseAction?) {
        let req = SendCodeForUpdateEmailRequest()
        req.email = email
        req.response = respAction
        req.queue = DispatchQueue.main
        let clientProfile = BTAPIClientProfile(host: host)
        clientProfile.useAccountId().useAuthorizationAPIToken()
        req.request(profile: clientProfile)
    }

    func updateEmailWithSecurityCode(newEmail: String, securityCode: String, respAction: UpdateEmailRequest.ResponseAction?) {
        let req = UpdateEmailRequest()
        req.newEmail = newEmail
        req.securityCode = securityCode
        req.response = respAction
        req.queue = DispatchQueue.main
        let clientProfile = BTAPIClientProfile(host: host)
        clientProfile.useAccountId().useAuthorizationAPIToken()
        req.request(profile: clientProfile)
    }

    func sendResetPasswordSecurityCode(accountId: String, email: String, respAction: SendCodeForResetPasswordRequest.ResponseAction?) {
        let req = SendCodeForResetPasswordRequest()
        req.accountId = accountId
        req.email = email
        req.response = respAction
        req.queue = DispatchQueue.main
        let clientProfile = BTAPIClientProfile(host: host)
        clientProfile.useAccountId().useAuthorizationAPIToken()
        req.request(profile: clientProfile)
    }

    func resetPasswordWithSecurityCode(accountId: String, newPassword: String, securityCode: String, respAction: ResetPasswordRequest.ResponseAction?) {
        let req = ResetPasswordRequest()
        req.accountId = accountId
        req.newPassword = BTServiceConst.generateClientSaltPassword(password: newPassword)
        req.securityCode = securityCode
        req.response = respAction
        req.queue = DispatchQueue.main
        let clientProfile = BTAPIClientProfile(host: host)
        clientProfile.useAccountId().useAuthorizationAPIToken()
        req.request(profile: clientProfile)
    }

    func setLogout() {
        self.localAccount = BTAccount()
    }
}

extension BTServiceContainer {
    public static func useBTAccountService(serverHost: String, dbContext: BTServiceDBContext) {
        let service = BTAccountService()
        service.configure(serverHost: serverHost, db: dbContext)
        addService(name: "BTAccountService", service: service)
    }

    public static func getBTAccountService() -> BTAccountService? {
        return getService(name: "BTAccountService") as? BTAccountService
    }
}
