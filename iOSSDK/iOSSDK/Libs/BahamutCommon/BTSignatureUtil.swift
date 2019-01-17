//
//  BTSignatureUtil.swift
//  BTBaseSDK
//
//  Created by Alex Chow on 2019/1/17.
//  Copyright © 2019 btbase. All rights reserved.
//

import Foundation
class BTSignatureUtil {
    public static func generateBTSignature(parameters:[String]) -> String{
        return parameters.joined(separator: "").md5
    }
}

extension Array{
    func generateBTSignature() -> String {
        return BTSignatureUtil.generateBTSignature(parameters: self.map{"\($0)"})
    }
}
