//
//  BTAPIResult.swift
//  BTBaseSDK
//
//  Created by Alex Chow on 2018/6/4.
//  Copyright © 2018年 btbase. All rights reserved.
//

import Foundation

class BTAPIResultError: Codable {
    public var code: Int = 0
    public var msg: String!
}

extension BTAPIResultError {
    public var msgWithoutSpaces: String {
        if let m = msg {
            return m.replacingOccurrences(of: " ", with: "")
        }
        return msg ?? "UnknowErr"
    }
}

class BTAPIResult<T>: Codable where T: Codable {
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
}

extension BTAPIResult {
    public var isHttpOK: Bool {
        return code == 200
    }
    
    public var isServerError: Bool {
        return code >= 500 && code <= 599
    }
    
    public var isHttpError: Bool {
        return code >= 400 && code <= 499
    }
    
    public var isHttpBadRequest: Bool {
        return code == 400
    }
    
    public var isHttpUnauthorized: Bool {
        return code == 401
    }
    
    public var isHttpPaymentRequired: Bool {
        return code == 402
    }
    
    public var isHttpForbidden: Bool {
        return code == 403
    }
    
    public var isHttpNotFound: Bool {
        return code == 404
    }
    
    public var isHttpMethodNotAllowed: Bool {
        return code == 405
    }
    
    public var isHttpNotAcceptable: Bool {
        return code == 406
    }
    
    public var isNetworkError: Bool {
        return code == 556 || msg == "Network Error"
    }
}
