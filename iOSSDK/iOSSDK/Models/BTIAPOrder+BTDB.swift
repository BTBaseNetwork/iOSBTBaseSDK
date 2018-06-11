//
//  BTIAPOrder+BTDB.swift
//  BTBaseSDK
//
//  Created by Alex Chow on 2018/6/11.
//  Copyright © 2018年 btbase. All rights reserved.
//

import Foundation
extension BTIAPOrder: BTDBEntityModel {
    public static func newDefaultModel() -> BTDBEntityModel {
        return BTIAPOrder()
    }
    
    public static func onBuildBTDBEntity(entity: BTDBEntity.Builder) {
        entity.hasProperty("transactionId", String.self) { (model: BTIAPOrder, value: Any) in
            model.transactionId = value as! String
        }.hasPrimaryKey()
        
        entity.hasProperty("productId", String.self) { (model: BTIAPOrder, value: Any) in
            model.productId = value as! String
        }
        
        entity.hasProperty("store", String.self) { (model: BTIAPOrder, value: Any) in
            model.store = value as? String
        }
        
        entity.hasProperty("receipt", String.self) { (model: BTIAPOrder, value: Any) in
            model.receipt = value as? String
        }
        
        entity.hasProperty("locPrice", String.self) { (model: BTIAPOrder, value: Any) in
            model.locPrice = value as? String
        }
        
        entity.hasProperty("date", Date.self) { (model: BTIAPOrder, value: Any) in
            model.date = value as? Date
        }
        
        entity.hasProperty("quantity", Int.self) { (model: BTIAPOrder, value: Any) in
            model.quantity = (value as? Int) ?? 1
        }
        
        entity.hasProperty("state", String.self) { (model: BTIAPOrder, value: Any) in
            model.state = (value as? Int) ?? 1
        }
        entity.hasProperty("verifyCode", Int.self) { (model: BTIAPOrder, value: Any) in
            model.verifyCode = (value as? Int) ?? 0
        }
        entity.hasProperty("verifyMsg", String.self) { (model: BTIAPOrder, value: Any) in
            model.verifyMsg = value as? String
        }
        entity.hasProperty("locTitle", String.self) { (model: BTIAPOrder, value: Any) in
            model.locTitle = value as? String
        }
    }
}
