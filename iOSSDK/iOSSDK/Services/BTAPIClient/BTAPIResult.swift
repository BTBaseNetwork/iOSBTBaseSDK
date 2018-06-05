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

public class BTAPIResult<T>: Codable where T: Codable {
    public var code: Int = 0
    public var msg: String!
    public var content: T!
    public var error: BTAPIResultError!
    public var msgWithoutSpaces: String! {
        if let m = msg {
            return m.replacingOccurrences(of: " ", with: "")
        }
        return msg
    }

    public var isHttpOK: Bool {
        return code == 200
    }
    
    public var isHttpServerError:Bool{
        return code >= 500 && code <= 599
    }
    
    public var isNetworkError:Bool{
        return false
    }
}
