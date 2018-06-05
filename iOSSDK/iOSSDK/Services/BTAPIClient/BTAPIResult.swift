//
//  BTAPIResult.swift
//  BTBaseSDK
//
//  Created by Alex Chow on 2018/6/4.
//  Copyright © 2018年 btbase. All rights reserved.
//

import Foundation

public class BTAPIResultError: Codable {
    public var code: Int = 0
    public var msg: String!
    public var msgWithoutSpaces: String! {
        if let m = msg {
            return m.replacingOccurrences(of: " ", with: "")
        }
        return msg
    }
}

public class BTAPIResult<T>: BTAPIResultBase where T: Codable {
    public var content: T!
}

public class BTAPIResultBase: Codable {
    public var code: Int = 0
    public var msg: String!
    public var error: BTAPIResultError!
    public var msgWithoutSpaces: String! {
        if let m = msg {
            return m.replacingOccurrences(of: " ", with: "")
        }
        return msg
    }
}
