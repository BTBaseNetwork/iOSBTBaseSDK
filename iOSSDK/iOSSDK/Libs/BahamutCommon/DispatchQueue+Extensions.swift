//
//  Dispatch+Extensions.swift
//  BTBaseSDK
//
//  Created by Alex Chow on 2018/6/7.
//  Copyright © 2018年 btbase. All rights reserved.
//

import Foundation
extension DispatchQueue {
    func afterMS(_ ms: UInt64, handler: @escaping () -> Void) {
        let time = DispatchTime.now() + Double(NSNumber(value: NSEC_PER_MSEC * ms as UInt64).int64Value) / Double(NSEC_PER_SEC)
        asyncAfter(deadline: time, execute: handler)
    }
    
    static var background: DispatchQueue {
        return DispatchQueue.global(qos: .background)
    }
    
    static var utility: DispatchQueue {
        return DispatchQueue.global(qos: .utility)
    }
    
    static var defaultQueue: DispatchQueue {
        return DispatchQueue.global(qos: .default)
    }
    
    static var userInitiated: DispatchQueue {
        return DispatchQueue.global(qos: .userInitiated)
    }
}
