//
//  BTBaseSDKManager+UI.swift
//  BTBaseSDK
//
//  Created by Alex Chow on 2018/6/11.
//  Copyright © 2018年 btbase. All rights reserved.
//

import Foundation
public extension BTBaseSDKManager {
    public var GameServiceName: String { return "BTLocGameServiceName".localizedBTBaseString }

    static func tryShowLoginWithSharedAuthenticationAlert(vc: UIViewController) {
        if let auth = getAuthentication() {
            let title = "BTLocTitleSharedAuthenticationExists".localizedBTBaseString
            let msg = "BTLocMsgSharedAuthenticationExists".localizedBTBaseString
            vc.showAlert(title, msg: msg, actions: [ALERT_ACTION_CANCEL, UIAlertAction(title: "BTLocSignIn".localizedBTBaseString, style: .default, handler: { _ in
                BTServiceContainer.getBTSessionService()?.login(auth.accountId, auth.saltedPassword, passwordSalted: true, autoFillPassword: false, respAction: { _, res in
                    if res.isHttpOK {
                    } else {
                    }
                })
            })])
        }
    }

    public static func openHome(_ vc: UIViewController, completion: (() -> Void)? = nil) {
        vc.present(BTBaseHomeEntry.getEntryViewController(), animated: true, completion: completion)
    }
}
