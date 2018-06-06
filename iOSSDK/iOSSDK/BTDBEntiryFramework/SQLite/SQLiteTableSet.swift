//
//  SQLiteTableSet.swift
//  BTBaseSDK
//
//  Created by Alex Chow on 2018/6/6.
//  Copyright © 2018年 btbase. All rights reserved.
//

import Foundation
import FMDB
public class SQLiteTableSet<T>: BTDBTableSet<T> where T: BTDBEntityModel {
    
    var database:FMDatabase!{
        return (dbContext as? SQLiteDbContext)?.database
    }
    
    
    public override func createTable() {
        let fields = entity.properties.map { p -> (String, String) in
            let pt = p as! SQLiteEntityProperty
            return (pt.columnName, pt.columnDesc)
        }
        let sql = SQLiteHelper.createTableSql(tableName: entity.scheme, fields: fields)
        database.executeStatements(sql)
    }

    public override func dropTable() {
        database.executeStatements("DROP TABLE \(entity.scheme)")
    }

    public override func tableExists() -> Bool {
        return database.tableExists(entity.scheme)
    }

    public override func query(sql: String, parameters: [Any]?) -> [T] {
        if let resultSet = try? database.executeQuery(sql, values: parameters) {
            var result = [T]()
            while resultSet.next() {
                let model = T.newDefaultModel() as! T
                for property in entity.properties {
                    property.setter(model, resultSet.value(forKey: property.columnName))
                }
                result.append(model)
            }
        }
        return []
    }

    public override func add(model: T) -> T {
        let fields = entity.properties.map { (name: $0.columnName, value: $0.getter(model)) }
        let sql = SQLiteHelper.insertSql(tableName: entity.scheme, fields: fields.map { $0.name })
        try? database.executeUpdate(sql, values: fields.map { $0.value })
        return model
    }

    public override func update(model: T, upsert: Bool) -> T {
        let priKvs = entity.primaryKeys.map { (column: $0.columnName, value: $0.getter(model)) }
        let querySql = SQLiteHelper.selectSql(tableName: entity.scheme, query: priKvs.map { $0.column }.map { "\($0)=?" }.joined(separator: " "))
        let priValues = priKvs.map { $0.value }
        if let _: T = query(sql: querySql, parameters: priValues).first {
            let notPriKvs = entity.notPrimaryKeys.map { (column: $0.columnName, value: $0.getter(model)) }
            let sql = SQLiteHelper.updateSql(tableName: entity.scheme, fields: notPriKvs.map { $0.column }, query: querySql)
            try? database.executeUpdate(sql, values: notPriKvs.map { $0.value } + priValues)
            return model
        } else if upsert {
            let m: T = add(model: model)
            return m
        }
        return model
    }

    public override func delete(model: T) -> Bool {
        let priKvs = entity.primaryKeys.map { (column: $0.columnName, value: $0.getter(model)) }
        let querySql = SQLiteHelper.selectSql(tableName: entity.scheme, query: priKvs.map { $0.column }.map { "\($0)=?" }.joined(separator: " "))
        let priValues = priKvs.map { $0.value }
        let sql = SQLiteHelper.deleteSql(tableName: entity.scheme, query: querySql)
        if (try? database.executeUpdate(sql, values: priValues)) != nil {
            return true
        }
        return false
    }
}
