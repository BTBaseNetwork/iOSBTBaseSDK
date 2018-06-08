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

    @IBOutlet var loginButton: UIButton! { didSet { loginButton.SetupBTBaseUI() } }

    override func viewDidLoad() {
        super.viewDidLoad()
        for textField in [accountTextField, passwordTextField] {
            textField?.addTarget(self, action: #selector(onTextFieldEditingDidBegin(sender:)), for: UIControlEvents.editingDidBegin)
            textField?.addTarget(self, action: #selector(onTextFieldEditingChanged(sender:)), for: UIControlEvents.editingChanged)
            textField?.addTarget(self, action: #selector(onTextFieldEditingDidEnd(sender:)), for: UIControlEvents.editingDidEnd)
        }
        setCheckTag(accountCheckImage, false)
        setCheckTag(passwordCheckImage, false)
        tipsLabel.text = nil
        if let status = BTServiceContainer.getBTSessionService()?.localSession.status, status == BTAccountSession.STATUS_LOGOUT_DEFAULT {
            accountTextField.text = BTServiceContainer.getBTSessionService()?.localSession.accountId
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.removeObserver(self, name: BTAccountService.onNewAccountRegisted, object: nil)
    }

    @objc func onNewAccountRegisted(a: Notification) {
        if let username = a.userInfo?[kBTRegistedUsername] as? String {
            accountTextField.text = username
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "SignUp" {
            NotificationCenter.default.addObserver(self, selector: #selector(onNewAccountRegisted(a:)), name: BTAccountService.onNewAccountRegisted, object: nil)
        }
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
                if result.isHttpOK {
                    self.onClickCancel(sender)
                } else {
                    if result.isHttpNotFound {
                        if let msg = result.error?.msgWithoutSpaces, msg == "LoginTooOften" {
                            self.showAlert("BTLogTitleLoginTooOften".localizedBTBaseString, msg: "BTLogMsgLoginTooOften".localizedBTBaseString)
                        } else {
                            self.tipsLabel.text = ("BTLocMsgLoginVerifyFalse").localizedBTBaseString
                        }
                    } else if result.isServerError {
                        self.tipsLabel.text = "BTLocMsgServerErr".localizedBTBaseString
                    } else {
                        self.tipsLabel.text = "BTLocMsgUnknowErr".localizedBTBaseString
                    }
                }
            })
        }
    }

    @objc private func onTextFieldEditingChanged(sender: Any) {
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

    @objc private func onTextFieldEditingDidBegin(sender: Any) {
        tipsLabel.text = nil
    }

    @objc private func onTextFieldEditingDidEnd(sender: Any) {
    }

    @IBAction func onClickCancel(_: Any) {
        navigationController?.dismiss(animated: true, completion: nil)
    }

    private func setCheckTag(_ check: UIView, _ visible: Bool) {
        check.isHidden = !visible
    }
}
