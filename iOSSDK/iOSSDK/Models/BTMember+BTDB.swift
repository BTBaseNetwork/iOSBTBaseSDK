//
//  BTMember+BTDB.swift
//  BTBaseSDK
//
//  Created by Alex Chow on 2018/6/6.
//  Copyright © 2018年 btbase. All rights reserved.
//

import Foundation
extension BTMember: BTDBEntityModel {
    public static func newDefaultModel() -> BTDBEntityModel {
        return BTMember()
    }
    
    public static func onBuildBTDBEntity(entity: BTDBEntity.Builder) {
        entity.hasProperty("id", Int64.self) { (model: BTMember, value: Any) in
            model.id = value as! Int64
        }.hasPrimaryKey().autoIncrement()
        
        entity.hasProperty("accountId", String.self) { (model: BTMember, value: Any) in
            model.accountId = value as? String
        }.length(valueLength: 32)
        
        entity.hasProperty("memberType",Int.self) { (model: BTMember, value: Any) in
            model.memberType = value as! Int
        }
        
        entity.hasProperty("expiredDateTs",Double.self) { (model: BTMember, value: Any) in
            model.expiredDateTs = value as! Double
        }
    }
}
