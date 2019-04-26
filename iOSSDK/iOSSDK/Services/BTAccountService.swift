//
//  BTAccountService.swift
//  iOSSDK
//
//  Created by Alex Chow on 2018/6/3.
//  Copyright © 2018年 btbase. All rights reserved.
//

import BTSDK_FMDB
import Foundation

let kBTRegistedAccountId = "kBTRegistedAccountId"
let kBTRegistedUsername = "kBTRegistedUsername"

class BTAccountService {
    public static let onLocalAccountUpdated = Notification.Name("BTAccountService_onLocalAccountUpdated")
    public static let onNewAccountRegisted = Notification.Name("BTAccountService_onNewAccountRegisted")

    private var host = "http://localhost:6000/"
    private var config: BTBaseConfig!

    var localAccount: BTAccount! {
        didSet {
            let userInfo:[AnyHashable : Any] = [NSKeyValueChangeKey.oldKey:oldValue,NSKeyValueChangeKey.newKey:localAccount]
            let notification = Notification(name: BTAccountService.onLocalAccountUpdated, object: self, userInfo: userInfo)
            NotificationCenter.default.postWithMainQueue(notification)
        }
    }

    func configure(config: BTBaseConfig) {
        guard let host = config.getString(key: "BTAccountServiceHost") else {
            fatalError("[BTAccountService] Config Not Exists:BTAccountServiceHost")
        }
        self.config = config
        self.host = host
    }

    func loadLocalAccount(accountId: String) {
        let dbContext = BTBaseSDK.getDbContext()
        let resultSet = dbContext.tableAccount.query(sql: SQLiteHelper.selectSql(tableName: "BTAccount", query: "AccountId = ?"), parameters: [accountId])
        dbContext.close()
        if let account = resultSet.first {
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
        req.response = { request, res in
            if res.isHttpOK {
                let uinfo: [String: Any] = [kBTRegistedUsername: res.content.userName, kBTRegistedAccountId: res.content.accountId]
                NotificationCenter.default.postWithMainQueue(name: BTAccountService.onNewAccountRegisted, object: self, userInfo: uinfo)
            }
            DispatchQueue.main.async {
                respAction?(request, res)
            }
        }
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
                let dbContext = BTBaseSDK.getDbContext()
                let _ = dbContext.tableAccount.update(model: account, upsert: true)
                dbContext.close()
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

    func updatePassword(currentPassword: String, newPassword: String, respAction: @escaping (_: BTAPIResult<EmptyContent>, _ newSaltedPassword: String) -> Void) {
        let req = UpdatePasswordRequest()
        req.newPassword = BTServiceConst.generateClientSaltPassword(password: newPassword)
        req.password = BTServiceConst.generateClientSaltPassword(password: currentPassword)
        req.response = { _, res in
            respAction(res, req.newPassword)
        }
        req.queue = DispatchQueue.main
        let clientProfile = BTAPIClientProfile(host: host)
        clientProfile.useAccountId().useAuthorizationAPIToken()
        req.request(profile: clientProfile)
    }

    func updateNick(newNick: String, respAction: UpdateNickRequest.ResponseAction?) {
        let req = UpdateNickRequest()
        req.newNick = newNick
        req.response = { request, res in
            if res.isHttpOK {
                self.localAccount.nick = newNick
                let dbContext = BTBaseSDK.getDbContext()
                let _ = dbContext.tableAccount.update(model: self.localAccount, upsert: true)
                dbContext.close()
            }
            DispatchQueue.main.async {
                respAction?(request, res)
            }
        }
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
        clientProfile.useAccountId().useAuthorizationAPIToken().useLang()
        req.request(profile: clientProfile)
    }

    func updateEmailWithSecurityCode(newEmail: String, securityCode: String, respAction: UpdateEmailRequest.ResponseAction?) {
        let req = UpdateEmailRequest()
        req.newEmail = newEmail
        req.securityCode = securityCode
        req.response = { request, res in
            if res.isHttpOK {
                self.localAccount.email = "\(newEmail.first!)***@\(newEmail.split("@")[1])"
                let dbContext = BTBaseSDK.getDbContext()
                let _ = dbContext.tableAccount.update(model: self.localAccount, upsert: true)
                dbContext.close()
            }
            DispatchQueue.main.async {
                respAction?(request, res)
            }
        }
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
        clientProfile.useLang()
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
        req.request(profile: clientProfile)
    }

    func setLogout() {
        self.localAccount = BTAccount()
    }
}

extension BTServiceContainer {
    public static func useBTAccountService(_ config: BTBaseConfig) {
        let service = BTAccountService()
        addService(name: "BTAccountService", service: service)
        service.configure(config: config)
    }

    public static func getBTAccountService() -> BTAccountService? {
        return getService(name: "BTAccountService") as? BTAccountService
    }
}
