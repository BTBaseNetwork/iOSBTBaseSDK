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
    public var category:String!
    public var assets:String!
    public var amount:Int = 0
    
    @objc public func toDict() -> NSDictionary {
        let dict = NSMutableDictionary()
        dict["assetsId"] = self.assetsId
        dict["category"] = self.category
        dict["assets"] = self.assets
        dict["id"] = self.id
        dict["amount"] = self.amount
        return dict
    }
    
    @objc static public func fromDict(dict:NSDictionary) -> OCUserAssets {
        let res = OCUserAssets()
        res.assetsId = dict["assetsId"] as? String
        res.category = dict["category"] as? String
        res.assets = dict["assets"] as? String
        res.id = dict["id"] as! Int64
        res.amount = dict["amount"] as! Int
        return res
    }
    
    @objc public func toJson() -> String?{
        let dict = toDict()
        if let json = try? JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions(rawValue: 0)){
            return String(data: json, encoding: .utf8)
        }
        return nil
    }
    
    @objc public func fromJson(json:String) -> OCUserAssets?{
        if let data = json.data(using: .utf8),let obj = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0)){
            if let dict = obj as? NSDictionary{
                return OCUserAssets.fromDict(dict: dict)
            }
        }
        return nil
    }
    
    @objc static public func arrayToJson(arr:NSArray) -> String?{
        var list = [OCUserAssets]()
        
        for item in arr {
            if let a = item as? OCUserAssets{
                list.append(a)
            }
        }
        
        let str = list.map{$0.toJson()}.filter{!String.isNullOrWhiteSpace($0)}.map{$0!}.joined(separator: ",")
        
        return "[\(str)]"
    }
}

extension OCUserAssets{
    convenience init(rawAssets:BTUserAssets) {
        self.init()
        self.id = rawAssets.id
        self.assetsId = rawAssets.assetsId
        self.category = rawAssets.category
        self.assets = rawAssets.assets
        self.amount = rawAssets.amount
    }
    
    func toBTUserAssets() -> BTUserAssets {
        let res = BTUserAssets()
        res.id = self.id
        res.assetsId = self.assetsId
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
