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

    override func viewDidLoad() {
        super.viewDidLoad()
        homeButton.isHidden = true
    }

    @IBAction func onClickProduction(_ sender: Any) {
        let btbaseConfigFile = "btbase"
        if let filePath = Bundle.main.path(forResource: btbaseConfigFile, ofType: "plist"), let config = BTBaseConfig(filePath: filePath) {
            BTBaseSDK.start(config: config)
            BTBaseSDK.setupSDKUI()
            homeButton.isHidden = false
            devButton.isHidden = true
            productionButton.isEnabled = false
        }
    }

    @IBAction func onClickDev(_ sender: Any) {
        let btbaseConfigFile = "btbase_dev"
        if let filePath = Bundle.main.path(forResource: btbaseConfigFile, ofType: "plist"), let config = BTBaseConfig(filePath: filePath) {
            BTBaseSDK.start(config: config)
            BTBaseSDK.setupSDKUI()
            homeButton.isHidden = false
            devButton.isEnabled = false
            productionButton.isHidden = true
        }
    }

    @IBAction func OnClickHome(_: Any) {
        BTBaseSDK.openHome(self)
    }
}
