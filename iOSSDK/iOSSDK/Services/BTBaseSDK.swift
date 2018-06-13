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

import Foundation
import SwiftyStoreKit

// MARK: SwiftyStoreKitCompleteDelegate

public protocol SwiftyStoreKitCompleteDelegate {
    func swiftStoreKitTransactionsComplete(_: [Purchase])
}

// MARK: BTBaseSDK

public class BTBaseSDK: NSObject {
    private static var instance = { BTBaseSDK() }()
    internal private(set) static var defaultDbContext: BTServiceDBContext!
    private static var pasteboard = UIPasteboard(name: UIPasteboardName("mobi.btbase.iossdk"), create: true) {
        didSet {
            pasteboard?.setPersistent(true)
        }
    }

    @objc public private(set) static var isSDKInited: Bool = false

    public static var swiftyStoreKitCompleteDelegate: SwiftyStoreKitCompleteDelegate?

    @objc public class func start() {
        if let config = BTBaseConfig() {
            if let dbname = config.getString(key: "BTBaseDB") {
                let dbPath = URL(fileURLWithPath: FileManager.persistentDataPath).appendingPathComponent(dbname).absoluteString
                let dbContext = BTServiceDBContext(dbpath: dbPath)
                dbContext.open()
                BTBaseSDK.defaultDbContext = dbContext
                BTBaseSDK.defaultDbContext.ensureDatabase()

                BTIAPOrderManager.initManager(dbContext: dbContext)

                BTServiceContainer.useBTGameWall(config)
                BTServiceContainer.useBTMemberService(config, dbContext: dbContext)
                BTServiceContainer.useBTAccountService(config, dbContext: dbContext)
                BTServiceContainer.useBTSessionService(config, dbContext: dbContext)

                NotificationCenter.default.addObserver(instance, selector: #selector(onSessionInvalid(a:)), name: BTSessionService.onSessionInvalid, object: nil)
                NotificationCenter.default.addObserver(instance, selector: #selector(onSessionUpdated(a:)), name: BTSessionService.onSessionUpdated, object: nil)
                NotificationCenter.default.addObserver(instance, selector: #selector(applicationWillTerminate(a:)), name: NSNotification.Name.UIApplicationWillTerminate, object: nil)
                SwiftyStoreKit.completeTransactions { purchases in
                    BTBaseSDK.swiftyStoreKitCompleteDelegate?.swiftStoreKitTransactionsComplete(purchases)
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
        BTBaseSDK.defaultDbContext?.close()
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
        var saltedPassword: String!
    }

    static func shareAuthentication(_ auth: ClientSharedAuthentication) {
        if let json = auth.toJson() {
            let item: [String: Any] = ["Authentication": json]
            BTBaseSDK.pasteboard?.addItems([item])
        }
    }

    static func getAuthentication() -> ClientSharedAuthentication? {
        if let items = BTBaseSDK.pasteboard?.items {
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

