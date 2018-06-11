//
//  BTAPIRequest.swift
//  BTBaseSDK
//
//  Created by Alex Chow on 2018/6/4.
//  Copyright © 2018年 btbase. All rights reserved.
//

import Alamofire
import Foundation

extension Notification.Name {
    static let BTAPIRequestUnauthorized = Notification.Name(rawValue: "BTAPIRequestUnauthorized")
}

class BTAPIRequest<T> where T: Codable {
    typealias ResponseAction = (_ req: BTAPIRequest<T>, _ result: BTAPIResult<T>) -> Void
    internal(set) var headers = [String: String]()
    internal(set) var parameters = [String: String]()
    internal(set) var api = ""
    internal(set) var host = ""
    internal(set) var method = HTTPMethod.get

    var queue = DispatchQueue.utility

    var response: ResponseAction?

    private(set) var rawRequest: Request!

    var url: String { return host + api }

    public func useHeader(name: String, value: String) {
        headers[name] = value
    }

    public func useHeaders(headers: [String: String]) {
        for headerKV in headers {
            useHeader(name: headerKV.key, value: headerKV.value)
        }
    }

    public func addParameters(parameters: [String: String]) {
        for kv in parameters {
            addParameter(name: kv.key, value: kv.value)
        }
    }

    public func addParameter(name: String, value: String) {
        parameters[name] = value
    }

    @discardableResult
    public func request(profile: BTAPIClientProfile) -> BTAPIRequest<T> {
        useHeaders(headers: profile.defaultHeaders)
        host = profile.host.hasSuffix("/") ? profile.host : profile.host + "/"

        rawRequest = Alamofire.request(url, method: method, parameters: parameters, encoding: URLEncoding.default, headers: headers).validate(contentType: ["application/json"]).responseData(queue: queue, completionHandler: { response in
            if let statusCode = response.response?.statusCode, statusCode == 401 {
                let tobj = BTAPIResult<T>()
                tobj.code = 401
                tobj.error = BTAPIResultError()
                tobj.error.code = 401
                tobj.error.msg = "Unauthorized"
                tobj.msg = "Unauthorized"
                NotificationCenter.default.postWithMainQueue(name: Notification.Name.BTAPIRequestUnauthorized, object: self)
                self.response?(self, tobj)
            } else if let data = response.result.value, let tobj = try? JSONDecoder().decode(BTAPIResult<T>.self, from: data) {
                self.response?(self, tobj)
            } else if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                let tobj = BTAPIResult<T>()
                tobj.code = response.response?.statusCode ?? 555
                tobj.error = BTAPIResultError()
                tobj.error.code = tobj.code
                tobj.error.msg = "Unsupport Content"
                tobj.msg = utf8Text
                self.response?(self, tobj)
            } else {
                let tobj = BTAPIResult<T>()
                tobj.code = response.response?.statusCode ?? 556
                tobj.error = BTAPIResultError()
                tobj.error.code = tobj.code
                tobj.error.msg = "Network Error"
                tobj.msg = "Network Error"
                self.response?(self, tobj)
            }
        })
        return self
    }
}

public class EmptyContent: Codable {}
public class BTAPIRequestEmptyContent: BTAPIRequest<EmptyContent> {}
