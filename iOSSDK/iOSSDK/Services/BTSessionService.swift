//
//  BTSessionService.swift
//  iOSSDK
//
//  Created by Alex Chow on 2018/6/3.
//  Copyright © 2018年 btbase. All rights reserved.
//

import FMDB
import Foundation
public class BTSessionService {
    public static let onSessionUpdated = NSNotification.Name("BTSessionService_onSessionUpdated")
    public static let onSessionUnauthorized = NSNotification.Name("BTSessionService_onSessionUnauthorized")

    var host: String = "http://localhost/"
    private(set) var localSession: BTAccountSession! {
        didSet {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: BTSessionService.onSessionUpdated, object: self)
            }
        }
    }

    var isSessionLogined: Bool { return self.localSession?.IsSessionLogined() ?? false }

    var dbContext: BTServiceDBContext!

    func configure(sessionServerHost: String, db: BTServiceDBContext) {
        self.initDB(db: db)
        self.host = sessionServerHost
        self.loadCachedSession()
        NotificationCenter.default.addObserver(self, selector: #selector(self.onRequestUnauthorized(a:)), name: onBTAPIRequestUnauthorized, object: nil)
    }

    private func initDB(db: BTServiceDBContext) {
        self.dbContext = db
        self.dbContext.createTable(model: BTAccountSession())
    }

    @objc private func onRequestUnauthorized(a _: Notification) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: BTSessionService.onSessionUnauthorized, object: self)
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func loadCachedSession() {
        if let session = dbContext.select(model: BTAccountSession(), query: "Status >= ?", parameters: [BTAccountSession.STATUS_LOGIN]).first {
            self.localSession = session
        } else {
            self.localSession = BTAccountSession()
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

    func login(userstring: String, password: String, cachedPassword: Bool, respAction: LoginAccountRequest.ResponseAction?) {
        let req = LoginAccountRequest()
        req.userstring = userstring
        req.password = BTServiceConst.generateClientSaltPassword(password: password)
        req.audience = "BTBaseWebAPI"
        req.response = { request, result in

            if result.isHttpOK {
                var session = BTAccountSession()
                session.accountId = result.content.accountId
                session.password = cachedPassword ? password : nil
                session.session = result.content.session
                session.sessionToken = result.content.sessionToken
                session.status = BTAccountSession.STATUS_LOGIN
                session.token = result.content.token
                self.localSession = session
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
                self.localSession.sessionToken = result.content.token
            }
        }
        let clientProfile = BTAPIClientProfile(host: host)
        clientProfile.useDeviceInfos().useAccountId().useAuthorizationSessionServerToken().useSessionKey()
        req.request(profile: clientProfile)
    }

    func logoutDevice() {
        let req = LogoutDeviceRequest()
        req.response = { _, _ in
        }
        let clientProfile = BTAPIClientProfile(host: host)
        clientProfile.useDeviceInfos().useAccountId().useAuthorizationSessionServerToken().useSessionKey()
        req.request(profile: clientProfile)
    }
}

extension BTServiceContainer {
    public static func useBTSessionService(serverHost: String, dbContext: BTServiceDBContext) {
        let service = BTSessionService()
        service.configure(sessionServerHost: serverHost, db: dbContext)
        addService(name: "BTSessionService", service: service)
    }

    public static func getBTSessionService() -> BTSessionService? {
        return getService(name: "BTSessionService") as? BTSessionService
    }
}

public extension BTAPIClientProfile {
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
