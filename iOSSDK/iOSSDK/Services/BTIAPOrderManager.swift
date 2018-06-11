//
//  BTIAPOrderManager.swift
//  BTBaseSDK
//
//  Created by Alex Chow on 2018/6/11.
//  Copyright © 2018年 btbase. All rights reserved.
//

import Foundation
class BTIAPOrderManager {
    private(set) static var instance: BTIAPOrderManager = {
        BTIAPOrderManager()
    }()
    
    var dbContext: BTServiceDBContext!
    
    static func initManager(dbContext: BTServiceDBContext) {
        instance.dbContext = dbContext
    }
    
    private init() {}
    
    func getAllOrders() -> [BTIAPOrder] {
        return dbContext.tableIAPOrder.query(sql: "SELECT * FROM \(dbContext.tableIAPOrder.tableName)", parameters: nil).map { $0 }
    }
}
