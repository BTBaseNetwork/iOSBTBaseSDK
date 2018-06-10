//
//  BTBaseSDKManager.swift
//  BTBaseSDK
//
//  Created by Alex Chow on 2018/6/5.
//  Copyright © 2018年 btbase. All rights reserved.
//

import Foundation
import SwiftyStoreKit
public class BTBaseSDKManager {
    private init() {}
    private static var instance = { BTBaseSDKManager() }()
    internal private(set) static var defaultDbContext: BTServiceDBContext!
    public private(set) static var isSDKInited: Bool = false
    public static var swiftyStoreKitCompleteTransactions: (([Purchase]) -> Void)?

    private static var pasteboard = UIPasteboard(name: UIPasteboardName("mobi.btbase.iossdk"), create: true) {
        didSet {
            pasteboard?.setPersistent(true)
        }
    }

    public static func start() {
        if let config = BTBaseConfig() {
            if let dbname = config.getString(key: "BTBaseDB") {
                let dbPath = URL(fileURLWithPath: FileManager.persistentDataPath).appendingPathComponent(dbname).absoluteString
                let dbContext = BTServiceDBContext(dbpath: dbPath)
                dbContext.open()
                BTBaseSDKManager.defaultDbContext = dbContext

                BTServiceContainer.useBTGameWall(config)
                BTServiceContainer.useBTMemberService(config, dbContext: dbContext)
                BTServiceContainer.useBTAccountService(config, dbContext: dbContext)
                BTServiceContainer.useBTSessionService(config, dbContext: dbContext)

                NotificationCenter.default.addObserver(instance, selector: #selector(onSessionUpdated(a:)), name: BTSessionService.onSessionUpdated, object: nil)
                NotificationCenter.default.addObserver(instance, selector: #selector(applicationWillTerminate(a:)), name: NSNotification.Name.UIApplicationWillTerminate, object: nil)
                SwiftyStoreKit.completeTransactions { purchases in
                    BTBaseSDKManager.swiftyStoreKitCompleteTransactions?(purchases)
                }

                isSDKInited = true

            } else {
                debugLog("Couldn't initialize BTBaseSDK: lost BTBaseDB")
            }
        } else {
            debugLog("Couldn't initialize BTBaseSDK: lost btbase.plist")
        }
    }

    @objc private func applicationWillTerminate(a: Notification) {
        BTBaseSDKManager.defaultDbContext?.close()
    }

    @objc private func onSessionUpdated(a: Notification) {
        if let sessionService = BTServiceContainer.getBTSessionService(), let accountId = sessionService.localSession?.accountId {
            let accountService = BTServiceContainer.getBTAccountService()
            let memberService = BTServiceContainer.getBTMemberService()
            if sessionService.isSessionLogined {
                accountService?.loadLocalAccount(accountId: accountId)
                memberService?.loadLocalProfile(accountId: accountId)
                accountService?.fetchProfile()
                memberService?.fetchMemberProfile()
            } else {
                accountService?.setLogout()
                memberService?.setLogout()
            }
        }
    }

    public class ClientSharedAuthentication: Codable {
        public static func parse(json: String) -> ClientSharedAuthentication? {
            if let data = json.data(using: .utf8), let obj = try? JSONDecoder().decode(ClientSharedAuthentication.self, from: data) {
                return obj
            }
            return nil
        }

        public func toJson() -> String? {
            if let json = try? JSONEncoder().encode(self) {
                return String(data: json, encoding: .utf8)
            }
            return nil
        }

        public var accountId: String!
        public var saltedPassword: String!
    }

    static func shareAuthentication(_ auth: ClientSharedAuthentication) {
        if let json = auth.toJson() {
            let item: [String: Any] = ["Authentication": json]
            BTBaseSDKManager.pasteboard?.addItems([item])
        }
    }

    static func getAuthentication() -> ClientSharedAuthentication? {
        if let items = BTBaseSDKManager.pasteboard?.items {
            for item in items {
                if item.keys.contains("Authentication") {
                    if let json = item["Authentication"] as? String {
                        return ClientSharedAuthentication.parse(json: json)
                    }
                }
            }
        }
        return nil
    }

    static func tryShowLoginWithSharedAuthenticationAlert(vc: UIViewController) {
        if let auth = getAuthentication() {
            let title = "BTLocTitleSharedAuthenticationExists".localizedBTBaseString
            let msg = "BTLocMsgSharedAuthenticationExists".localizedBTBaseString
            vc.showAlert(title, msg: msg, actions: [ALERT_ACTION_CANCEL, UIAlertAction(title: "BTLocSignIn".localizedBTBaseString, style: .default, handler: { _ in
                BTServiceContainer.getBTSessionService()?.login(auth.accountId, auth.saltedPassword, passwordSalted: true, autoFillPassword: false, respAction: { _, res in
                    if res.isHttpOK {
                    } else {
                    }
                })
            })])
        }
    }
}
