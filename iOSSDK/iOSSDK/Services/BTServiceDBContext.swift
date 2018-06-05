//
//  BTServiceDBManager.swift
//  iOSSDK
//
//  Created by Alex Chow on 2018/6/3.
//  Copyright © 2018年 btbase. All rights reserved.
//

import FMDB
import Foundation
public protocol BTServiceDBModel {
    func tableName() -> String
    func fieldDescs() -> [(field:String,fieldDesc:String)]
    func insertFieldsValues() -> [(field:String,value:Any)]
    func modelFromResultSet(resultSet:FMResultSet) -> BTServiceDBModel
}

public class BTServiceDBContext {
    public private(set) var database: FMDatabase!
    init(dbpath: String) {
        #if DEBUG
            debugLog("BTServiceDBContext DB Path:%@", dbpath)
        #endif
        database = FMDatabase(path: dbpath)
        database.open()
    }
    
    public func createTable<T>(model:T) where T:BTServiceDBModel
    {
        let sql = SQLiteHelper.createTableSql(tableName: model.tableName(), fields: model.fieldDescs())
        database.executeStatements(sql)
    }
    
    public func insert<T>(model:T) -> Bool where T:BTServiceDBModel
    {
        let insertFVs = model.insertFieldsValues()
        let fields = insertFVs.map{$0.field}
        let values = insertFVs.map{$0.value}
        let tbName = model.tableName()
        let sql = SQLiteHelper.insertSql(tableName: tbName, fields: fields)
        if let _ = try? database.executeUpdate(sql, values: values){
            return true
        }
        return false
    }
    
    public func select<T>(model:T,query:String,parameters:[Any]) -> [T] where T:BTServiceDBModel
    {
        let sql = SQLiteHelper.selectSql(tableName: model.tableName(), query: query)
        if let resultSet = try? database.executeQuery(sql, values: parameters){
            var result = [T]()
            while resultSet.next(){
                result.append(model.modelFromResultSet(resultSet: resultSet) as! T)
            }
            return result
        }
        return []
    }
    
    public func update<T>(model:T,query:String,parameters:[Any]) -> Bool where T:BTServiceDBModel
    {
        let insertFVs = model.insertFieldsValues()
        let fields = insertFVs.map{$0.field}
        let values = insertFVs.map{$0.value}
        let sql = SQLiteHelper.updateSql(tableName: model.tableName(), fields: fields, query: query)
        if let _ = try? database.executeUpdate(sql, values: values + parameters){
            return true
        }
        return false
    }
}

class SQLiteHelper {
    static func createTableSql(tableName: String, fields: [(field:String,fieldDesc:String)]) -> String {
        let sql = "CREATE TABLE IF NOT EXISTS \(tableName)(\(fields.map { "\($0.field) \($0.fieldDesc)" }.joined(separator: ",")))"
        #if DEBUG
            debugLog("createTableSql:\n%@", sql)
        #endif
        return sql
    }

    static func insertSql(tableName: String, fields: [String]) -> String {
        let sql = "INSERT INTO \(tableName)(\(fields.joined(separator: ",")) VALUES(\(fields.map { _ in "?" }.joined(separator: ",")))"
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
