//
//  BTSessionService.swift
//  iOSSDK
//
//  Created by Alex Chow on 2018/6/3.
//  Copyright © 2018年 btbase. All rights reserved.
//

import FMDB
import Foundation
class BTSessionService {
    public static let onSessionUpdated = NSNotification.Name("BTSessionService_onSessionUpdated")
    public static let onSessionUnauthorized = NSNotification.Name("BTSessionService_onSessionUnauthorized")
    fileprivate var config: BTBaseConfig!
    private var host: String = "http://localhost/"
    private(set) var localSession: BTAccountSession! {
        didSet {
            NotificationCenter.default.postWithMainQueue(name: BTSessionService.onSessionUpdated, object: self)
        }
    }

    var isSessionLogined: Bool { return self.localSession?.IsSessionLogined() ?? false }

    var dbContext: BTServiceDBContext!

    func configure(config: BTBaseConfig, db: BTServiceDBContext) {
        self.config = config
        self.host = config.getString(key: "BTSessionServiceHost")!
        self.dbContext = db
        self.loadCachedSession()

        NotificationCenter.default.addObserver(self, selector: #selector(self.onRequestUnauthorized(a:)), name: Notification.Name.BTAPIRequestUnauthorized, object: nil)
    }

    @objc private func onRequestUnauthorized(a _: Notification) {
        NotificationCenter.default.postWithMainQueue(name: BTSessionService.onSessionUnauthorized, object: self)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func loadCachedSession() {
        let resultSet = dbContext.tableAccountSession.query(sql: SQLiteHelper.selectSql(tableName: dbContext.tableAccountSession.tableName, query: "Status >= ?"), parameters: [BTAccountSession.STATUS_LOGIN])
        if let session = resultSet.first {
            self.localSession = session
            self.checkAndRefreshToken()
        } else {
            self.localSession = BTAccountSession()
        }
    }

    func checkAndRefreshToken() {
        if self.localSession.IsSessionLogined() {
            if self.localSession.sTokenExpires == nil || self.localSession.sTokenExpires!.timeIntervalSince1970 < Date().timeIntervalSince1970 {
                self.login(self.localSession.accountId, self.localSession.password!, passwordSalted: true, autoFillPassword: false) { _, res in
                    if !res.isHttpOK {
                        NotificationCenter.default.postWithMainQueue(name: BTSessionService.onSessionUnauthorized, object: self)
                    }
                }
            } else if self.localSession.tokenExpires == nil || self.localSession.tokenExpires!.timeIntervalSince1970 < Date().timeIntervalSince1970 {
                self.refreshToken()
            }
        }
    }

    func checkDeviceAccountActive(respAction: CheckDeviceAccountActivedRequest.ResponseAction?) {
        let req = CheckDeviceAccountActivedRequest()
        req.reactive = false
        req.response = respAction
        req.queue = DispatchQueue.main
        let clientProfile = BTAPIClientProfile(host: host)
        clientProfile.useDeviceInfos()
        req.request(profile: clientProfile)
    }

    func login(_ userstring: String, _ password: String, passwordSalted: Bool, autoFillPassword: Bool, respAction: LoginAccountRequest.ResponseAction?) {
        let saltPsw = passwordSalted ? password : BTServiceConst.generateClientSaltPassword(password: password)
        let req = LoginAccountRequest()
        req.userstring = userstring
        req.password = saltPsw
        req.audience = "BTBaseWebAPI"
        req.response = { request, result in

            if result.isHttpOK {
                let session = BTAccountSession()
                session.accountId = result.content.accountId
                session.password = saltPsw
                session.session = result.content.session
                session.sessionToken = result.content.sessionToken
                session.sTokenExpires = DateHelper.dateOfUnixTimeSpan(result.content.sessionTokenExpires)
                session.status = BTAccountSession.STATUS_LOGIN
                session.token = result.content.token
                session.tokenExpires = DateHelper.dateOfUnixTimeSpan(result.content.tokenExpires)
                session.fillPassword = autoFillPassword
                self.dbContext.tableAccountSession.update(model: session, upsert: true)
                self.localSession = session
                let sql = SQLiteHelper.updateSql(tableName: self.dbContext.tableAccountSession.tableName, fields: ["status"], query: "accountId != ?")
                self.dbContext.tableAccountSession.executeUpdateSql(sql: sql, parameters: [BTAccountSession.STATUS_LOGOUT, session.accountId])
            }

            DispatchQueue.main.async {
                respAction?(request, result)
            }
        }

        let clientProfile = BTAPIClientProfile(host: host)
        clientProfile.useDeviceInfos().useLang().useClientId()
        req.request(profile: clientProfile)
    }

    func refreshToken() {
        let req = RefreshTokenRequest()
        req.audience = "BTBaseWebAPI"
        req.response = { _, result in
            if result.isHttpOK {
                self.localSession.token = result.content.token
                self.localSession.tokenExpires = DateHelper.dateOfUnixTimeSpan(result.content.expires)
                self.dbContext.tableAccountSession.update(model: self.localSession, upsert: false)
            }
        }
        let clientProfile = BTAPIClientProfile(host: host)
        clientProfile.useDeviceInfos().useAccountId().useAuthorizationSessionServerToken().useSessionKey()
        req.request(profile: clientProfile)
    }

    func logoutDevice() {
        let req = LogoutDeviceRequest()
        req.response = { _, res in
            if res.isHttpOK {
                self.logoutClient()
            }
        }
        let clientProfile = BTAPIClientProfile(host: host)
        clientProfile.useDeviceInfos().useAccountId().useAuthorizationSessionServerToken().useSessionKey()
        req.request(profile: clientProfile)
    }

    func logoutClient() {
        self.localSession.status = BTAccountSession.STATUS_LOGOUT_DEFAULT
        let s = self.localSession
        self.dbContext.tableAccountSession.update(model: self.localSession, upsert: false)
        self.localSession = s
    }
}

extension BTServiceContainer {
    public static func useBTSessionService(_ config: BTBaseConfig, dbContext: BTServiceDBContext) {
        let service = BTSessionService()
        service.configure(config: config, db: dbContext)
        addService(name: "BTSessionService", service: service)
    }

    public static func getBTSessionService() -> BTSessionService? {
        return getService(name: "BTSessionService") as? BTSessionService
    }
}

extension BTAPIClientProfile {
    @discardableResult
    public func useAuthorizationToken(token: String) -> BTAPIClientProfile {
        useHeader("Authorization", "Bearer \(token)")
        return self
    }

    @discardableResult
    public func useAuthorizationAPIToken() -> BTAPIClientProfile {
        self.useAuthorizationToken(token: BTServiceContainer.getBTSessionService()!.localSession!.token!)
        return self
    }

    @discardableResult
    public func useAuthorizationSessionServerToken() -> BTAPIClientProfile {
        self.useAuthorizationToken(token: BTServiceContainer.getBTSessionService()!.localSession!.sessionToken!)
        return self
    }

    @discardableResult
    public func useAccountId() -> BTAPIClientProfile {
        useHeader("accountId", (BTServiceContainer.getBTSessionService()?.localSession.accountId)!)
        return self
    }

    @discardableResult
    public func useSessionKey() -> BTAPIClientProfile {
        useHeader("session", (BTServiceContainer.getBTSessionService()?.localSession.session)!)
        return self
    }
}
