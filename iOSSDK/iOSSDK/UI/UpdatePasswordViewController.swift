//
//  UpdatePasswordViewController.swift
//  BTBaseSDK
//
//  Created by Alex Chow on 2018/6/4.
//  Copyright © 2018年 btbase. All rights reserved.
//

import UIKit

class UpdatePasswordViewController: UIViewController {
    @IBOutlet var curPasswordTextField: UITextField! { didSet { curPasswordTextField.SetupBTBaseUI() } }

    @IBOutlet var newPasswordTextField: UITextField! { didSet { newPasswordTextField.SetupBTBaseUI() } }

    @IBOutlet var curPasswordCheckImage: UIImageView!
    @IBOutlet var newPasswordCheckImage: UIImageView!
    @IBOutlet var updatePasswordButton: UIButton! { didSet { updatePasswordButton.SetupBTBaseUI() } }

    override func viewDidLoad() {
        super.viewDidLoad()
        SetupBTBaseUI()
        for textField in [curPasswordTextField, newPasswordTextField] {
            textField?.addTarget(self, action: #selector(onTextFieldEditingDidBegin(sender:)), for: UIControlEvents.editingDidBegin)
            textField?.addTarget(self, action: #selector(onTextFieldEditingChanged(sender:)), for: UIControlEvents.editingChanged)
            textField?.addTarget(self, action: #selector(onTextFieldEditingDidEnd(sender:)), for: UIControlEvents.editingDidEnd)
        }
        curPasswordCheckImage.isHidden = true
        newPasswordCheckImage.isHidden = true
        curPasswordCheckImage.tintColor = BTBaseUIConfig.GlobalTintColor
        newPasswordCheckImage.tintColor = BTBaseUIConfig.GlobalTintColor
        updatePasswordButton.isEnabled = false
        curPasswordTextField.isEnabled = true
        newPasswordTextField.isEnabled = false
    }

    @IBAction func onClickUpdatePassword(_: Any) {
        updatePasswordButton.isEnabled = false
        BTServiceContainer.getBTAccountService()?.updatePassword(currentPassword: curPasswordTextField.trimText!, newPassword: newPasswordTextField.trimText!, respAction: { result, newSaltedPassword in
            if result.isHttpOK {
                BTServiceContainer.getBTSessionService()?.updateNewPassword(newSaltedPassword)
                self.showAlert("BTLocTitleUpdatePswSuc".localizedBTBaseString, msg: nil, actions: [UIAlertAction(title: "BTLocOK".localizedBTBaseString, style: .default, handler: { _ in
                    self.navigationController?.popViewController(animated: true)
                })])
            } else {
                self.updatePasswordButton.isEnabled = true
                let msg = result.error != nil ? result.error.msgWithoutSpaces : "UnknowErr"
                self.showAlert("BTLocTitleUpdatePswErr".localizedBTBaseString, msg: "BTLocMsg\(msg)".localizedBTBaseString)
            }
        })
    }

    @objc private func onTextFieldEditingChanged(sender: Any) {
        if let textField = sender as? UITextField {
            if textField == curPasswordTextField {
                curPasswordCheckImage.isHidden = !String.regexTestStringWithPattern(value: textField.trimText, pattern: CommonRegexPatterns.PATTERN_PASSWORD)
                newPasswordTextField.isEnabled = !curPasswordCheckImage.isHidden
            } else if textField == newPasswordTextField {
                newPasswordCheckImage.isHidden = !String.regexTestStringWithPattern(value: textField.trimText, pattern: CommonRegexPatterns.PATTERN_PASSWORD)
            }
            updatePasswordButton.isEnabled = !newPasswordCheckImage.isHidden && !curPasswordCheckImage.isHidden
        }
    }

    @objc private func onTextFieldEditingDidBegin(sender: Any) {
    }

    @objc private func onTextFieldEditingDidEnd(sender: Any) {
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    deinit {
        debugLog("Deinited:\(self.description)")
    }
}
