//
//  BTGameWall.swift
//  iOSSDK
//
//  Created by Alex Chow on 2018/6/3.
//  Copyright © 2018年 btbase. All rights reserved.
//

import Alamofire
import Foundation

public class BTGameWall {
    public static let onGameWallListUpdated = Notification.Name("BTGameWall_onGameWallListUpdated")

    var configJsonUrl = "http://localhost/gamewall.json"

    static var cachedConfigJsonPathUrl: URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent("BTGameWallConfig.json")
        return fileURL
    }

    let destination: DownloadRequest.DownloadFileDestination = { _, _ in
        (cachedConfigJsonPathUrl, [.removePreviousFile, .createIntermediateDirectories])
    }

    private var cachedConfigModel: BTGameWallConfig? {
        didSet {
            NotificationCenter.default.post(name: BTGameWall.onGameWallListUpdated, object: self)
        }
    }

    var gameItemCount: Int { return cachedConfigModel?.items?.count ?? 0 }

    func getItem(index: Int) -> BTGameWallItem? {
        if let items = cachedConfigModel?.items {
            return items[index]
        }
        return nil
    }

    func refreshGameWallList() {
        Alamofire.download(configJsonUrl, to: destination).response { response in
            if response.error == nil, let _ = response.destinationURL?.path {
                self.loadCachedGamewallConfig()
            }
        }
    }

    func loadCachedGamewallConfig() {
        if let json = try? String(contentsOfFile: BTGameWall.cachedConfigJsonPathUrl.path), let data = json.data(using: String.Encoding.utf8) {
            if let configModel = try? JSONDecoder().decode(BTGameWallConfig.self, from: data) {
                cachedConfigModel = configModel
            }
        }
    }
}

extension BTServiceContainer {
    public static func useBTGameWall(configUrl: String) {
        let gameWall = BTGameWall()
        gameWall.configJsonUrl = configUrl
        addService(name: "BTGameWall", service: gameWall)
    }

    public static func getGameWall() -> BTGameWall? {
        return getService(name: "BTGameWall") as? BTGameWall
    }
}
