//
//  BTBaseConfig.swift
//  BTBaseSDK
//
//  Created by Alex Chow on 2018/6/7.
//  Copyright © 2018年 btbase. All rights reserved.
//

import Foundation
public class BTBaseConfig:NSObject {
    var config: NSDictionary!
    
    override init() {
        super.init()
    }
    
    public init?(filePath: String) {
        if let dict = NSDictionary(contentsOfFile: filePath) {
            config = dict
        } else {
            return nil
        }
    }
    
    func getString(key: String) -> String? {
        return config?[key] as? String
    }
    
    func getInt(key: String) -> Int? {
        return config?[key] as? Int
    }
    
    func getBool(key: String) -> Bool? {
        return config?[key] as? Bool
    }
    
    func getDouble(key: String) -> Double? {
        return config?[key] as? Double
    }
    
    func getDictionary(key: String) -> NSDictionary? {
        return config?[key] as? NSDictionary
    }
    
    func getURL(key: String) -> URL? {
        return config?[key] as? URL
    }
}

extension BTBaseConfig{
    public var appStoreID:String?{
        return getString(key: "AppStoreID")
    }
}
