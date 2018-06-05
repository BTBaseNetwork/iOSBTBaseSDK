//
//  SignInViewController.swift
//  BTBaseSDK
//
//  Created by Alex Chow on 2018/6/4.
//  Copyright © 2018年 btbase. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {
    @IBOutlet var loadingIndicator: UIActivityIndicatorView! { didSet { loadingIndicator.hidesWhenStopped = true } }
    @IBOutlet var tipsLabel: UILabel!
    @IBOutlet var accountTextField: UITextField!

    @IBOutlet var passwordTextField: UITextField!

    @IBOutlet var accountCheckImage: UIImageView!
    @IBOutlet var passwordCheckImage: UIImageView!

    @IBOutlet var loginButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setCheckTag(accountCheckImage, false)
        setCheckTag(passwordCheckImage, false)
        tipsLabel.text = nil
    }

    @IBAction func onClickSignIn(_ sender: Any) {
        if String.isNullOrWhiteSpace(accountTextField.text) {
            tipsLabel.text = "BTLocMsgEmptyUserLogStr".localizedBTBaseString
        } else if String.isNullOrWhiteSpace(passwordTextField.text) {
            tipsLabel.text = "BTLocMsgEmptyPassword".localizedBTBaseString
        } else {
            loadingIndicator.startAnimating()
            loginButton.isEnabled = false
            accountTextField.isEnabled = false
            passwordTextField.isEnabled = false
            BTServiceContainer.getBTSessionService()?.login(userstring: accountTextField.text!, password: passwordTextField.text!, cachedPassword: false, respAction: { _, result in
                self.loadingIndicator.stopAnimating()
                self.loginButton.isEnabled = true
                self.accountTextField.isEnabled = true
                self.passwordTextField.isEnabled = true
                if result.code == 200 {
                    self.onClickCancel(sender)
                } else if result.code == 500 {
                    self.tipsLabel.text = "BTLocMsgNetworkErr".localizedBTBaseString
                } else {
                    if result.code == 404 {
                        self.tipsLabel.text = ("BTLocMsgLoginVerifyFalse").localizedBTBaseString
                    } else if result.code == 500 {
                        self.tipsLabel.text = "BTLocMsgServerErr".localizedBTBaseString
                    } else {
                        self.tipsLabel.text = "BTLocMsgUnknowErr".localizedBTBaseString
                    }
                }
            })
        }
    }

    @IBAction func onTextFieldEditingChanged(_ sender: Any) {
        if let textField = sender as? UITextField {
            if textField == accountTextField {
                if String.regexTestStringWithPattern(value: textField.text, pattern: CommonRegexPatterns.PATTERN_ACCOUNT_ID)
                    || String.regexTestStringWithPattern(value: textField.text, pattern: CommonRegexPatterns.PATTERN_USERNAME)
                    || String.regexTestStringWithPattern(value: textField.text, pattern: CommonRegexPatterns.PATTERN_EMAIL) {
                    setCheckTag(accountCheckImage, true)
                    loginButton.isEnabled = true
                } else {
                    setCheckTag(accountCheckImage, false)
                    loginButton.isEnabled = false
                }
            } else if textField == passwordTextField {
                if String.regexTestStringWithPattern(value: textField.text, pattern: CommonRegexPatterns.PATTERN_PASSWORD) {
                    setCheckTag(accountCheckImage, true)
                    loginButton.isEnabled = true
                } else {
                    setCheckTag(accountCheckImage, false)
                    loginButton.isEnabled = false
                }
            }
        }
    }

    @IBAction func onTextFieldEditingDidBegin(_: Any) {
        tipsLabel.text = nil
    }

    @IBAction func onTextFieldEditingDidEnd(_: Any) {
    }

    @IBAction func onClickCancel(_: Any) {
        navigationController?.dismiss(animated: true, completion: nil)
    }

    private func setCheckTag(_ check: UIView, _ visible: Bool) {
        check.isHidden = !visible
    }
}
