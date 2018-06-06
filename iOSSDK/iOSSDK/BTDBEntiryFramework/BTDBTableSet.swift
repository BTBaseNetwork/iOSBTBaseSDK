//
//  BTDBDbSet.swift
//  BTBaseSDK
//
//  Created by Alex Chow on 2018/6/6.
//  Copyright © 2018年 btbase. All rights reserved.
//

import Foundation
public class BTDBTableSet<M> where M: BTDBEntityModel {
    private(set) var dbContext: BTDBContext
    private(set) var entity: BTDBEntity
    
    init(dbContext: BTDBContext, scheme: String) {
        self.dbContext = dbContext
        self.entity = BTDBEntity.Builder(scheme: scheme).build(M.self)
    }
    
    public func createTable() {}
    public func tableExists() -> Bool { return false }
    
    public func dropTable() {}
    @discardableResult
    public func add(model: M) -> M { return model }
    @discardableResult
    public func query(sql: String, parameters: [Any]?) -> [M] { return [] }
    @discardableResult
    public func update(model: M, upsert: Bool) -> M { return model }
    @discardableResult
    public func delete(model: M) -> Bool { return false }
}
