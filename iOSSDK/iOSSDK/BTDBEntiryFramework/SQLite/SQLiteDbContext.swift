//
//  SQLiteDbContext.swift
//  BTBaseSDK
//
//  Created by Alex Chow on 2018/6/6.
//  Copyright © 2018年 btbase. All rights reserved.
//

import FMDB
import Foundation

public class SQLiteDbContext: BTDBContext {
    public private(set) var database: FMDatabase!
    init(dbpath: String) {
        #if DEBUG
        debugLog("SQliteDbContext DB Path:%@", dbpath)
        #endif
        database = FMDatabase(path: dbpath)
    }

    public func commit() {
        database.commit()
    }

    public func beginTransaction() {
        database.beginTransaction()
    }

    public func executeSql(sql: String) {
        database.executeStatements(sql)
    }
    
    public func open() {
        database.open()
    }
    
    public func close() {
        database.close()
    }
}
