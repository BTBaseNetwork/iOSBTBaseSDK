//
//  BTAccountService.swift
//  iOSSDK
//
//  Created by Alex Chow on 2018/6/3.
//  Copyright © 2018年 btbase. All rights reserved.
//

import FMDB
import Foundation

let kBTRegistedAccountId = "kBTRegistedAccountId"
let kBTRegistedUsername = "kBTRegistedUsername"

public class BTAccountService {
    public static let onLocalAccountUpdated = Notification.Name("BTAccountService_onLocalAccountUpdated")
    public static let onNewAccountRegisted = Notification.Name("BTAccountService_onNewAccountRegisted")

    private var host = "http://localhost:6000/"
    private var dbContext: BTServiceDBContext!
    private var config: BTBaseConfig!

    var localAccount: BTAccount! {
        didSet {
            NotificationCenter.default.postWithMainQueue(name: BTAccountService.onLocalAccountUpdated, object: self)
        }
    }

    func configure(config: BTBaseConfig, db: BTServiceDBContext) {
        self.config = config
        self.host = config.getString(key: "BTAccountServiceHost")!
        self.initDB(db: db)
    }

    private func initDB(db: BTServiceDBContext) {
        self.dbContext = db
        self.dbContext.tableAccount.createTable()
    }

    func loadLocalAccount(accountId: String) {
        let resultSet = dbContext.tableAccount.query(sql: SQLiteHelper.selectSql(tableName: "BTAccount", query: "AccountId = ?"), parameters: [accountId])
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
        req.response = { _, res in
            if res.isHttpOK {
                let uinfo: [String: Any] = [kBTRegistedUsername: res.content.userName, kBTRegistedAccountId: res.content.accountId]
                NotificationCenter.default.postWithMainQueue(name: BTAccountService.onNewAccountRegisted, object: self, userInfo: uinfo)
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
                self.dbContext.tableAccount.update(model: account, upsert: true)
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
        req.response = { request, res in
            if res.isHttpOK {
                self.localAccount.nick = newNick
                self.dbContext.tableAccount.update(model: self.localAccount, upsert: true)
            }
            respAction?(request, res)
        }
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
                self.dbContext.tableAccount.update(model: self.localAccount, upsert: true)
            }
            respAction?(request, res)
        }
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
    public static func useBTAccountService(_ config: BTBaseConfig, dbContext: BTServiceDBContext) {
        let service = BTAccountService()
        service.configure(config: config, db: dbContext)
        addService(name: "BTAccountService", service: service)
    }

    public static func getBTAccountService() -> BTAccountService? {
        return getService(name: "BTAccountService") as? BTAccountService
    }
}
