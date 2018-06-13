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
        if !BTBaseSDK.isSDKInited {
            BTBaseSDK.start()
        }
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
        BTBaseSDK.openHome(self)
    }
}
