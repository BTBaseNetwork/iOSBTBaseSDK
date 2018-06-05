//
//  BTServiceConst.swift
//  iOSSDK
//
//  Created by Alex Chow on 2018/6/3.
//  Copyright © 2018年 btbase. All rights reserved.
//

import Foundation
public class BTServiceConst {
    public static let BT_WEB_API_AUDIENCE = "BTBaseWebAPI"
    /// Platform Id
    public static let PLATFORM_UNKNOW = 0
    public static let PLATFORM_IOS = 1
    public static let PLATFORM_ANDROID = 2
    public static let PLATFORM_WINDOWS = 3
    public static let PLATFORM_MACOS = 4
    public static let PLATFORM_LINUX = 5

    /// Store Channel Id
    public static let CHANNEL_UNKNOW = "UNKNOW"
    public static let CHANNEL_EDITOR_FAKE = "FAKE"
    public static let CHANNEL_APP_STORE = "APPSTORE"
    public static let CHANNEL_GOOGLE_PLAY = "GOOGLEPLAY"
    public static let CHANNEL_MS_MARKET = "MSMARKET"
    public static let CHANNEL_TAP_TAP = "TAPTAP"

    /// Account Type
    public static let ACCOUNT_TYPE_LOGOUT = -1
    public static let ACCOUNT_TYPE_EMPTY = 0
    public static let ACCOUNT_TYPE_BTPLATFORM = 1
    public static let ACCOUNT_TYPE_GAME_PRODUCER = 2
    public static let ACCOUNT_TYPE_GAME_PLAYER = 4

    /// Account Const
    public static let USER_ID_UNLOGIN = "USERID_UNLOGIN"
    public static let ACCOUNT_ID_UNLOGIN = "000000"

    /// Unity IAP Receipt Data Store
    public static let UNITY_IAP_STORE_FAKE = "fake"
    public static let UNITY_IAP_STORE_APPLE_APP_STORE = "AppleAppStore"
    public static let UNITY_IAP_STORE_GOOGLE_PLAY = "GooglePlay"

    private static let CLIENT_PASSWORD_SALT = "GNDAYZHAJ"

    public static func generateClientSaltPassword(password: String) -> String {
        return (password.sha256 + CLIENT_PASSWORD_SALT).sha256
    }
}
