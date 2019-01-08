//
//  BTBaseHomeController.swift
//  BTBaseSDK
//
//  Created by Alex Chow on 2018/6/3.
//  Copyright © 2018年 btbase. All rights reserved.
//

import UIKit
let kDidSelectViewController = "kDidSelectVievController"
let kLastSelectViewController = "kLastSelectViewController"
let kLastClickTabBarItemDate = "kLastClickTabBarItemDate"

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

    private var lastSelectedViewController: UIViewController?
    private var lastClickTabbarDate = Date()
    func tabBarController(_: UITabBarController, didSelect viewController: UIViewController) {
        var uinfo:[String : Any] = [kDidSelectViewController: viewController,kLastClickTabBarItemDate:lastClickTabbarDate]
        if let lvc = lastSelectedViewController {
            uinfo[kLastSelectViewController] = lvc
        }
        lastClickTabbarDate = Date()
        lastSelectedViewController = viewController
        NotificationCenter.default.post(name: BTBaseHomeController.DidSelectViewController, object: viewController, userInfo: uinfo)
    }

    @IBAction func OnClickClose(_: Any) {
        navigationController?.dismiss(animated: true, completion: nil)
    }

    deinit {
        debugLog("Deinited:\(self.description)")
    }
}

extension Notification.Name {
    static let BTBaseHomeEntryClosed = Notification.Name("BTBaseHomeEntryClosed")
    static let BTBaseHomeEntryDidShown = Notification.Name("BTBaseHomeEntryDidShown")
}

class BTBaseHomeEntry {
    
    enum HomePage:String {
        case gameWall = "gamewall"
        case member = "member"
        case account = "account"
    }
    
    private static var homeController: BTBaseHomeController?
    private static var IQKeyboardManagerEnabledOutOfSDK = false
    static func getEntryViewController() -> BTBaseHomeController {
        if homeController != nil {
            return homeController!
        }
        let board = UIStoryboard(name: "BTBaseMainStoryboard", bundle: Bundle.iOSBTBaseSDKUI)
        BTBaseHomeEntry.IQKeyboardManagerEnabledOutOfSDK = IQKeyboardManager.shared.enable
        IQKeyboardManager.shared.enable = true
        homeController = board.instantiateViewController(withIdentifier: "BTBaseHomeController") as? BTBaseHomeController
        return homeController!
    }
    
    static func openHome(_ vc: UIViewController, completion: @escaping (BTBaseHomeController) -> Void) {
        openHome(vc, page: .gameWall, completion: completion)
    }

    static func openHome(_ vc: UIViewController, page:HomePage, completion: @escaping (BTBaseHomeController) -> Void) {
        let homeVC = BTBaseHomeEntry.getEntryViewController()
        vc.present(homeVC, animated: true) {
            completion(homeVC)
            NotificationCenter.default.post(Notification(name: .BTBaseHomeEntryDidShown))
            switch page{
            case .account:
                if let sessionService = BTServiceContainer.getBTSessionService(),sessionService.isSessionLogined {
                    homeVC.selectedIndex = 2
                }else{
                    homeVC.showSignIn()
                }
            case .member:homeVC.selectedIndex = 1
            case .gameWall:homeVC.selectedIndex = 0
            }
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
