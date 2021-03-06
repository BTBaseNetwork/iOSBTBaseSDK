//
//  BTBaseSDK+UI.swift
//  BTBaseSDK
//
//  Created by Alex Chow on 2018/6/11.
//  Copyright © 2018年 btbase. All rights reserved.
//

import Foundation
import UIKit

public extension BTBaseSDK {
    @objc public var GameServiceName: String { return "BTLocGameServiceName".localizedBTBaseString }
    
    @objc public static func setupLoginedBanner() {
        NotificationCenter.default.addObserver(self, selector: #selector(onLocalAccountUpdated(a:)), name: BTAccountService.onLocalAccountUpdated, object: nil)
    }
    
    @objc private static func onLocalAccountUpdated(a:Notification){
        let oldValue = a.userInfo?[NSKeyValueChangeKey.oldKey] as? BTAccount
        let newValue = a.userInfo?[NSKeyValueChangeKey.newKey] as? BTAccount
        
        if newValue != nil {
            if oldValue == nil || oldValue?.accountId != newValue?.accountId{
                _ = WelcomeToast.play()
            }
        }
    }

    @objc public static func setupSDKUI() {
        BahamutCommonLocalizedBundle = Bundle.iOSBTBaseSDKUI!
    }

    @objc public static func tryShowLoginWithSharedAuthenticationAlert(vc: UIViewController) {
        debugLog("tryShowLoginWithSharedAuthenticationAlert")
        if let auth = getAuthentication(), let _ = auth.accountId {
            debugLog("Quick Login Account Exists:", auth.accountId)
            easyQuickLogin(vc, auth)
            // askQuickLogin(vc: vc)
        } else {
            debugLog("No Quick Login Account")
        }
    }

    private static func easyQuickLogin(_ vc: UIViewController, _ auth: ClientSharedAuthentication) {
        BTServiceContainer.getBTSessionService()?.login(auth.accountId, auth.password, passwordSalted: true, autoFillPassword: false, respAction: { _, res in
            if res.isHttpOK {
                debugLog("Account:%@ Logined", auth.accountId)
            }
        })
    }

    private static func askQuickLogin(_ vc: UIViewController, _ auth: ClientSharedAuthentication) {
        let title = "BTLocTitleSharedAuthenticationExists".localizedBTBaseString
        let msg = String(format: "BTLocMsgSharedAuthenticationExists".localizedBTBaseString, auth.accountId)
        vc.showAlert(title, msg: msg, actions: [ALERT_ACTION_CANCEL, UIAlertAction(title: "BTLocQuickSignIn".localizedBTBaseString, style: .default, handler: { _ in
            BTServiceContainer.getBTSessionService()?.login(auth.accountId, auth.password, passwordSalted: true, autoFillPassword: false, respAction: { _, res in
                if res.isHttpOK {
                    openHome(vc)
                } else {
                    openHome(vc,page:nil, completion: { home in
                        home.showSignIn()
                    })
                }
            })
        })])
    }
    
    @objc public static func openHome(_ vc: UIViewController,_ page:String) {
        openHome(vc,page:page) { _ in }
    }

    @objc public static func openHome(_ vc: UIViewController) {
        openHome(vc,page:nil) { _ in }
    }

    private static func openHome(_ vc: UIViewController, page:String?, completion: @escaping (BTBaseHomeController) -> Void) {
        if let str = page,let p = BTBaseHomeEntry.HomePage(rawValue: str){
            BTBaseHomeEntry.openHome(vc, page: p, completion: completion)
        }else{
            BTBaseHomeEntry.openHome(vc, completion: completion)
        }
    }
}
