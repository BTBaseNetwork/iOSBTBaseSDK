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

    static let createBTAccountSql = "create table BTAccount"

    var dbContext: BTServiceDBContext!

    var localAccount: BTAccount! {
        didSet {
            NotificationCenter.default.post(name: BTAccountService.onLocalAccountUpdated, object: self)
        }
    }

    var host = "http://localhost:6000/"

    func configure(serverHost: String) {
        host = serverHost
        // self.initDB()
    }

    func initDB() {
        if !dbContext.database.tableExists("BTAccount") {
            dbContext.database.executeStatements(BTAccountService.createBTAccountSql)
        }
    }

    func loadLocalAccount(accountId: String) {
        if let db = dbContext?.database, let resultSet = try? db.executeQuery("select * from BTAccount where AccountId = ?", values: [accountId]) {
            localAccount = BTAccount.parse(resultSet: resultSet)
        } else {
            localAccount = BTAccount()
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
        req.response = { _, _ in
        }
        let clientProfile = BTAPIClientProfile(host: host)
        clientProfile.useDeviceInfos().useAccountId().useAuthorizationAPIToken().useLang()
        req.request(profile: clientProfile)
    }

    func checkUserNameExists(username: String, respAction: CheckUsernameExistsRequest.ResponseAction?) {
        let req = CheckUsernameExistsRequest()
        req.username = username
        req.response = respAction
        let clientProfile = BTAPIClientProfile(host: host)
        req.request(profile: clientProfile)
    }

    func updatePassword(currentPassword: String, newPassword: String, respAction: UpdatePasswordRequest.ResponseAction?) {
        let req = UpdatePasswordRequest()
        req.newPassword = BTServiceConst.generateClientSaltPassword(password: newPassword)
        req.password = BTServiceConst.generateClientSaltPassword(password: currentPassword)
        req.response = respAction
        let clientProfile = BTAPIClientProfile(host: host)
        clientProfile.useAccountId().useAuthorizationAPIToken()
        req.request(profile: clientProfile)
    }

    func updateNick(newNick: String, respAction: UpdateNickRequest.ResponseAction?) {
        let req = UpdateNickRequest()
        req.newNick = newNick
        req.response = respAction
        let clientProfile = BTAPIClientProfile(host: host)
        clientProfile.useAccountId().useAuthorizationAPIToken()
        req.request(profile: clientProfile)
    }

    func sendUpdateEmailSecurityCode(email: String, respAction: SendCodeForUpdateEmailRequest.ResponseAction?) {
        let req = SendCodeForUpdateEmailRequest()
        req.email = email
        req.response = respAction
        let clientProfile = BTAPIClientProfile(host: host)
        clientProfile.useAccountId().useAuthorizationAPIToken()
        req.request(profile: clientProfile)
    }

    func updateEmailWithSecurityCode(newEmail: String, securityCode: String, respAction: UpdateEmailRequest.ResponseAction?) {
        let req = UpdateEmailRequest()
        req.newEmail = newEmail
        req.securityCode = securityCode
        req.response = respAction
        let clientProfile = BTAPIClientProfile(host: host)
        clientProfile.useAccountId().useAuthorizationAPIToken()
        req.request(profile: clientProfile)
    }

    func sendResetPasswordSecurityCode(accountId: String, email: String, respAction: SendCodeForResetPasswordRequest.ResponseAction?) {
        let req = SendCodeForResetPasswordRequest()
        req.accountId = accountId
        req.email = email
        req.response = respAction
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
        let clientProfile = BTAPIClientProfile(host: host)
        clientProfile.useAccountId().useAuthorizationAPIToken()
        req.request(profile: clientProfile)
    }
}

extension BTServiceContainer {
    public static func useBTAccountService(serverHost: String) {
        let service = BTAccountService()
        service.configure(serverHost: serverHost)
        addService(name: "BTAccountService", service: service)
    }

    public static func getBTAccountService() -> BTAccountService? {
        return getService(name: "BTAccountService") as? BTAccountService
    }
}
