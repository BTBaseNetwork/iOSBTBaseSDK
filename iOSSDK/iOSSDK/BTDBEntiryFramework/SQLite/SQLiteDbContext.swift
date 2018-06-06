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
        database.open()
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
}

public class SQLiteEntityProperty<T, V>: BTDBEntity.Property<T, V> {
    private(set) var constraints = [String]()

    private func getColumnType() -> String {
        var propertyType = "BLOB"
        let vt = V.self
        if vt == Int.self {
            propertyType = "INTEGER"
        } else if vt == Int32.self {
            propertyType = "INTEGER"
        } else if vt == Int64.self {
            propertyType = "INTEGER"
        } else if vt == uint.self {
            propertyType = "INTEGER"
        } else if vt == UInt64.self {
            propertyType = "INTEGER"
        } else if vt == UInt.self {
            propertyType = "INTEGER"
        } else if vt == Float.self {
            propertyType = "NUMERIC"
        } else if vt == Float32.self {
            propertyType = "NUMERIC"
        } else if vt == Float80.self {
            propertyType = "NUMERIC"
        } else if vt == Double.self {
            propertyType = "NUMERIC"
        } else if vt == Bool.self {
            propertyType = "NUMERIC"
        } else if vt == String.self {
            propertyType = length > 0 ? "CHAR(\(length))" : "TEXT"
        } else if vt == Date.self {
            propertyType = "TEXT"
        }
        return propertyType
    }

    var columnDesc: String {
        return "\(getColumnType()) \(constraints.joined(separator: " "))"
    }
}
