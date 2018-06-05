//
//  BTServiceDBManager.swift
//  iOSSDK
//
//  Created by Alex Chow on 2018/6/3.
//  Copyright © 2018年 btbase. All rights reserved.
//

import FMDB
import Foundation

public class BTServiceDBContext {
    public private(set) var database: FMDatabase!
    init(dbpath: String) {
        database = FMDatabase(path: dbpath)
    }
}
