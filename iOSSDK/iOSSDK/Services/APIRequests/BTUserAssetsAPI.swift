//
//  BTUserAssetsAPI.swift
//  BTBaseSDK
//
//  Created by Alex Chow on 2019/1/17.
//  Copyright © 2019 btbase. All rights reserved.
//

import Foundation
class GetBTUserAssetsResult: Codable {
    public var count: Int = 0
    public var assets: [BTUserAssets]!
}


class GetUserAssetsRequest: BTAPIRequest<GetBTUserAssetsResult> {
    override init() {
        super.init()
        api = "api/v1/UserAssets"
    }
}

class GetUserAssetsBycategoryRequest: BTAPIRequest<GetBTUserAssetsResult> {
    override init() {
        super.init()
    }
    
    var category:String!{
        didSet{
            api = "api/v1/UserAssets/category/\(category!)"
        }
    }
    
}

class GetUserAssetsByAssetsIdRequest: BTAPIRequest<GetBTUserAssetsResult> {
    override init() {
        super.init()
    }
    
    var assetsId:String!{
        didSet{
            api = "api/v1/UserAssets/Id/\(assetsId!)"
        }
    }
}

class AddUserAssetsRequest: BTAPIRequest<BTUserAssets> {
    override init() {
        super.init()
        self.method = .post
    }
    
    var assetsId:String!{
        didSet{
            api = "api/v1/UserAssets/\(assetsId!)"
        }
    }
    
    var assets:String!{
        didSet{
            addParameter(name: "assets", value: assets)
        }
    }
    
    var category:String!{
        didSet{
            addParameter(name: "category", value: category)
        }
    }
    
    var amount:Int = 1{
        didSet{
            addParameter(name: "amount", value: "\(amount)")
        }
    }
    
    func addSignature() {
        if let token = BTServiceContainer.getBTSessionService()?.localSession.session{
            if let accountId = BTServiceContainer.getBTSessionService()?.localSession.accountId{
                let bundleId = BTServiceInfo.BundleId
                let ts = Int64(DateHelper.unixTimeSpan)
                let key = "\(bundleId):\(ts):\(accountId):\(token)".md5
                let signature = [key,assetsId!,assets!,category!,amount].generateBTSignature()
                addParameter(name: "ts", value: "\(ts)")
                addParameter(name: "signature", value: signature)
            }
        }
    }
}

class UpdateUserAssetsRequest: AddUserAssetsRequest {
    override init() {
        super.init()
        self.method = .post
    }
    
    var id:Int64 = 0{
        didSet{
            api = "api/v1/UserAssets/Updates/\(id)"
        }
    }
    
    override var assetsId:String!{
        didSet{
            addParameter(name: "assetsId", value: assetsId)
            api = "api/v1/UserAssets/Updates/\(id)"
        }
    }
    
    override func addSignature() {
        if let token = BTServiceContainer.getBTSessionService()?.localSession.session{
            if let accountId = BTServiceContainer.getBTSessionService()?.localSession.accountId{
                let bundleId = BTServiceInfo.BundleId
                let ts = Int64(DateHelper.unixTimeSpan)
                let key = "\(bundleId):\(ts):\(accountId):\(token)".md5
                let signature = [key,id,assetsId!,assets!,category!,amount].generateBTSignature()
                addParameter(name: "ts", value: "\(ts)")
                addParameter(name: "signature", value: signature)
            }
        }
    }
}
