//
//  SQLiteHelper.swift
//  BTBaseSDK
//
//  Created by Alex Chow on 2018/6/6.
//  Copyright © 2018年 btbase. All rights reserved.
//

import Foundation
class SQLiteHelper {
    static func createTableSql(tableName: String, fields: [(field: String, fieldDesc: String)]) -> String {
        let sql = "CREATE TABLE IF NOT EXISTS \(tableName)(\(fields.map { "\($0.field) \($0.fieldDesc)" }.joined(separator: ",")))"
        #if DEBUG
        debugLog("createTableSql:\n%@", sql)
        #endif
        return sql
    }
    
    static func insertSql(tableName: String, fields: [String]) -> String {
        let sql = "INSERT INTO \(tableName) (\(fields.joined(separator: ","))) VALUES (\(fields.map { _ in "?" }.joined(separator: ",")))"
        #if DEBUG
        debugLog("insertSql:\n%@", sql)
        #endif
        return sql
    }
    
    static func deleteSql(tableName: String, query: String) -> String {
        let sql = "DELETE FROM \(tableName) WHERE \(query)"
        #if DEBUG
        debugLog("deleteSql:\n%@", sql)
        #endif
        return sql
    }
    
    static func selectSql(tableName: String, query: String = "") -> String {
        var sql = ""
        if String.isNullOrWhiteSpace(query) {
            sql = "SELECT * FROM \(tableName)"
        } else {
            sql = "SELECT * FROM \(tableName) WHERE \(query)"
        }
        #if DEBUG
        debugLog("selectSql:\n%@", sql)
        #endif
        return sql
    }
    
    static func updateSql(tableName: String, fields: [String], query: String = "") -> String {
        var sql = ""
        if String.isNullOrWhiteSpace(query) {
            sql = "UPDATE \(tableName) SET \(fields.map { "\($0)=?" }.joined(separator: ","))"
        } else {
            sql = "UPDATE \(tableName) SET \(fields.map { "\($0)=?" }.joined(separator: ",")) WHERE \(query)"
        }
        #if DEBUG
        debugLog("updateSql:\n%@", sql)
        #endif
        return sql
    }
}
