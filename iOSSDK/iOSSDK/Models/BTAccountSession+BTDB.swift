//
//  BTAccountSession+BTDB.swift
//  BTBaseSDK
//
//  Created by Alex Chow on 2018/6/6.
//  Copyright © 2018年 btbase. All rights reserved.
//

import Foundation
extension BTAccountSession: BTDBEntityModel {
    public static func newDefaultModel() -> BTDBEntityModel {
        return BTAccountSession()
    }
    
    public static func onBuildBTDBEntity(entity: BTDBEntity.Builder) {
        entity.hasProperty("id") { (model: BTAccountSession, value: Int?) in
            model.id = value ?? 0
        }.hasPrimaryKey().autoIncrement()
        
        entity.hasProperty("accountId") { (model: BTAccountSession, value: String?) in
            model.accountId = value
        }.length(valueLength: 24)
        
        entity.hasProperty("session") { (model: BTAccountSession, value: String?) in
            model.session = value
        }
        
        entity.hasProperty("sessionToken") { (model: BTAccountSession, value: String?) in
            model.sessionToken = value
        }
        
        entity.hasProperty("status") { (model: BTAccountSession, value: Int?) in
            model.status = value ?? 0
        }
        
        entity.hasProperty("token") { (model: BTAccountSession, value: String?) in
            model.token = value
        }
        entity.hasProperty("password") { (model: BTAccountSession, value: String?) in
            model.password = value
        }
    }
}
