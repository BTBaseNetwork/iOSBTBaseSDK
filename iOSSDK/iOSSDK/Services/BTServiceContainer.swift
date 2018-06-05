//
//  BTServiceContainer.swift
//  BTBaseSDK
//
//  Created by Alex Chow on 2018/6/4.
//  Copyright © 2018年 btbase. All rights reserved.
//

import Foundation
public class BTServiceContainer {
    private static var services = [String: Any]()

    public static func addService(name: String, service: Any) {
        services[name] = service
    }

    public static func getService(name: String) -> Any? {
        if services.keys.contains(name) {
            return services[name]
        } else {
            return nil
        }
    }
}
