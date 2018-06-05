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
            NotificationCenter.default.post(name: BTSessionService.onSessionUpdated, object: self)
        }
    }

    var isSessionLogined: Bool { return localSession?.IsSessionLogined() ?? false }

    var dbContext: BTServiceDBContext!

    func configure(sessionServerHost: String) {
        host = sessionServerHost
        loadCachedSession()
        NotificationCenter.default.addObserver(self, selector: #selector(onRequestUnauthorized(a:)), name: onBTAPIRequestUnauthorized, object: nil)
    }

    @objc private func onRequestUnauthorized(a _: Notification) {
        NotificationCenter.default.post(name: BTSessionService.onSessionUnauthorized, object: self)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func loadCachedSession() {
        if let db = dbContext?.database, let res = try? db.executeQuery("select * from BTAccountSession where Status >= ?", values: [BTAccountSession.STATUS_LOGIN]) {
            localSession = BTAccountSession.parse(resultSet: res)
        } else {
            localSession = BTAccountSession()
        }
    }

    func checkDeviceAccountActive(respAction: CheckDeviceAccountActivedRequest.ResponseAction?) {
        let req = CheckDeviceAccountActivedRequest()
        req.reactive = false
        req.response = respAction
        let clientProfile = BTAPIClientProfile(host: host)
        clientProfile.useDeviceInfos()
        req.request(profile: clientProfile)
    }

    func login(userstring: String, password: String, cachedPassword _: Bool, respAction: LoginAccountRequest.ResponseAction?) {
        let req = LoginAccountRequest()
        req.userstring = userstring
        req.password = BTServiceConst.generateClientSaltPassword(password: password)
        req.audience = "BTBaseWebAPI"
        req.response = respAction

        let clientProfile = BTAPIClientProfile(host: host)
        clientProfile.useDeviceInfos().useLang().useClientId()
        req.request(profile: clientProfile)
    }

    func refreshToken() {
        let req = RefreshTokenRequest()
        req.audience = "BTBaseWebAPI"
        req.response = { _, _ in
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
    public static func useBTSessionService(serverHost: String) {
        let service = BTSessionService()
        service.configure(sessionServerHost: serverHost)
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
        useAuthorizationToken(token: BTServiceContainer.getBTSessionService()!.localSession!.token!)
        return self
    }

    @discardableResult
    public func useAuthorizationSessionServerToken() -> BTAPIClientProfile {
        useAuthorizationToken(token: BTServiceContainer.getBTSessionService()!.localSession!.sessionToken!)
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
