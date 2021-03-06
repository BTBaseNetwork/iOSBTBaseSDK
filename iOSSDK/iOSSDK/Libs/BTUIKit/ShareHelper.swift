//
//  ShareHelper.swift
//  smashanything
//
//  Created by Alex Chow on 2017/6/27.
//  Copyright © 2017年 Bahamut. All rights reserved.
//

import Foundation
import UIKit

class ShareHelper: NSObject {
    static let shareError = Notification.Name("ShareHelper_shareError")
    static let shareWithType = Notification.Name("ShareHelper_shareWithType")
    static let shareShown = Notification.Name("ShareHelper_shareShown")

    static let snsTypes: [UIActivity.ActivityType] = [
        UIActivity.ActivityType.postToVimeo,
        UIActivity.ActivityType.postToWeibo,
        UIActivity.ActivityType.postToFlickr,
        UIActivity.ActivityType.postToTwitter,
        UIActivity.ActivityType.postToFacebook,
        UIActivity.ActivityType.postToTencentWeibo,
        UIActivity.ActivityType.mail,
        UIActivity.ActivityType.message,
    ]

    static let snsBundlePrefix: [String] = [
        "com.tencent",
        "com.burbn.instagram",
        "com.tumblr",
        "com.google.GooglePlus",
        "jp.naver.line",
        "com.toyopagroup.picaboo",
    ]

    static var shareSNSTimes: Int {
        get {
            return UserSetting.getUserIntValue("shareSNSTimes")
        }
        set {
            UserSetting.setUserIntValue("shareSNSTimes", value: newValue)
        }
    }

    static func share(vc: UIViewController, shareItems: [Any], srcView: UIView? = nil, srcBarItem: UIBarButtonItem? = nil, srcRect: CGRect? = nil) {
        let ac = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        ac.completionWithItemsHandler = { type, flag, _, error in
            if error != nil {
                NotificationCenter.default.post(name: shareError, object: self, userInfo: ["error": error!])
            } else if let t = type {
                if snsTypes.contains(t) || (snsBundlePrefix.contains(where: { t.rawValue.hasBegin($0) })) {
                    shareSNSTimes += 1
                    NotificationCenter.default.post(name: shareWithType, object: self, userInfo: ["type": t.rawValue, "suc": "\(flag)"])
                }
            }
        }

        ac.popoverPresentationController?.sourceView = srcView
        ac.popoverPresentationController?.barButtonItem = srcBarItem
        if let sr = srcRect {
            ac.popoverPresentationController?.sourceRect = sr
        }
        ac.excludedActivityTypes = [.airDrop, .addToReadingList, .print, .assignToContact]
        if #available(iOS 9.0, *) {
            ac.excludedActivityTypes?.append(.openInIBooks)
        }
        vc.present(ac, animated: true) {
            NotificationCenter.default.post(name: shareShown, object: self)
        }
    }

    static func addShareObservers(observer: Any, selector: Selector) {
        NotificationCenter.default.addObserver(observer, selector: selector, name: shareError, object: nil)
        NotificationCenter.default.addObserver(observer, selector: selector, name: shareWithType, object: nil)
        NotificationCenter.default.addObserver(observer, selector: selector, name: shareShown, object: nil)
    }

    static func removeShareObservers(observer: Any) {
        NotificationCenter.default.removeObserver(observer, name: shareError, object: nil)
        NotificationCenter.default.removeObserver(observer, name: shareWithType, object: nil)
        NotificationCenter.default.removeObserver(observer, name: shareShown, object: nil)
    }
}
