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
        entity.hasProperty("id") { (model: BTMember, value: Int64?) in
            model.id = value ?? 0
        }.hasPrimaryKey().autoIncrement()
        
        entity.hasProperty("accountId") { (model: BTMember, value: String?) in
            model.accountId = value
        }.length(valueLength: 24)
        
        entity.hasProperty("memberType") { (model: BTMember, value: Int?) in
            model.memberType = value ?? 0
        }
        
        entity.hasProperty("expiredDateTs") { (model: BTMember, value: Double?) in
            model.expiredDateTs = value ?? 0
        }
    }
}
