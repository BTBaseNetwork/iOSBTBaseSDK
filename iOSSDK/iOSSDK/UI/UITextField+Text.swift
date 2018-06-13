//
//  UITextField+Text.swift
//  BTBaseSDK
//
//  Created by Alex Chow on 2018/6/9.
//  Copyright © 2018年 btbase. All rights reserved.
//

import Foundation
import UIKit
extension UITextField{
    var trimText:String?{
        return self.text?.trim()
    }
}
