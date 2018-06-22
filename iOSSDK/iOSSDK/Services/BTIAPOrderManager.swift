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
    
    static func initManager() {
    }
    
    private init() {}
    
    func getAllOrders(accountId: String) -> [BTIAPOrder] {
        let dbContext = BTBaseSDK.getDbContext()
        let res = dbContext.tableIAPOrder.query(sql: "SELECT * FROM \(dbContext.tableIAPOrder.tableName) WHERE accountId=?", parameters: [accountId]).map { $0 }
        dbContext.close()
        return res
    }
    
    func getAllOrders() -> [BTIAPOrder] {
        let dbContext = BTBaseSDK.getDbContext()
        let res = dbContext.tableIAPOrder.query(sql: "SELECT * FROM \(dbContext.tableIAPOrder.tableName)", parameters: nil).map { $0 }
        dbContext.close()
        return res
    }
}
