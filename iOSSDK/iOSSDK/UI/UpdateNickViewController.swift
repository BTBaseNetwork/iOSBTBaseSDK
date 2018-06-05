//
//  UpdateNickViewController.swift
//  BTBaseSDK
//
//  Created by Alex Chow on 2018/6/4.
//  Copyright © 2018年 btbase. All rights reserved.
//

import UIKit

class UpdateNickViewController: UIViewController {
    @IBOutlet var updateNickButton: UIButton!
    @IBOutlet var newNickTextField: UITextField!

    @IBOutlet var newNickCheckImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        newNickCheckImage.isHidden = true
        updateNickButton.isEnabled = false
        newNickTextField.isEnabled = true
    }

    @IBAction func onClickUpdateNick(_: Any) {
        updateNickButton.isEnabled = false
        newNickTextField.isEnabled = false
        BTServiceContainer.getBTAccountService()?.updateNick(newNick: newNickTextField.text!, respAction: { _, result in
            if result.code == 200 {
                self.showAlert("BTLocTitleUpdateNickSuc".localizedBTBaseString, msg: nil, actions: [UIAlertAction(title: "BTLocOK".localizedBTBaseString, style: .default, handler: { _ in
                    self.navigationController?.popViewController(animated: true)
                })])
            } else {
                self.newNickTextField.isEnabled = true
                self.updateNickButton.isEnabled = true
                self.showAlert("BTLocTitleUpdateNickErr".localizedBTBaseString, msg: "BTLocMsg\(result.error.msgWithoutSpaces)".localizedBTBaseString)
            }
        })
    }

    @IBAction func onTextFieldEditingChanged(_: Any) {
        if String.isNullOrWhiteSpace(newNickTextField.text) {
            newNickCheckImage.isHidden = true
            updateNickButton.isEnabled = false
        } else {
            newNickCheckImage.isHidden = false
            updateNickButton.isEnabled = true
        }
    }

    @IBAction func onTextFieldEditingDidBegin(_: Any) {
    }

    @IBAction func onTextFieldEditingDidEnd(_: Any) {
    }
}
