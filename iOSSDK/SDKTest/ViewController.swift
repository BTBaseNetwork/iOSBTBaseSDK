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
    @IBOutlet var devButton: UIButton!
    @IBOutlet var productionButton: UIButton!

    @IBOutlet var homeButton: UIButton!

    @IBOutlet weak var accountButton: UIButton!
    @IBOutlet weak var memberButton: UIButton!
    @IBOutlet var badgeLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        homeButton.isHidden = true
        accountButton.isHidden = true
        memberButton.isHidden = true
    }

    @IBAction func onClickProduction(_ sender: Any) {
        let btbaseConfigFile = "btbase"
        if let filePath = Bundle.main.path(forResource: btbaseConfigFile, ofType: "plist"), let config = BTBaseConfig(filePath: filePath) {
            start(config: config, dev: false)
        }
    }

    @IBAction func onClickDev(_ sender: Any) {
        let btbaseConfigFile = "btbase_dev"
        if let filePath = Bundle.main.path(forResource: btbaseConfigFile, ofType: "plist"), let config = BTBaseConfig(filePath: filePath) {
            start(config: config, dev: true)
        }
    }

    func start(config: BTBaseConfig, dev: Bool) {
        BTBaseSDK.setupLoginedBanner()
        BTBaseSDK.start(config: config)
        BTBaseSDK.setupSDKUI()
        homeButton.isHidden = false
        accountButton.isHidden = false
        memberButton.isHidden = false
        devButton.isHidden = true
        productionButton.isHidden = true
        BTBaseSDK.fetchGameWallList(force: true)
        if #available(iOS 10.0, *) {
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                self.badgeLabel.text = "\(BTBaseSDK.badgeNumber)"
            }
        } else {
            // Fallback on earlier versions
        }
    }

    @IBAction func OnClickHome(_: Any) {
        BTBaseSDK.openHome(self)
        BTBaseSDK.clearBadgeNumber()
    }
    
    @IBAction func onClickMmeber(_ sender: Any) {
        BTBaseSDK.openHome(self, "member")
        BTBaseSDK.clearBadgeNumber()
    }
    
    @IBAction func onClickAccount(_ sender: Any) {
        BTBaseSDK.openHome(self, "account")
        BTBaseSDK.clearBadgeNumber()
    }
}
