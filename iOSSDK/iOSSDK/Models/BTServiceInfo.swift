//
//  BTServiceInfo.swift
//  BTBaseSDK
//
//  Created by Alex Chow on 2018/6/5.
//  Copyright © 2018年 btbase. All rights reserved.
//

import AdSupport
import Foundation
import UIKit

class BTServiceInfo {
    public static var DeviceId: String { return (UIDevice.current.identifierForVendor ?? ASIdentifierManager.shared().advertisingIdentifier).uuidString }
    public static var Clientd: String { return BundleId }
    public static var BundleId: String { return Bundle.main.bundleIdentifier ?? "unknow.bundleId" }
    public static var PlatformId: Int {
        #if TARGET_OS_IPHONE
            return BTServiceConst.PLATFORM_IOS
        #elseif TARGET_OS_MAC
            return BTServiceConst.PLATFORM_MACOS
        #else
            return BTServiceConst.PLATFORM_UNKNOW
        #endif
    }
    public static var DeviceName: String { return UIDevice.current.name }
    public static var DeviceModel: String { return UIDevice.current.originModelName }
}
