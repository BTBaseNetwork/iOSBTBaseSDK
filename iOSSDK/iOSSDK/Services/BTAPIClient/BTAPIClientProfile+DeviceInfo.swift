//
//  BTAPIClientProfile+DeviceInfo.swift
//  BTBaseSDK
//
//  Created by Alex Chow on 2018/6/5.
//  Copyright © 2018年 btbase. All rights reserved.
//

import Foundation
extension BTAPIClientProfile {
    @discardableResult
    public func useDeviceInfos() -> BTAPIClientProfile {
        useDeviceId()
        useDeviceName()
        useDeviceModel()
        usePlatformId()
        return self
    }

    @discardableResult
    public func useLang() -> BTAPIClientProfile {
        useHeader("lang", Locale.preferredLangCode)
        return self
    }

    @discardableResult
    public func useDeviceName() -> BTAPIClientProfile {
        useHeader("devName", BTServiceInfo.DeviceName)
        return self
    }

    @discardableResult
    public func useDeviceId() -> BTAPIClientProfile {
        useHeader("devId", BTServiceInfo.DeviceId)
        return self
    }

    @discardableResult
    public func useDeviceModel() -> BTAPIClientProfile {
        useHeader("devModel", BTServiceInfo.DeviceModel)
        return self
    }

    @discardableResult
    public func useClientId() -> BTAPIClientProfile {
        useHeader("clientId", BTServiceInfo.DeviceId)
        return self
    }

    @discardableResult
    public func usePlatformId() -> BTAPIClientProfile {
        useHeader("platId", "\(BTServiceInfo.PlatformId)")
        return self
    }
}
