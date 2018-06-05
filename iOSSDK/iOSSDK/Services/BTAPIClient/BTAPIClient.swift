//
//  BTAPIClient.swift
//  iOSSDK
//
//  Created by Alex Chow on 2018/6/3.
//  Copyright © 2018年 btbase. All rights reserved.
//

import Alamofire
import Foundation

public class BTAPIClientProfile {
    var host = "http://localhost/"
    var defaultHeaders = [String: String]()

    init(host: String) {
        self.host = host
    }

    public func useHeader(_ name: String, _ value: String) {
        defaultHeaders[name] = value
    }
}
