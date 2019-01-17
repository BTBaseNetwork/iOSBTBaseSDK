//
//  BTUserAssetService.swift
//  BTBaseSDK
//
//  Created by Alex Chow on 2019/1/17.
//  Copyright © 2019 btbase. All rights reserved.
//

import Foundation
public class BTUserAssetService : NSObject{
    private var config: BTBaseConfig!
    private var host = "http://localhost:6000"
    
    func configure(config: BTBaseConfig) {
        self.config = config
        self.host = config.getString(key: "BTUserAssetServiceHost")!
    }
    
    public func RetrieveUserAssets(callback:@escaping ([BTUserAssets]?)->Void) {
        let req = GetUserAssetsRequest()
        req.queue = DispatchQueue.global()
        let clientProfile = BTAPIClientProfile(host: host)
        clientProfile.useLang().useAppBundleId().useAccountId().useAuthorizationAPIToken()
        req.response = { (rq,res) in
            callback(res.content.assets)
        }
        req.request(profile: clientProfile)
    }
    
    public func RetrieveUserAssets(bycategory category:String,callback:@escaping ([BTUserAssets]?)->Void) {
        let req = GetUserAssetsBycategoryRequest()
        req.category = category
        req.queue = DispatchQueue.global()
        let clientProfile = BTAPIClientProfile(host: host)
        clientProfile.useLang().useAppBundleId().useAccountId().useAuthorizationAPIToken()
        req.response = { (rq,res) in
            callback(res.content.assets)
        }
        req.request(profile: clientProfile)
    }
    
    public func RetrieveUserAssets(byAssetsId assetsId:String,callback:@escaping ([BTUserAssets]?)->Void) {
        let req = GetUserAssetsByAssetsIdRequest()
        req.assetsId = assetsId
        req.queue = DispatchQueue.global()
        let clientProfile = BTAPIClientProfile(host: host)
        clientProfile.useLang().useAppBundleId().useAccountId().useAuthorizationAPIToken()
        req.response = { (rq,res) in
            callback(res.content.assets)
        }
        req.request(profile: clientProfile)
    }
    
    public func addNewAssets(newAssets:BTUserAssets,callback:@escaping (BTUserAssets?)->Void) {
        let req = AddUserAssetsRequest()
        req.assetsId = newAssets.assetsId
        req.amount = newAssets.amount
        req.assets = newAssets.assets
        req.category = newAssets.category
        req.addSignature()
        req.queue = DispatchQueue.global()
        let clientProfile = BTAPIClientProfile(host: host)
        clientProfile.useLang().useAppBundleId().useAccountId().useAuthorizationAPIToken().useSessionKey()
        req.response = { (rq,res) in
            callback(res.content)
        }
        req.request(profile: clientProfile)
    }
    
    public func updateAssets(modifiedAssets:BTUserAssets,callback:@escaping (BTUserAssets?)->Void) {
        let req = UpdateUserAssetsRequest()
        req.id = modifiedAssets.id
        req.assetsId = modifiedAssets.assetsId
        req.amount = modifiedAssets.amount
        req.assets = modifiedAssets.assets
        req.category = modifiedAssets.category
        req.addSignature()
        req.queue = DispatchQueue.global()
        let clientProfile = BTAPIClientProfile(host: host)
        clientProfile.useLang().useAppBundleId().useAccountId().useAuthorizationAPIToken().useSessionKey()
        req.response = { (rq,res) in
            callback(res.content)
        }
        req.request(profile: clientProfile)
    }
}

extension BTServiceContainer {
    public static func useBTUserAssetService(_ config: BTBaseConfig) {
        let service = BTUserAssetService()
        addService(name: "BTUserAssetService", service: service)
        service.configure(config: config)
    }
    
    public static func getBTUserAssetService() -> BTUserAssetService? {
        return getService(name: "BTUserAssetService") as? BTUserAssetService
    }
}
