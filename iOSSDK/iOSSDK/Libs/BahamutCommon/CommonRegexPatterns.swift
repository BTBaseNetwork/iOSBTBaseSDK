//
//  CommonRegexPatterns.swift
//  BTBaseSDK
//
//  Created by Alex Chow on 2018/6/4.
//  Copyright © 2018年 btbase. All rights reserved.
//

import Foundation
public class CommonRegexPatterns {
    public static let PATTERN_CHINESE = "[\\u4e00-\\u9fa5]"
    public static let PATTERN_HTML = "<(\\S*?)[^>]*>.*?</\\1>|<.*? />"
    public static let PATTERN_EMAIL = "\\w+([-+.]\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*"
    public static let PATTERN_URL = "[a-zA-z]+://[^\\s]*"
    public static let PATTERN_ACCOUNT_ID = "[1-9][0-9]{5,23}"
    public static let PATTERN_USERNAME = "^[a-zA-Z][a-zA-Z0-9_]{3,23}$"
    public static let PATTERN_PASSWORD_HASH = "^[a-zA-Z0-9_]{4,}$"
    public static let PATTERN_PASSWORD = "^[a-zA-Z0-9_`~!@#\\$%\\^&\\*=\\-\\+><\\?';:]{6,20}$"
    public static let PATTERN_PHONE_NO = "\\+?[0-9]+[0-9\\-]+[0-9]"
    public static let PATTERN_CHINESE_NICK = "^[_a-zA-Z0-9]{1,23}|[_a-zA-Z0-9\\u4e00-\\u9fa5]{1,12}$"
    public static let PATTERN_CHINESE_PHONE = "\\d{3}-\\d{8}|\\d{4}-\\d{7}"
    public static let PATTERN_CHINESE_MOBILE = "^((13[0-9])|(15[^4,\\D])|(18[0-9]))\\d{8}$"
    public static let PATTERN_QQ = "[1-9][0-9]{4,}"
    public static let PATTERN_CHINESE_POST_CODE = "[1-9]\\d{5}(?!\\d)"
    public static let PATTERN_CHINESE_ID_CARD = "\\d{15}|\\d{18}"
    public static let PATTERN_CHINESE_IP_ADDRESS = "\\d+\\.\\d+\\.\\d+\\.\\d+"
    public static let PATTERN_VERIFY_CODE = "^[0-9a-zA-Z]{4,}$"
}

extension String {
    public static func regexTestStringWithPattern(value: String?, pattern: String) -> Bool {
        if let v = value, v.isRegexMatch(pattern: pattern) {
            return true
        }
        return false
    }
}

extension String {
    func isMobileNumber() -> Bool {
        return isRegexMatch(pattern: CommonRegexPatterns.PATTERN_CHINESE_MOBILE)
    }

    func isEmail() -> Bool {
        return isRegexMatch(pattern: CommonRegexPatterns.PATTERN_EMAIL)
    }

    func isPassword() -> Bool {
        return isRegexMatch(pattern: CommonRegexPatterns.PATTERN_EMAIL)
    }

    func isUsername() -> Bool {
        return isRegexMatch(pattern: CommonRegexPatterns.PATTERN_EMAIL)
    }

    func isNickName() -> Bool {
        return isRegexMatch(pattern: CommonRegexPatterns.PATTERN_CHINESE_NICK)
    }
}
