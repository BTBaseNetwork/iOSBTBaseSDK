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
        entity.hasProperty("accountId", String.self) { (model: BTAccountSession, value: Any) in
            model.accountId = value as! String
        }.length(valueLength: 32).hasPrimaryKey()
        
        entity.hasProperty("session", String.self) { (model: BTAccountSession, value: Any) in
            model.session = value as? String
        }
        
        entity.hasProperty("sessionToken", String.self) { (model: BTAccountSession, value: Any) in
            model.sessionToken = value as? String
        }
        
        entity.hasProperty("sTokenExpires", Date.self) { (model: BTAccountSession, value: Any) in
            model.sTokenExpires = (value as? Date) ?? Date(timeIntervalSince1970: 0)
        }
        
        entity.hasProperty("status", Int.self) { (model: BTAccountSession, value: Any) in
            model.status = value as! Int
        }
        
        entity.hasProperty("token", String.self) { (model: BTAccountSession, value: Any) in
            model.token = value as? String
        }
        
        entity.hasProperty("tokenExpires", Date.self) { (model: BTAccountSession, value: Any) in
            model.tokenExpires = (value as? Date) ?? Date(timeIntervalSince1970: 0)
        }
        
        entity.hasProperty("password", String.self) { (model: BTAccountSession, value: Any) in
            model.password = value as? String
        }
        
        entity.hasProperty("fillPassword", String.self) { (model: BTAccountSession, value: Any) in
            model.fillPassword = (value as? Bool) ?? false
        }
    }
}
