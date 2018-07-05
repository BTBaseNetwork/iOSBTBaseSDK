//
//  BTGameWall.swift
//  iOSSDK
//
//  Created by Alex Chow on 2018/6/3.
//  Copyright © 2018年 btbase. All rights reserved.
//
import Foundation

class BTGameWall {
    public static let onGameWallListUpdated = Notification.Name("BTGameWall_onGameWallListUpdated")

    fileprivate var configJsonUrl = "http://localhost/gamewall.json"
    fileprivate var config: BTBaseConfig!
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
            NotificationCenter.default.postWithMainQueue(name: BTGameWall.onGameWallListUpdated, object: self)
        }
    }

    var gameItemCount: Int { return self.cachedConfigModel?.items?.count ?? 0 }

    func getItem(index: Int) -> BTGameWallItem? {
        if let items = cachedConfigModel?.items {
            return items[index]
        }
        return nil
    }

    func getSortedItemsByPriority() -> [BTGameWallItem] {
        if let items = cachedConfigModel?.items {
            return items.sorted(by: { (a, b) -> Bool in
                a.priority >= b.priority
            })
        }
        return []
    }

    func refreshGameWallList(force: Bool, completion: (() -> Void)? = nil) {
        if !force, let attrs = try? FileManager.default.attributesOfItem(atPath: BTGameWall.cachedConfigJsonPathUrl.path) {
            let date = (attrs[FileAttributeKey.modificationDate]) ?? (attrs[FileAttributeKey.creationDate])
            if let d = date as? Date {
                if d.addDays(1).timeIntervalSince1970 > Date().timeIntervalSince1970 {
                    completion?()
                    return
                }
            }
        }

        download(self.configJsonUrl, to: self.destination).response { response in
            if response.error == nil, let _ = response.destinationURL?.path {
                self.loadCachedGamewallConfig()
            }
            completion?()
        }
    }

    func loadCachedGamewallConfig() {
        if let json = try? String(contentsOfFile: BTGameWall.cachedConfigJsonPathUrl.path), let data = json.data(using: String.Encoding.utf8) {
            if let configModel = try? JSONDecoder().decode(BTGameWallConfig.self, from: data) {
                self.cachedConfigModel = configModel
            }
        }
    }
}

extension BTServiceContainer {
    public static func useBTGameWall(_ config: BTBaseConfig) {
        let gameWall = BTGameWall()
        gameWall.config = config
        gameWall.configJsonUrl = config.getString(key: "BTGameWallConfigUrl")!
        addService(name: "BTGameWall", service: gameWall)
    }

    public static func getGameWall() -> BTGameWall? {
        return getService(name: "BTGameWall") as? BTGameWall
    }
}
