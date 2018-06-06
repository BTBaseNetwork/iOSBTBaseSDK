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
        entity.hasProperty("accountId") { (model: BTAccount, value: String?) in
            model.accountId = value
        }.hasPrimaryKey().length(valueLength: 24).notNull()
        
        entity.hasProperty("accountTypes") { (model: BTAccount, value: String?) in
            model.accountTypes = value
        }
        
        entity.hasProperty("email") { (model: BTAccount, value: String?) in
            model.email = value
        }
        
        entity.hasProperty("mobile") { (model: BTAccount, value: String?) in
            model.mobile = value
        }
        
        entity.hasProperty("nick") { (model: BTAccount, value: String?) in
            model.nick = value
        }
        
        entity.hasProperty("signDateTs") { (model: BTAccount, value: Double?) in
            model.signDateTs = value ?? 0
        }
        
        entity.hasProperty("userName") { (model: BTAccount, value: String?) in
            model.userName = value
        }
    }
}
