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

public class BTServiceInfo {
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

/*
 public static string DeviceId { get { return SystemInfo.deviceUniqueIdentifier; } }
 public static string Clientd { get { return BundleId; } }
 public static string BundleId
 {
 get
 {
 #if UNITY_ANDROID || UNITY_IOS || UNITY_OSX
 return Application.identifier;
 #else
 return "unknow_bundle_id";
 #endif
 }
 }
 public static int PlatformId
 {
 get
 {
 var platform = BTServiceConst.PLATFORM_UNKNOW;
 #if UNITY_IOS
 platform = BTServiceConst.PLATFORM_IOS;
 #elif UNITY_STANDALONE_LINUX
 platform = BTServiceConst.PLATFORM_LINUX;
 #elif UNITY_STANDALONE_OSX
 platform = BTServiceConst.PLATFORM_MACOS;
 #elif UNITY_ANDROID
 platform = BTServiceConst.PLATFORM_ANDROID;
 #elif UNITY_STANDALONE_WIN
 platform = BTServiceConst.PLATFORM_WINDOWS
 #endif
 return platform;
 }
 }

 public static string DeviceName
 {
 get
 {
 #if UNITY_EDITOR

 return "Unity Editor Player";
 #else
 if (string.IsNullOrEmpty(SystemInfo.deviceName))
 {
 return "Unknow Device";
 }
 return SystemInfo.deviceName;
 #endif
 }
 }

 public static string DeviceModel
 {
 get
 {
 #if UNITY_EDITOR

 return "Unity Editor Player";
 #else
 if (string.IsNullOrEmpty(SystemInfo.deviceModel))
 {
 return "Unknow Device Model";
 }
 return SystemInfo.deviceModel;
 #endif
 }
 }

 */
