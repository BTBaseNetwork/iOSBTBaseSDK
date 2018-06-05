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
            ("accountTypes", accountId),
            ("email", accountId),
            ("mobile", accountId),
            ("nick", accountId),
            ("signDateTs", accountId),
            ("userName", accountId),
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
