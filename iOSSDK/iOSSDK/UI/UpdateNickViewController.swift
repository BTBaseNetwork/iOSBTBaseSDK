//
//  UpdateNickViewController.swift
//  BTBaseSDK
//
//  Created by Alex Chow on 2018/6/4.
//  Copyright © 2018年 btbase. All rights reserved.
//

import UIKit

class UpdateNickViewController: UIViewController {
    @IBOutlet var updateNickButton: UIButton! { didSet { updateNickButton.SetupBTBaseUI() } }
    @IBOutlet var newNickTextField: UITextField!

    @IBOutlet var newNickCheckImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        for textField in [newNickTextField] {
            textField?.addTarget(self, action: #selector(onTextFieldEditingDidBegin(sender:)), for: UIControlEvents.editingDidBegin)
            textField?.addTarget(self, action: #selector(onTextFieldEditingChanged(sender:)), for: UIControlEvents.editingChanged)
            textField?.addTarget(self, action: #selector(onTextFieldEditingDidEnd(sender:)), for: UIControlEvents.editingDidEnd)
        }
        newNickCheckImage.isHidden = true
        updateNickButton.isEnabled = false
        newNickTextField.isEnabled = true
    }

    @IBAction func onClickUpdateNick(_: Any) {
        updateNickButton.isEnabled = false
        newNickTextField.isEnabled = false
        BTServiceContainer.getBTAccountService()?.updateNick(newNick: newNickTextField.text!, respAction: { _, result in
            if result.isHttpOK {
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

    @objc private func onTextFieldEditingChanged(sender: Any) {
        if String.isNullOrWhiteSpace(newNickTextField.text) {
            newNickCheckImage.isHidden = true
            updateNickButton.isEnabled = false
        } else {
            newNickCheckImage.isHidden = false
            updateNickButton.isEnabled = true
        }
    }

    @objc private func onTextFieldEditingDidBegin(sender: Any) {
    }

    @objc private func onTextFieldEditingDidEnd(sender: Any) {
    }
}
