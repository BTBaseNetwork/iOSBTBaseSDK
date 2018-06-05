//
//  Model+FMDB.swift
//  BTBaseSDK
//
//  Created by Alex Chow on 2018/6/5.
//  Copyright © 2018年 btbase. All rights reserved.
//

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

extension BTAccountSession {
    static func parse(resultSet: FMResultSet) -> BTAccountSession {
        var res = BTAccountSession()
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

extension BTAccount {
    static func parse(resultSet: FMResultSet) -> BTAccount {
        let res = BTAccount()
        res.accountId = resultSet.string(forColumn: "accountId")
        res.accountTypes = resultSet.string(forColumn: "accountTypes")
        res.email = resultSet.string(forColumn: "email")
        res.mobile = resultSet.string(forColumn: "mobile")
        res.nick = resultSet.string(forColumn: "nick")
        res.signDateTs = resultSet.longLongInt(forColumn: "signDateTs")
        res.userName = resultSet.string(forColumn: "userName")
        return res
    }
}

extension BTMember {
    static func parse(resultSet: FMResultSet) -> BTMember {
        let res = BTMember()
        res.id = resultSet.longLongInt(forColumn: "id")
        res.accountId = resultSet.string(forColumn: "accountId")
        res.expiredDateTs = resultSet.double(forColumn: "expiredDateTs")
        res.memberType = resultSet.integer(forColumn: "memberType")
        return res
    }
}

class SQLiteHelper {
    static func createTableSql(tableName: String, fields: [String: String]) -> String {
        return "CREATE TABLE IF NOT EXISTS \(tableName)(\(fields.map { "\($0.key) \($0.value)" }.joined(separator: ","))"
    }

    static func insertSql(tableName: String, fields: [String]) -> String {
        return "INSERT INTO \(tableName)(\(fields.joined(separator: ",")) VALUES(\(fields.map { _ in "?" }.joined(separator: ","))"
    }

    static func deleteSql(tableName: String, query: String) -> String {
        return "DELETE FROM \(tableName) WHERE \(query)"
    }

    static func selectSql(tableName: String, query: String) -> String {
        return "SELECT * FROM \(tableName) WHERE \(query)"
    }

    static func updateSql(tableName: String, fields: [String], query: String) -> String {
        return "UPDATE \(tableName) SET \(fields.map { "\($0)=?" }.joined(separator: ",")) WHERE \(query)"
    }
}
