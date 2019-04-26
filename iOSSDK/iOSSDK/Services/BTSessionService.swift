//
//  BTSessionService.swift
//  iOSSDK
//
//  Created by Alex Chow on 2018/6/3.
//  Copyright © 2018年 btbase. All rights reserved.
//

import BTSDK_FMDB
import Foundation
class BTSessionService {
    public static let onSessionUpdated = NSNotification.Name("BTSessionService_onSessionUpdated")
    public static let onSessionInvalid = NSNotification.Name("BTSessionService_onSessionInvalid")
    fileprivate var config: BTBaseConfig!
    private var host: String = "http://localhost/"
    private(set) var localSession: BTAccountSession! {
        didSet {
            NotificationCenter.default.postWithMainQueue(name: BTSessionService.onSessionUpdated, object: self)
        }
    }

    var isSessionLogined: Bool { return self.localSession?.IsSessionLogined() ?? false }

    func configure(config: BTBaseConfig) {
        guard let host = config.getString(key: "BTSessionServiceHost") else {
            fatalError("[BTSessionService] Config Not Exists:BTSessionServiceHost")
        }
        self.config = config
        self.host = host
        self.loadCachedSession()
        NotificationCenter.default.addObserver(self, selector: #selector(self.onRequestUnauthorized(a:)), name: Notification.Name.BTAPIRequestUnauthorized, object: nil)
    }

    @objc private func onRequestUnauthorized(a: Notification) {
        #if DEBUG
        debugLog("Token Is Unauthorized, Request: %@", "\(a.object ?? "Unknow")")
        #endif
        self.checkAndRefreshToken()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func loadCachedSession() {
        let dbContext = BTBaseSDK.getDbContext()
        let resultSet = dbContext.tableAccountSession.query(sql: SQLiteHelper.selectSql(tableName: dbContext.tableAccountSession.tableName, query: "Status == ? Or Status == ?"), parameters: [BTAccountSession.STATUS_LOGIN, BTAccountSession.STATUS_LOGOUT_DEFAULT]).sorted { $0.status < $1.status }
        dbContext.close()
        if let session = resultSet.first {
            self.localSession = session
            self.checkAndRefreshToken()
        } else {
            self.localSession = BTAccountSession()
        }
    }

    private func checkAndRefreshToken() {
        if self.localSession.IsSessionLogined() {
            if self.localSession.sTokenExpires == nil || self.localSession.sTokenExpires!.timeIntervalSince1970 < Date().timeIntervalSince1970 {
                debugLog("Session Token Is Expired, Relogin...")
                if String.isNullOrWhiteSpace(self.localSession.password) {
                    debugLog("Relogin Failed:%@", "No Cached Salted Password")
                    self.setSessionInvalid()
                } else {
                    self.login(self.localSession.accountId, self.localSession.password!, passwordSalted: true, autoFillPassword: false) { _, res in
                        if res.isHttpOK {
                            #if DEBUG
                            debugLog("Session Token Refreshed, New Token Expires:%@", self.localSession.sTokenExpires?.toLocalDateTimeString() ?? "Unknow")
                            #endif
                        } else {
                            debugLog("Relogin Failed:%@", res.error?.msg ?? "Unknow Reason")
                            self.setSessionInvalid()
                        }
                    }
                }

            } else if self.localSession.tokenExpires == nil || self.localSession.tokenExpires!.timeIntervalSince1970 < Date().addDays(3).timeIntervalSince1970 {
                debugLog("Token Is Nearly Expired, Refreshing...")
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
                let dbContext = BTBaseSDK.getDbContext()
                dbContext.tableAccountSession.update(model: session, upsert: true)
                let sql = SQLiteHelper.updateSql(tableName: dbContext.tableAccountSession.tableName, fields: ["status"], query: "accountId != ?")
                dbContext.tableAccountSession.executeUpdateSql(sql: sql, parameters: [BTAccountSession.STATUS_LOGOUT, session.accountId])
                dbContext.close()
                self.localSession = session
                #if DEBUG
                debugLog("Login Success, Session Token Expires:%@", self.localSession.sTokenExpires?.toLocalDateTimeString() ?? "Unknow")
                debugLog("Login Success, Token Expires:%@", self.localSession.tokenExpires?.toLocalDateTimeString() ?? "Unknow")
                #endif
            }

            DispatchQueue.main.async {
                respAction?(request, result)
            }
        }

        let clientProfile = BTAPIClientProfile(host: host)
        clientProfile.useDeviceInfos().useLang().useClientId()
        req.request(profile: clientProfile)
    }

    func updateNewPassword(_ newSaltedPassword: String) {
        if self.isSessionLogined {
            self.localSession.password = newSaltedPassword
            let dbContext = BTBaseSDK.getDbContext()
            dbContext.tableAccountSession.update(model: self.localSession, upsert: false)
            dbContext.close()
        }
    }

    private func refreshToken() {
        let req = RefreshTokenRequest()
        req.audience = "BTBaseWebAPI"
        req.response = { _, result in
            if result.isHttpOK {
                self.localSession.token = result.content.token
                self.localSession.tokenExpires = DateHelper.dateOfUnixTimeSpan(result.content.expires)
                let dbContext = BTBaseSDK.getDbContext()
                dbContext.tableAccountSession.update(model: self.localSession, upsert: false)
                dbContext.close()
                #if DEBUG
                debugLog("Token Refreshed, New Token Expires:%@", self.localSession.tokenExpires?.toLocalDateTimeString() ?? "Unknow")
                #endif
            } else if result.isHttpNotFound || result.isHttpForbidden {
                debugLog("Refresh Token Failed:%@", result.error?.msg ?? "Unknow Reason")
                self.setSessionInvalid()
            }
        }
        let clientProfile = BTAPIClientProfile(host: host)
        clientProfile.useDeviceInfos().useAccountId().useAuthorizationSessionServerToken().useSessionKey()
        req.request(profile: clientProfile)
    }

    private func setSessionInvalid() {
        if self.localSession.IsSessionLogined() {
            debugLog("Session Is Setted To Invalid")
            self.logoutClient()
            NotificationCenter.default.postWithMainQueue(name: BTSessionService.onSessionInvalid, object: self)
        }
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
        let dbContext = BTBaseSDK.getDbContext()
        dbContext.tableAccountSession.update(model: self.localSession, upsert: false)
        dbContext.close()
        self.localSession = s
    }
}

extension BTServiceContainer {
    public static func useBTSessionService(_ config: BTBaseConfig) {
        let service = BTSessionService()
        addService(name: "BTSessionService", service: service)
        service.configure(config: config)
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
