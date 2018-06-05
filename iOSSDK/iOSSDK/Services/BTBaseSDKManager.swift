//
//  BTBaseSDKManager.swift
//  BTBaseSDK
//
//  Created by Alex Chow on 2018/6/5.
//  Copyright © 2018年 btbase. All rights reserved.
//

import Foundation
public class BTBaseSDKManager {
    private init() {}
    private static var instance = { BTBaseSDKManager() }()
    internal private(set) static var defaultDbContext: BTServiceDBContext!
    public private(set) static var isSDKInited: Bool = false

    public static func start() {
        if let configPath = Bundle.main.path(forResource: "btbase", ofType: "plist"), let config = NSDictionary(contentsOfFile: configPath) {
            if let dbname = config["BTBaseDB"] as? String {
                let dbPath = URL(fileURLWithPath: FileManager.persistentDataPath).appendingPathComponent(dbname).absoluteString
                let dbContext = BTServiceDBContext(dbpath: dbPath)
                BTBaseSDKManager.defaultDbContext = dbContext
                if let gameWallConfigUrl = config["BTGameWallConfig"] as? String {
                    BTServiceContainer.useBTGameWall(configUrl: gameWallConfigUrl)
                } else {
                    debugLog("Couldn't initialize BTBaseSDK: lost BTGameWallConfig")
                    return
                }

                if let memberServiceHost = config["BTMemberServiceHost"] as? String {
                    BTServiceContainer.useBTMemberService(serverHost: memberServiceHost, dbContext: dbContext)
                } else {
                    debugLog("Couldn't initialize BTBaseSDK: lost BTMemberServiceHost")
                    return
                }

                if let accountServiceHost = config["BTAccountServiceHost"] as? String {
                    BTServiceContainer.useBTAccountService(serverHost: accountServiceHost, dbContext: dbContext)
                } else {
                    debugLog("Couldn't initialize BTBaseSDK: lost BTAccountServiceHost")
                    return
                }

                if let sessionServiceHost = config["BTSessionServiceHost"] as? String {
                    BTServiceContainer.useBTSessionService(serverHost: sessionServiceHost, dbContext: dbContext)
                } else {
                    debugLog("Couldn't initialize BTBaseSDK: lost BTSessionServiceHost")
                    return
                }

                NotificationCenter.default.addObserver(instance, selector: #selector(onSessionUpdated(a:)), name: BTSessionService.onSessionUpdated, object: nil)

                isSDKInited = true

            } else {
                debugLog("Couldn't initialize BTBaseSDK: lost BTBaseDB")
            }
        } else {
            debugLog("Couldn't initialize BTBaseSDK: lost btbase.plist")
        }
    }

    @objc private func onSessionUpdated(a: Notification) {
        if BTServiceContainer.getBTSessionService()!.isSessionLogined {
            BTServiceContainer.getBTAccountService()?.fetchProfile()
            BTServiceContainer.getBTMemberService()?.fetchMemberProfile()
        }else{
            BTServiceContainer.getBTAccountService()?.setLogout()
            BTServiceContainer.getBTMemberService()?.setLogout()
        }
    }
}
