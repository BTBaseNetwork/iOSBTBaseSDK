//
//  BTAccount.swift
//  iOSSDK
//
//  Created by Alex Chow on 2018/6/3.
//  Copyright © 2018年 btbase. All rights reserved.
//

import Foundation
public class BTAccount: Codable {
    public var accountId: String = BTServiceConst.ACCOUNT_ID_UNLOGIN
    public var accountTypes: String?
    public var userName: String?
    public var nick: String?
    public var email: String?
    public var mobile: String?
    public var signDateTs: Double = 0
}

public class BTAppLink: Codable {
    public var url: String!
    public var androidPackageId: String!
    public var iOSUrlScheme: String!
    public var iOSAppId: String!
    public var iOSPackageId: String!
}

public class BTDeviceInstalledApp: Codable {
    public var uniqueId: String?
    public var channel: String?
    public var bundleId: String?
    public var urlSchemes: String?
    public var launchDateTs: Double = 0
}

public class BTAccountSession: Codable {
    public static let STATUS_LOGOUT = 0
    public static let STATUS_LOGIN = 1
    public static let STATUS_LOGOUT_DEFAULT = 2

    public var accountId: String = BTServiceConst.ACCOUNT_ID_UNLOGIN
    public var status: Int = BTAccountSession.STATUS_LOGOUT
    public var session: String?
    public var sessionToken: String?
    public var token: String?
    public var password: String?

    public func IsSessionLogined() -> Bool { return status == BTAccountSession.STATUS_LOGIN }
}

public class BTMember: Codable {
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

public class BTMemberOrderReceipt: Codable {
    public var transactionId: String = ""
    public var store: String?
    public var payload: String?
}

public class BTGameWallItem: Codable {
    public enum Label: Int {
        case None = 0
        case New = 1
        case Hot = 2
    }

    public static let VIDEO_TYPE_UNSPECIFIC = 0
    public static let VIDEO_TYPE_VERTICAL = 1
    public static let VIDEO_TYPE_HORIZONTAL = 2

    public var itemId: String!
    public var gameName: String!
    public var iconUrl: String!
    public var videoUrl: String!
    public var videoLoop: Bool = false
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

    func getLocalizedGameName() -> String {
        return getLocalizedString(key: "gameName", defaultValue: gameName) ?? "Unknow Game"
    }
}

public class BTGameWallConfig: Codable {
    public var configVersion = 0
    public var items: [BTGameWallItem]!
}
