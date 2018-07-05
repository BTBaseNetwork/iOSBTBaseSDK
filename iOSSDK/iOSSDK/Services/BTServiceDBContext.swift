//
//  BTServiceDBManager.swift
//  iOSSDK
//
//  Created by Alex Chow on 2018/6/3.
//  Copyright © 2018年 btbase. All rights reserved.
//

import BTSDK_FMDB
import Foundation

public class BTServiceDBContext: SQLiteDbContext {
    private(set) var tableAccount: BTDBTableSet<BTAccount>!
    private(set) var tableMember: SQLiteTableSet<BTMember>!
    private(set) var tableAccountSession: SQLiteTableSet<BTAccountSession>!
    private(set) var tableIAPOrder: SQLiteTableSet<BTIAPOrder>!

    override init(dbpath: String) {
        super.init(dbpath: dbpath)
        tableAccount = SQLiteTableSet<BTAccount>(dbContext: self, scheme: "BTAccount")
        tableMember = SQLiteTableSet<BTMember>(dbContext: self, scheme: "BTMember")
        tableAccountSession = SQLiteTableSet<BTAccountSession>(dbContext: self, scheme: "BTAccountSession")
        tableIAPOrder = SQLiteTableSet<BTIAPOrder>(dbContext: self, scheme: "BTIAPOrder")
    }

    func ensureDatabase() {
        tableAccount.createTable()
        tableAccountSession.createTable()
        tableMember.createTable()
        tableIAPOrder.createTable()
    }
}
