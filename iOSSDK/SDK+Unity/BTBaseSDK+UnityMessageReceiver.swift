//
//  BTBaseSDK+UnityMessageReceiver.swift
//  BTBaseSDK
//
//  Created by Alex Chow on 2018/6/13.
//  Copyright © 2018年 btbase. All rights reserved.
//

import Foundation

// MARK: Message To UnityMessageReceiver

let UnityMessageReceiverNotificationName = Notification.Name("UnityMessageReceiverNotification")
let kUnityMessageReceiverMessageName = "kUnityMessageReceiverMessageName"
let kUnityMessageReceiverMessageUserInfo = "kUnityMessageReceiverMessageUserInfo"

public extension BTBaseSDK {
    @objc public static func sendMessageToUnityMessageReceiver(_ msgName: String, _ userInfo: NSDictionary?) {
        var info: [AnyHashable: Any] = [kUnityMessageReceiverMessageName: msgName]
        if let ui = userInfo {
            info[kUnityMessageReceiverMessageUserInfo] = ui
        }
        NotificationCenter.default.post(name: UnityMessageReceiverNotificationName, object: nil, userInfo: info)
    }
}

private var observers = [NSObjectProtocol]()
public extension BTBaseSDK {
    @objc public static func startListenBTBaseNotifications() {
        observers.append(NotificationCenter.default.addObserver(forName: BTSessionService.onSessionInvalid, object: nil, queue: nil, using: { (a) in
            //TODO:
        }))
        
        observers.append(NotificationCenter.default.addObserver(forName: BTSessionService.onSessionUpdated, object: nil, queue: nil, using: { (a) in
            //TODO:
        }))
        
        observers.append(NotificationCenter.default.addObserver(forName: Notification.Name.BTBaseHomeEntryDidShown, object: nil, queue: nil, using: { (a) in
            //TODO:
        }))
        
        observers.append(NotificationCenter.default.addObserver(forName: Notification.Name.BTBaseHomeEntryClosed, object: nil, queue: nil, using: { (a) in
            //TODO:
        }))
    }

    @objc public static func stopListenBTBaseNotifications() {
        for ob in observers {
            NotificationCenter.default.removeObserver(ob)
        }
    }
}
