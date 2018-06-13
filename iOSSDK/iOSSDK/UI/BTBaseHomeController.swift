//
//  BTBaseHomeController.swift
//  BTBaseSDK
//
//  Created by Alex Chow on 2018/6/3.
//  Copyright © 2018年 btbase. All rights reserved.
//

import UIKit
let kDidSelectViewController = "kDidSelectVievController"

class BTBaseHomeController: UITabBarController, UITabBarControllerDelegate {
    static let DidSelectViewController = Notification.Name("BTBaseHomeController_DidSelectViewController")
    override func viewDidLoad() {
        super.viewDidLoad()
        SetupBTBaseUI()
        delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(onSessionUpdated(a:)), name: BTSessionService.onSessionUpdated, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        super.viewWillDisappear(animated)
    }

    @objc private func onSessionUpdated(a _: Notification) {
        if !BTServiceContainer.getBTSessionService()!.isSessionLogined {
            selectedIndex = 0
        }
    }

    func tabBarController(_: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController.restorationIdentifier == "AccountNavigationController" {
            if let sessionService = BTServiceContainer.getBTSessionService() {
                if sessionService.isSessionLogined {
                    return true
                }
            }
            showSignIn()
            return false
        }
        return true
    }

    func showSignIn() {
        if let sessionService = BTServiceContainer.getBTSessionService() {
            if !sessionService.isSessionLogined {
                performSegue(withIdentifier: "SignIn", sender: nil)
            }
        }
    }

    func tabBarController(_: UITabBarController, didSelect viewController: UIViewController) {
        NotificationCenter.default.post(name: BTBaseHomeController.DidSelectViewController, object: viewController, userInfo: [kDidSelectViewController: viewController])
    }

    @IBAction func OnClickClose(_: Any) {
        navigationController?.dismiss(animated: true, completion: nil)
    }

    deinit {
        debugLog("Deinited:\(self.description)")
    }
}

import IQKeyboardManagerSwift

extension Notification.Name {
    static let BTBaseHomeEntryClosed = Notification.Name("BTBaseHomeEntryClosed")
    static let BTBaseHomeEntryDidShown = Notification.Name("BTBaseHomeEntryDidShown")
}

class BTBaseHomeEntry {
    private static var homeController: BTBaseHomeController?
    private static var IQKeyboardManagerEnabledOutOfSDK = false
    static func getEntryViewController() -> BTBaseHomeController {
        if homeController != nil {
            return homeController!
        }
        let board = UIStoryboard(name: "BTBaseMainStoryboard", bundle: Bundle.iOSBTBaseSDKUI)
        BahamutCommonLocalizedBundle = Bundle.iOSBTBaseSDKUI!
        BTBaseHomeEntry.IQKeyboardManagerEnabledOutOfSDK = IQKeyboardManager.shared.enable
        IQKeyboardManager.shared.enable = true
        homeController = board.instantiateViewController(withIdentifier: "BTBaseHomeController") as? BTBaseHomeController
        return homeController!
    }

    static func openHome(_ vc: UIViewController, completion: @escaping (BTBaseHomeController) -> Void) {
        let homeVC = BTBaseHomeEntry.getEntryViewController()
        vc.present(homeVC, animated: true) {
            completion(homeVC)
            NotificationCenter.default.post(Notification(name: .BTBaseHomeEntryDidShown))
        }
    }

    static func closeHomeController() {
        homeController?.dismiss(animated: true) {
            IQKeyboardManager.shared.enable = IQKeyboardManagerEnabledOutOfSDK
            homeController = nil
            NotificationCenter.default.post(Notification(name: .BTBaseHomeEntryClosed))
        }
    }
}
