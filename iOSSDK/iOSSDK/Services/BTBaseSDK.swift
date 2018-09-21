//
//  BTBaseSDK.swift
//  BTBaseSDK
//
//  Created by Alex Chow on 2018/6/5.
//  Copyright © 2018年 btbase. All rights reserved.
//

/*
 OC项目调用swift类需要满足以下条件
 1. Swift必须继承NSObject,需要公开的方法或属性需要加@objc
 2.OC项目需要在Build Setting里设置 Defines Modules 为 YES
 3.OC项目需要在Build Setting里设置 Objective-C Generated Interface Header Name 为 $(SWIFT_MODULE_NAME)-Swift.h
 4.OC项目需要在Build Setting里设置 Product Module Name 为 $(SWIFT_MODULE_NAME)

 参考:https://www.jianshu.com/p/b0a38b4ba5b9
 */

import CommonCrypto
import Foundation
import UIKit

// MARK: SwiftyStoreKitCompleteDelegate

public protocol SwiftyStoreKitCompleteDelegate {
    func swiftStoreKitTransactionsComplete(_: [Purchase])
}

// MARK: BTBaseSDK

public class BTBaseSDK: NSObject {
    private static var instance = { BTBaseSDK() }()
    private static var pasteboard: UIPasteboard? {
        // UIPasteboard(name: UIPasteboardName("mobi.btbase.iossdk"), create: true)
        return UIPasteboard.general
    }

    @objc public private(set) static var isSDKInited: Bool = false

    public private(set) static var config: BTBaseConfig!

    public static var swiftyStoreKitCompleteDelegate: SwiftyStoreKitCompleteDelegate?

    private static var dbPath: String!

    static func getDbContext() -> BTServiceDBContext {
        let dbContext = BTServiceDBContext(dbpath: dbPath)
        dbContext.open()
        return dbContext
    }

    @objc public class func start() {
        if let filePath = Bundle.main.path(forResource: "btbase", ofType: "plist"), let config = BTBaseConfig(filePath: filePath) {
            start(config: config)
        } else {
            debugLog("Couldn't initialize BTBaseSDK: lost btbase.plist")
        }
    }

    @objc public class func start(config: BTBaseConfig) {
        BTBaseSDK.config = config
        if let dbname = config.getString(key: "BTBaseDB") {
            dbPath = URL(fileURLWithPath: FileManager.persistentDataPath).appendingPathComponent(dbname).absoluteString

            let db = getDbContext()
            db.ensureDatabase()
            db.close()

            BTIAPOrderManager.initManager()

            // Account Service Must Init First
            BTServiceContainer.useBTAccountService(config)

            BTServiceContainer.useBTMemberService(config)
            BTServiceContainer.useBTSessionService(config)
            BTServiceContainer.useBTGameWall(config)

            NotificationCenter.default.addObserver(instance, selector: #selector(onSessionInvalid(a:)), name: BTSessionService.onSessionInvalid, object: nil)
            NotificationCenter.default.addObserver(instance, selector: #selector(onSessionUpdated(a:)), name: BTSessionService.onSessionUpdated, object: nil)
            NotificationCenter.default.addObserver(instance, selector: #selector(applicationWillTerminate(a:)), name: UIApplication.willTerminateNotification, object: nil)
            SwiftyStoreKit.completeTransactions { purchases in
                BTBaseSDK.swiftyStoreKitCompleteDelegate?.swiftStoreKitTransactionsComplete(purchases)
            }

            isSDKInited = true

        } else {
            debugLog("Couldn't initialize BTBaseSDK: lost BTBaseDB")
        }
    }

    @objc private func applicationWillTerminate(a: Notification) {
    }
}

// MARK: Session

public extension BTBaseSDK {
    @objc public static var isLogined: Bool {
        return BTServiceContainer.getBTSessionService()?.isSessionLogined ?? false
    }

    @objc private func onSessionInvalid(a: Notification) {
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
                BTBaseSDK.clearSharedAuthentication()
            } else {
                accountService?.setLogout()
                memberService?.setLogout()
            }
        }
    }

    class ClientSharedAuthentication: Codable {
        static func parse(json: String) -> ClientSharedAuthentication? {
            if let data = json.data(using: .utf8), let obj = try? JSONDecoder().decode(ClientSharedAuthentication.self, from: data) {
                return obj
            }
            return nil
        }

        func toJson() -> String? {
            if let json = try? JSONEncoder().encode(self) {
                return String(data: json, encoding: .utf8)
            }
            return nil
        }

        var accountId: String!
        var password: String!
    }

    static func shareAuthentication() {
        if let session = BTServiceContainer.getBTSessionService()?.localSession, session.IsSessionLogined(), let psw = session.password {
            let auth = BTBaseSDK.ClientSharedAuthentication()
            auth.accountId = session.accountId
            auth.password = psw
            #if DEBUG
            NSLog("shareAuthentication")
            #endif
            if let json = auth.toJson(), let base64 = json.base64String {
                BTBaseSDK.pasteboard?.string = "Authentication:\(base64)"
            }
        }
    }

    static func clearSharedAuthentication() {
        #if DEBUG
        NSLog("clearSharedAuthentication")
        #endif
        if BTBaseSDK.pasteboard?.string?.hasBegin("Authentication:") ?? false {
            BTBaseSDK.pasteboard?.string = ""
        }
    }

    static func getAuthentication() -> ClientSharedAuthentication? {
        if let content = BTBaseSDK.pasteboard?.string, content.hasBegin("Authentication:") {
            let base64 = content.replacingOccurrences(of: "Authentication:", with: "")
            if let json = base64.valueOfBase64String, let auth = ClientSharedAuthentication.parse(json: json) {
                return auth
            }
        }
        return nil
    }
}

// MARK: Badge Number

public extension BTBaseSDK {
    public static var badgeNumber: Int {
        get {
            return UserDefaults.standard.integer(forKey: "BTBaseSDK:badgeNumber")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "BTBaseSDK:badgeNumber")
        }
    }

    @objc public static func clearBadgeNumber() {
        badgeNumber = -1
    }

    @objc public static func getBadgeNumber() -> Int {
        return badgeNumber
    }
}

// MARK: Member

public extension BTBaseSDK {
    @objc public static var isInMemberSubscription: Bool {
        if let member = BTServiceContainer.getBTMemberService()?.localProfile?.preferredMember {
            return member.expiredDateTs > Date().timeIntervalSince1970
        }
        return false
    }
}

// MARK: Game Wall

public extension BTBaseSDK {
    @objc public static func fetchGameWallList(force: Bool) {
        BTServiceContainer.getGameWall()?.refreshGameWallList(force: force)
    }
}
