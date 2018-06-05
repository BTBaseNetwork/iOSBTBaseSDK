//
//  BTSDKUIBundleExtensions.swift
//  iOSSDK
//
//  Created by Alex Chow on 2018/6/3.
//  Copyright © 2018年 btbase. All rights reserved.
//

import Foundation
import UIKit

extension Bundle {
    static var iOSBTBaseSDKUI: Bundle? {
        if let bundle = Bundle(identifier: "mobi.btbase.iossdkui") {
            return bundle
        }
        if let path = Bundle.main.path(forResource: "BTBaseSDKUI", ofType: "bundle") {
            return Bundle(path: path)
        }
        return nil
    }

    static var iOSBTBaseSDK: Bundle {
        return Bundle(identifier: "mobi.btbase.iossdk")!
    }
}

extension UIImage {
    static func BTSDKUIImage(named: String) -> UIImage? {
        return UIImage(named: named, in: Bundle.iOSBTBaseSDKUI, compatibleWith: nil)
    }
}

extension String {
    var localizedBTBaseString: String {
        if let bundle = Bundle.iOSBTBaseSDKUI {
            return LocalizedString(self, tableName: "BTBaseLocalized", bundle: bundle)
        }
        return self
    }
}
