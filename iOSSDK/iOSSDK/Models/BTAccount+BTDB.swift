//
//  Models+BTDB.swift
//  BTBaseSDK
//
//  Created by Alex Chow on 2018/6/6.
//  Copyright © 2018年 btbase. All rights reserved.
//

import Foundation
extension BTAccount: BTDBEntityModel {
    public static func newDefaultModel() -> BTDBEntityModel {
        return BTAccount()
    }
    
    public static func onBuildBTDBEntity(entity: BTDBEntity.Builder) {
        entity.hasProperty("accountId", String.self) { (model: BTAccount, value: Any) in
            model.accountId = value as! String
        }.hasPrimaryKey().length(valueLength: 32).notNull()
        
        entity.hasProperty("accountTypes", String.self) { (model: BTAccount, value: Any) in
            model.accountTypes = value as? String
        }
        
        entity.hasProperty("email", String.self) { (model: BTAccount, value: Any) in
            model.email = value as? String
        }
        
        entity.hasProperty("mobile", String.self) { (model: BTAccount, value: Any) in
            model.mobile = value as? String
        }
        
        entity.hasProperty("nick", String.self) { (model: BTAccount, value: Any) in
            model.nick = value as? String
        }
        
        entity.hasProperty("signDateTs", Double.self) { (model: BTAccount, value: Any) in
            model.signDateTs = value as! Double
        }
        
        entity.hasProperty("userName", String.self) { (model: BTAccount, value: Any) in
            model.userName = value as? String
        }
    }
}
