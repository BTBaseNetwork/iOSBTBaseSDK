//
//  UpdatePasswordViewController.swift
//  BTBaseSDK
//
//  Created by Alex Chow on 2018/6/4.
//  Copyright © 2018年 btbase. All rights reserved.
//

import UIKit

class UpdatePasswordViewController: UIViewController {
    @IBOutlet var curPasswordTextField: UITextField!

    @IBOutlet var newPasswordTextField: UITextField!

    @IBOutlet var curPasswordCheckImage: UIImageView!
    @IBOutlet var newPasswordCheckImage: UIImageView!
    @IBOutlet var updatePasswordButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        newPasswordCheckImage.isHidden = true
        newPasswordCheckImage.isHidden = true
        updatePasswordButton.isEnabled = false
    }

    @IBAction func onClickUpdatePassword(_: Any) {
        updatePasswordButton.isEnabled = false
        BTServiceContainer.getBTAccountService()?.updatePassword(currentPassword: curPasswordTextField.text!, newPassword: newPasswordTextField.text!, respAction: { _, result in
            if result.code == 200 {
                self.showAlert("BTLocTitleUpdatePswSuc".localizedBTBaseString, msg: nil, actions: [UIAlertAction(title: "BTLocOK".localizedBTBaseString, style: .default, handler: { _ in
                    self.navigationController?.popViewController(animated: true)
                })])
            } else {
                self.updatePasswordButton.isEnabled = true
                self.showAlert("BTLocTitleUpdatePswErr".localizedBTBaseString, msg: "BTLocMsg\(result.error.msgWithoutSpaces)".localizedBTBaseString)
            }
        })
    }

    @IBAction func onTextFieldEditingChanged(_ sender: Any) {
        if let textField = sender as? UITextField {
            if textField == curPasswordTextField {
                curPasswordCheckImage.isHidden = !String.regexTestStringWithPattern(value: textField.text, pattern: CommonRegexPatterns.PATTERN_PASSWORD)
            } else if textField == newPasswordTextField {
                newPasswordCheckImage.isHidden = !String.regexTestStringWithPattern(value: textField.text, pattern: CommonRegexPatterns.PATTERN_PASSWORD)
            }
            updatePasswordButton.isEnabled = !newPasswordCheckImage.isHidden && !curPasswordCheckImage.isHidden
        }
    }

    @IBAction func onTextFieldEditingDidBegin(_: Any) {
    }

    @IBAction func onTextFieldEditingDidEnd(_: Any) {
    }
}
