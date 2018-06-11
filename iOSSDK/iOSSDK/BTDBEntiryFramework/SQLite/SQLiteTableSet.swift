//
//  SQLiteTableSet.swift
//  BTBaseSDK
//
//  Created by Alex Chow on 2018/6/6.
//  Copyright © 2018年 btbase. All rights reserved.
//

import FMDB
import Foundation

public class SQLiteTableSet<T>: BTDBTableSet<T> where T: BTDBEntityModel {
    var database: FMDatabase! {
        return (dbContext as? SQLiteDbContext)?.database
    }
    
    private func getConstraints(property: BTDBEntity.PropertyBase) -> [String] {
        var strs = [String]()
        if property.isNotNull { strs.append("NOT NULL") }
        if property.primaryKey { strs.append("PRIMARY KEY") }
        if property.isUnique { strs.append("UNIQUE") }
        if property.isAutoIncrement { strs.append("AUTOINCREMENT") }
        return strs
    }
    
    private func getColumnType(property: BTDBEntity.PropertyBase) -> String {
        var propertyType = "BLOB"
        
        if let pt = swiftTypeToSqliteType[property.valueTypeName] {
            propertyType = pt
        }
        
        if propertyType == "TEXT" && property.length > 0 {
            return "CHAR(\(property.length))"
        }
        
        return propertyType
    }
    
    private func getColumnDesc(property: BTDBEntity.PropertyBase) -> String {
        return "\(getColumnType(property: property)) \(getConstraints(property: property).joined(separator: " "))"
    }
    
    public override func createTable() {
        let fields = entity.properties.map { p -> (String, String) in
            return (p.columnName, getColumnDesc(property: p))
        }
        if tableExists() {
            let sql = "PRAGMA  table_info(\(tableName))"
            if let result = try? database.executeQuery(sql, values: nil) {
                var columnNames = [String]()
                
                while result.next() {
                    if let name = result.string(forColumn: "name") {
                        columnNames.append(name)
                    }
                }
                
                var newFields = [(String, String)]()
                
                for field in fields {
                    if !columnNames.contains(field.0) {
                        newFields.append(field)
                    }
                }
                
                for (columnName, columnDesc) in newFields {
                    let addColumnSql = "ALTER TABLE \(tableName) ADD COLUMN \(columnName) \(columnDesc)"
                    database.executeStatements(addColumnSql)
                    debugLog("New Column(%@) Added To Table(%@)", columnName, tableName)
                }
            }
        } else {
            let sql = SQLiteHelper.createTableSql(tableName: entity.scheme, fields: fields)
            database.executeStatements(sql)
        }
    }
    
    public override func dropTable() {
        database.executeStatements("DROP TABLE \(entity.scheme)")
    }
    
    public override func tableExists() -> Bool {
        return database.tableExists(entity.scheme)
    }
    
    @discardableResult
    public override func query(sql: String, parameters: [Any]?) -> [T] {
        if let resultSet = try? database.executeQuery(sql, values: parameters) {
            var result = [T]()
            while resultSet.next() {
                let model = T.newDefaultModel() as! T
                for property: BTDBEntity.Property<T> in entity.getProperties() {
                    switch property.valueTypeName {
                    case "\(Int.self)": property.accessor?.setValue(model, resultSet.long(forColumn: property.columnName))
                    case "\(String.self)": property.accessor?.setValue(model, resultSet.string(forColumn: property.columnName))
                    case "\(Int32.self)": property.accessor?.setValue(model, resultSet.int(forColumn: property.columnName))
                    case "\(Int64.self)": property.accessor?.setValue(model, resultSet.longLongInt(forColumn: property.columnName))
                    case "\(Double.self)": property.accessor?.setValue(model, resultSet.double(forColumn: property.columnName))
                    case "\(Float.self)": property.accessor?.setValue(model, resultSet.double(forColumn: property.columnName))
                    case "\(Bool.self)": property.accessor?.setValue(model, resultSet.bool(forColumn: property.columnName))
                    case "\(Date.self)": property.accessor?.setValue(model, resultSet.date(forColumn: property.columnName))
                    case "\(uint.self)": property.accessor?.setValue(model, resultSet.unsignedLongLongInt(forColumn: property.columnName))
                    case "\(UInt64.self)": property.accessor?.setValue(model, resultSet.unsignedLongLongInt(forColumn: property.columnName))
                    case "\(UInt.self)": property.accessor?.setValue(model, resultSet.unsignedLongLongInt(forColumn: property.columnName))
                    case "\(Float32.self)": property.accessor?.setValue(model, resultSet.double(forColumn: property.columnName))
                    default: break
                    }
                    // property.accessor?.setValue(model, resultSet.object(forColumn: property.columnName))
                }
                result.append(model)
            }
            return result
        }
        return []
    }
    
    @discardableResult
    public override func add(model: T) -> T {
        let properties: [BTDBEntity.Property<T>] = entity.getProperties()
        
        let fields = properties.map { (name: $0.columnName, value: $0.accessor.getValue(model)) }.map { (name: $0.name, value: $0.value) }
        let sql = SQLiteHelper.insertSql(tableName: entity.scheme, fields: fields.map { $0.name })
        let parameters = fields.map { $0.value ?? "" }
        try? database.executeUpdate(sql, values: parameters)
        return model
    }
    
    @discardableResult
    public override func update(model: T, upsert: Bool) -> T {
        let priProperties: [BTDBEntity.Property<T>] = entity.getPrimaryKey()
        let priKvs = priProperties.map { (column: $0.columnName, value: $0.accessor.getValue(model)) }
        let queryFieldsSql = priKvs.map { $0.column }.map { "\($0)=?" }.joined(separator: " ")
        let querySql = SQLiteHelper.selectSql(tableName: entity.scheme, query: queryFieldsSql)
        let priValues = priKvs.map { $0.value! }
        if let _: T = query(sql: querySql, parameters: priValues).first {
            let notpriProperties: [BTDBEntity.Property<T>] = entity.getNotPrimaryKey()
            let notPriKvs = notpriProperties.map { (column: $0.columnName, value: $0.accessor.getValue(model)) }
            let sql = SQLiteHelper.updateSql(tableName: entity.scheme, fields: notPriKvs.map { $0.column }, query: queryFieldsSql)
            try? database.executeUpdate(sql, values: notPriKvs.map { $0.value } + priValues)
            return model
        } else if upsert {
            let m: T = add(model: model)
            return m
        }
        return model
    }
    
    @discardableResult
    public override func executeUpdateSql(sql: String, parameters: [Any]?) {
        try? database.executeUpdate(sql, values: parameters)
    }
    
    @discardableResult
    public override func delete(model: T) -> Bool {
        let priProperties: [BTDBEntity.Property<T>] = entity.getPrimaryKey()
        let priKvs = priProperties.map { (column: $0.columnName, value: $0.accessor.getValue(model)) }
        let queryFieldsSql = priKvs.map { $0.column }.map { "\($0)=?" }.joined(separator: " ")
        let priValues = priKvs.map { $0.value }
        let sql = SQLiteHelper.deleteSql(tableName: entity.scheme, query: queryFieldsSql)
        if (try? database.executeUpdate(sql, values: priValues)) != nil {
            return true
        }
        return false
    }
    
    @discardableResult
    public override func executeDeleteSql(sql: String, parameters: [Any]?) {
        try? database.executeUpdate(sql, values: parameters)
    }
}

private var swiftTypeToSqliteType: [String: String] = {
    var dict = [String: String]()
    dict["\(Int.self)"] = "INTEGER"
    dict["\(Int32.self)"] = "INTEGER"
    dict["\(Int64.self)"] = "INTEGER"
    dict["\(uint.self)"] = "INTEGER"
    dict["\(UInt64.self)"] = "INTEGER"
    dict["\(UInt.self)"] = "INTEGER"
    dict["\(Float.self)"] = "NUMERIC"
    dict["\(Float32.self)"] = "NUMERIC"
    dict["\(Double.self)"] = "NUMERIC"
    dict["\(Bool.self)"] = "NUMERIC"
    dict["\(String.self)"] = "TEXT"
    dict["\(Date.self)"] = "TEXT"
    return dict
}()
