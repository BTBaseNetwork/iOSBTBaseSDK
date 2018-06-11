//
//  Model+FMDB.swift
//  BTBaseSDK
//
//  Created by Alex Chow on 2018/6/5.
//  Copyright © 2018年 btbase. All rights reserved.
//
#if DEBUG_1
import FMDB
import Foundation

extension FMResultSet {
    func integer(forColumn: String) -> Int {
        return Int(int(forColumn: forColumn))
    }

    func integer(forColumn: Int32) -> Int {
        return Int(int(forColumnIndex: forColumn))
    }
}

extension BTAccountSession: BTServiceDBModel {
    public func tableName() -> String {
        return "BTAccountSession"
    }

    public func fieldDescs() -> [(field: String, fieldDesc: String)] {
        return [
            ("id", "INTEGER PRIMARY KEY AUTOINCREMENT"),
            ("accountId", "CHAR(24)"),
            ("session", "TEXT"),
            ("sessionToken", "TEXT"),
            ("status", "INTEGER"),
            ("token", "TEXT"),
            ("password", "TEXT"),
        ]
    }

    public func insertFieldsValues() -> [(field: String, value: Any)] {
        return [
            ("accountId", accountId),
            ("session", session),
            ("sessionToken", sessionToken),
            ("status", status),
            ("token", token),
            ("password", password),
        ]
    }

    public func modelFromResultSet(resultSet: FMResultSet) -> BTServiceDBModel {
        let res = BTAccountSession()
        res.accountId = resultSet.string(forColumn: "accountId")
        res.id = resultSet.integer(forColumn: "id")
        res.session = resultSet.string(forColumn: "session")
        res.sessionToken = resultSet.string(forColumn: "sessionToken")
        res.status = resultSet.integer(forColumn: "status")
        res.token = resultSet.string(forColumn: "token")
        res.password = resultSet.string(forColumn: "password")
        return res
    }
}

extension BTAccount: BTServiceDBModel {
    public func tableName() -> String { return "BTAccount" }

    public func fieldDescs() -> [(field: String, fieldDesc: String)] {
        return [
            ("accountId", "CHAR(24) PRIMARY KEY NOT NULL"),
            ("accountTypes", "TEXT"),
            ("email", "TEXT"),
            ("mobile", "TEXT"),
            ("nick", "TEXT"),
            ("signDateTs", "NUMERIC"),
            ("userName", "TEXT"),
        ]
    }

    public func insertFieldsValues() -> [(field: String, value: Any)] {
        return [
            ("accountId", accountId),
            ("accountTypes", accountTypes),
            ("email", email),
            ("mobile", mobile),
            ("nick", nick),
            ("signDateTs", signDateTs),
            ("userName", userName),
        ]
    }

    public func modelFromResultSet(resultSet: FMResultSet) -> BTServiceDBModel {
        let res = BTAccount()
        res.accountId = resultSet.string(forColumn: "accountId")
        res.accountTypes = resultSet.string(forColumn: "accountTypes")
        res.email = resultSet.string(forColumn: "email")
        res.mobile = resultSet.string(forColumn: "mobile")
        res.nick = resultSet.string(forColumn: "nick")
        res.signDateTs = resultSet.double(forColumn: "signDateTs")
        res.userName = resultSet.string(forColumn: "userName")
        return res
    }
}

extension BTMember: BTServiceDBModel {
    public func tableName() -> String { return "BTMember" }

    public func fieldDescs() -> [(field: String, fieldDesc: String)] {
        return [
            ("id", "INTEGER PRIMARY KEY AUTOINCREMENT"),
            ("accountId", "CHAR(24) NOT NULL"),
            ("memberType", "INTEGER"),
            ("expiredDateTs", "NUMERIC"),
        ]
    }

    public func insertFieldsValues() -> [(field: String, value: Any)] {
        return [
            ("id", id),
            ("accountId", accountId),
            ("memberType", memberType),
            ("expiredDateTs", expiredDateTs),
        ]
    }

    public func modelFromResultSet(resultSet: FMResultSet) -> BTServiceDBModel {
        let res = BTMember()
        res.id = resultSet.longLongInt(forColumn: "id")
        res.accountId = resultSet.string(forColumn: "accountId")
        res.expiredDateTs = resultSet.double(forColumn: "expiredDateTs")
        res.memberType = resultSet.integer(forColumn: "memberType")
        return res
    }
}


protocol BTServiceDBModel {
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
#endif
