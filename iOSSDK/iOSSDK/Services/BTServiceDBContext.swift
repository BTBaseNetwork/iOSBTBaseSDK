//
//  BTServiceDBManager.swift
//  iOSSDK
//
//  Created by Alex Chow on 2018/6/3.
//  Copyright © 2018年 btbase. All rights reserved.
//

import FMDB
import Foundation

public class BTServiceDBContext: SQLiteDbContext {
    private(set) var tableAccount: BTDBTableSet<BTAccount>!
    // private(set) var tableMember: SQLiteTableSet<BTMember>!
    // private(set) var tableAccountSession: SQLiteTableSet<BTAccountSession>!

    override init(dbpath: String) {
        super.init(dbpath: dbpath)
        tableAccount = SQLiteTableSet<BTAccount>(dbContext: self, scheme: "BTAccount")
        //tableMember = SQLiteTableSet<BTMember>(dbContext: self, entity: BTDBEntity.Builder(scheme: "BTMember").build(BTMember.self))
        //tableAccountSession = SQLiteTableSet<BTAccountSession>(dbContext: self, entity: BTDBEntity.Builder(scheme: "BTAccountSession").build(BTAccountSession.self))
    }
}

public protocol BTServiceDBModel {
    func tableName() -> String
    func fieldDescs() -> [(field: String, fieldDesc: String)]
    func insertFieldsValues() -> [(field: String, value: Any)]
    func modelFromResultSet(resultSet: FMResultSet) -> BTServiceDBModel
}

extension BTServiceDBContext {
    public func createTable<T>(model: T) where T: BTServiceDBModel {
        let sql = SQLiteHelper.createTableSql(tableName: model.tableName(), fields: model.fieldDescs())
        database.executeStatements(sql)
    }

    public func insert<T>(model: T) -> Bool where T: BTServiceDBModel {
        let insertFVs = model.insertFieldsValues()
        let fields = insertFVs.map { $0.field }
        let values = insertFVs.map { $0.value }
        let tbName = model.tableName()
        let sql = SQLiteHelper.insertSql(tableName: tbName, fields: fields)
        if let _ = try? database.executeUpdate(sql, values: values) {
            return true
        }
        return false
    }

    public func select<T>(model: T, query: String, parameters: [Any]) -> [T] where T: BTServiceDBModel {
        let sql = SQLiteHelper.selectSql(tableName: model.tableName(), query: query)
        if let resultSet = try? database.executeQuery(sql, values: parameters) {
            var result = [T]()
            while resultSet.next() {
                result.append(model.modelFromResultSet(resultSet: resultSet) as! T)
            }
            return result
        }
        return []
    }

    public func update<T>(model: T, query: String, parameters: [Any]) -> Bool where T: BTServiceDBModel {
        let insertFVs = model.insertFieldsValues()
        let fields = insertFVs.map { $0.field }
        let values = insertFVs.map { $0.value }
        let sql = SQLiteHelper.updateSql(tableName: model.tableName(), fields: fields, query: query)
        if let _ = try? database.executeUpdate(sql, values: values + parameters) {
            return true
        }
        return false
    }
}
