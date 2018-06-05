//
//  ViewController.swift
//  SDKTest
//
//  Created by Alex Chow on 2018/6/3.
//  Copyright © 2018年 btbase. All rights reserved.
//

import BTBaseSDK
import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        BTServiceContainer.useBTGameWall(configUrl: "https://raw.githubusercontent.com/BTAds/AdsAssets/master/BTGameWallConfig_01.json")
        BTServiceContainer.useBTMemberService(serverHost: "https://btbase.mobi/web/")
        BTServiceContainer.useBTAccountService(serverHost: "https://btbase.mobi/web/")
        BTServiceContainer.useBTSessionService(serverHost: "https://btbase.mobi/auth/")
    }

    var firstAppear = true
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if firstAppear {
            OnClickHome(self)
            firstAppear = false
        }
    }

    @IBAction func OnClickHome(_: Any) {
        present(BTBaseHomeEntry.getEntryViewController(), animated: true, completion: nil)
    }
}
