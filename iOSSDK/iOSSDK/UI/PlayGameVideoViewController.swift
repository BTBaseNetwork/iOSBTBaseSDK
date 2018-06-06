//
//  PlayGameVideoViewController.swift
//  BTBaseSDK
//
//  Created by Alex Chow on 2018/6/7.
//  Copyright © 2018年 btbase. All rights reserved.
//

import Foundation
import UIKit

public class PlayGameVideoViewController:UIViewController
{
    @IBOutlet weak var closeButton: UIButton!
    @IBAction func onClickClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
