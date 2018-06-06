//
//  BTDBContext.swift
//  BTBaseSDK
//
//  Created by Alex Chow on 2018/6/6.
//  Copyright © 2018年 btbase. All rights reserved.
//

import Foundation
public protocol BTDBContext {
    func executeSql(sql: String)
    func beginTransaction()
    func commit()
    func open()
    func close()
}
