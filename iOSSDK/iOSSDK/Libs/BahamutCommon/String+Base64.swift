//
//  String+Base64.swift
//  BTBaseSDK
//
//  Created by Alex Chow on 2018/6/20.
//  Copyright © 2018年 btbase. All rights reserved.
//

import Foundation
extension String {
    var base64String: String? {
        return self.data(using: .utf8)?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
    }

    var valueOfBase64String: String? {
        if let data = Data(base64Encoded: self) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
}
