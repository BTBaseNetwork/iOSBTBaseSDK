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
}
