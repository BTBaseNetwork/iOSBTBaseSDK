//
//  BTAccount.swift
//  iOSSDK
//
//  Created by Alex Chow on 2018/6/3.
//  Copyright © 2018年 btbase. All rights reserved.
//

import Foundation
class BTAccount: Codable {
    public var accountId: String = BTServiceConst.ACCOUNT_ID_UNLOGIN
    public var accountTypes: String?
    public var userName: String?
    public var nick: String?
    public var email: String?
    public var mobile: String?
    public var signDateTs: Double = 0
}

class BTAppLink: Codable {
    public var url: String!
    public var androidPackageId: String!
    public var iOSUrlScheme: String!
    public var iOSAppId: String!
    public var iOSPackageId: String!
}

class BTDeviceInstalledApp: Codable {
    public var uniqueId: String?
    public var channel: String?
    public var bundleId: String?
    public var urlSchemes: String?
    public var launchDateTs: Double = 0
}

class BTAccountSession: Codable {
    public static let STATUS_LOGOUT = 0
    public static let STATUS_LOGIN = 1
    public static let STATUS_LOGOUT_DEFAULT = 2

    public var accountId: String = BTServiceConst.ACCOUNT_ID_UNLOGIN
    public var status: Int = BTAccountSession.STATUS_LOGOUT
    public var session: String?
    public var sessionToken: String?
    public var sTokenExpires: Date?
    public var token: String?
    public var tokenExpires: Date?
    public var password: String? // Salted password
    public var fillPassword: Bool = false // Auto fill password in sign in password field

    public func IsSessionLogined() -> Bool { return status == BTAccountSession.STATUS_LOGIN }
}

class BTMember: Codable {
    public static let MEMBER_TYPE_LOGOUT = -1
    public static let MEMBER_TYPE_FREE = 0
    public static let MEMBER_TYPE_RESERVED = 1
    public static let MEMBER_TYPE_PREMIUM = 2
    public static let MEMBER_TYPE_ADVANCED = 3

    public var id: Int64 = 0
    public var accountId: String?
    public var memberType: Int = 0
    public var expiredDateTs: Double = 0
}

class BTIAPOrder: Codable {
    public static let STATE_INIT = 0
    public static let STATE_PAY_SUC = 1
    public static let STATE_VERIFY_SUC = 2
    public static let STATE_VERIFY_FAILED = 3
    public static let STATE_VERIFY_SERVER_NETWORK_ERROR = 4

    public var transactionId: String = ""
    public var accountId: String = ""
    public var productId: String = ""
    public var locTitle: String?
    public var store: String?
    public var receipt: String?
    public var locPrice: String?
    public var date: Date?
    public var quantity: Int = 1
    public var state: Int = 0
    public var verifyCode: Int = 0
    public var verifyMsg: String?
}

class BTGameWallItem: Codable {
    public enum Label: Int {
        case none = 0
        case new = 1
        case hot = 2
    }

    public static let VIDEO_TYPE_UNSPECIFIC = 0
    public static let VIDEO_TYPE_VERTICAL = 1
    public static let VIDEO_TYPE_HORIZONTAL = 2

    public var itemId: String!
    public var gameName: String!
    public var iconUrl: String!
    
    public var videoUrl: String!
    public var videoLoop: Bool = false
    public var closeVideo: Bool = true //Effect Only the video loop is false
    public var videoType: Int = 0
    
    public var coverUrl: String!
    public var labels = 0
    public var priority = 0
    public var stars: Float = 0
    public var appLink: BTAppLink!

    public var loc: [String: String]!

    func getLocalizedString(key: String, defaultValue: String?) -> String? {
        let langCode = Locale.preferredLangCodeUnderlined
        return loc["\(key)_\(langCode)"] ?? defaultValue
    }

    public var hasHotLabel: Bool {
        return labels & Label.hot.rawValue != 0
    }

    public var hasNewLabel: Bool {
        return labels & Label.new.rawValue != 0
    }
}

extension BTGameWallItem {
    var localizedGameName: String {
        return getLocalizedString(key: "gameName", defaultValue: gameName) ?? "Unknow Game"
    }

    var localizedIconUrl: String {
        return getLocalizedString(key: "iconUrl", defaultValue: iconUrl) ?? ""
    }

    var localizedVideoUrl: String {
        return getLocalizedString(key: "videoUrl", defaultValue: videoUrl) ?? ""
    }

    var localizedCoverUrl: String {
        return getLocalizedString(key: "coverUrl", defaultValue: coverUrl) ?? ""
    }
}

class BTGameWallConfig: Codable {
    public var configVersion = 0
    public var items: [BTGameWallItem]!
}
