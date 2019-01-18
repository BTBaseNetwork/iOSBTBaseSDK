//
//  BTBaseSDK+UserAssetService.swift
//  BTBaseSDK
//
//  Created by Alex Chow on 2019/1/18.
//  Copyright © 2019 btbase. All rights reserved.
//

import Foundation

// MARK: User Assets

public extension BTBaseSDK{
    public static func userAssetsService() -> BTUserAssetService?{
        return BTServiceContainer.getBTUserAssetService()
    }
}

// MARK: User Assets OC Bridge
public class OCUserAssets:NSObject{
    public var id:Int64 = 0
    public var assetsId:String!
    public var accountId:String!
    public var category:String!
    public var assets:String!
    public var amount:Int = 0
}

extension OCUserAssets{
    convenience init(rawAssets:BTUserAssets) {
        self.init()
        self.id = rawAssets.id
        self.assetsId = rawAssets.assetsId
        self.accountId = rawAssets.accountId
        self.category = rawAssets.category
        self.assets = rawAssets.assets
        self.amount = rawAssets.amount
    }
    
    func toBTUserAssets() -> BTUserAssets {
        let res = BTUserAssets()
        res.id = self.id
        res.assetsId = self.assetsId
        res.accountId = self.accountId
        res.category = self.category
        res.assets = self.assets
        res.amount = self.amount
        return res
    }
}

public class OCUserAssetsService:NSObject{
    private var rawService:BTUserAssetService!
    private override init() {
        super.init()
    }
    
    @objc public static func defaultService()->OCUserAssetsService?{
        if let s = BTBaseSDK.userAssetsService(){
            let service = OCUserAssetsService()
            service.rawService = s
            return service
        }
        return nil
    }
    
    @objc public func retrieveUserAssets(callback:@escaping ([OCUserAssets]?)->Void) {
        rawService.retrieveUserAssets { (result) in
            callback(result?.map{OCUserAssets(rawAssets: $0)})
        }
    }
    
    @objc public func retrieveUserAssets(byCategory category:String,callback:@escaping ([OCUserAssets]?)->Void) {
        rawService.retrieveUserAssets(byCategory: category) { (result) in
            callback(result?.map{OCUserAssets(rawAssets: $0)})
        }
    }
    
    @objc public func retrieveUserAssets(byAssetsId assetsId:String,callback:@escaping ([OCUserAssets]?)->Void) {
        rawService.retrieveUserAssets(byAssetsId: assetsId) { (result) in
            callback(result?.map{OCUserAssets(rawAssets: $0)})
        }
    }
    
    @objc public func addNewAssets(newAssets:OCUserAssets,callback:@escaping (OCUserAssets?)->Void) {
        rawService.addNewAssets(newAssets: newAssets.toBTUserAssets()) { (result) in
            if let r = result{
                callback(OCUserAssets(rawAssets: r))
            }else{
                callback(nil)
            }
        }
    }
    
    @objc public func updateAssets(modifiedAssets:OCUserAssets,callback:@escaping (OCUserAssets?)->Void) {
        rawService.updateAssets(modifiedAssets: modifiedAssets.toBTUserAssets()) { (result) in
            if let r = result{
                callback(OCUserAssets(rawAssets: r))
            }else{
                callback(nil)
            }
        }
    }
}
