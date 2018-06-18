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
    @IBOutlet var accountTextField: UITextField! { didSet { accountTextField.SetupBTBaseUI() } }

    @IBOutlet var passwordTextField: UITextField! { didSet { passwordTextField.SetupBTBaseUI() } }

    @IBOutlet var accountCheckImage: UIImageView!
    @IBOutlet var passwordCheckImage: UIImageView!

    @IBOutlet var loginButton: UIButton! { didSet { loginButton.SetupBTBaseUI() } }

    var saltedPassword: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        SetupBTBaseUI()

        for textField in [accountTextField, passwordTextField] {
            textField?.addTarget(self, action: #selector(onTextFieldEditingDidBegin(sender:)), for: UIControlEvents.editingDidBegin)
            textField?.addTarget(self, action: #selector(onTextFieldEditingChanged(sender:)), for: UIControlEvents.editingChanged)
            textField?.addTarget(self, action: #selector(onTextFieldEditingDidEnd(sender:)), for: UIControlEvents.editingDidEnd)
        }
        setCheckTag(accountCheckImage, false)
        setCheckTag(passwordCheckImage, false)
        tipsLabel.text = nil
        loginButton.isEnabled = false
        if let session = BTServiceContainer.getBTSessionService()?.localSession, session.status == BTAccountSession.STATUS_LOGOUT_DEFAULT {
            accountTextField.text = session.accountId
            if session.fillPassword && !String.isNullOrWhiteSpace(session.password) {
                saltedPassword = session.password
                passwordTextField.text = "********"
            } else {
                saltedPassword = nil
                passwordTextField.text = nil
            }
        } else {
            accountTextField.text = nil
            performSegue(withIdentifier: "SignUp", sender: self)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "SignUp",let svc = segue.destination as? SignUpViewController {
            svc.onSignUpComplete = { username,accountId in
                self.accountTextField.text = username
            }
        }
    }

    @IBAction func onClickSignIn(_ sender: Any) {
        if String.isNullOrWhiteSpace(accountTextField.trimText) {
            tipsLabel.text = "BTLocMsgEmptyUserLogStr".localizedBTBaseString
        } else if String.isNullOrWhiteSpace(passwordTextField.trimText) {
            tipsLabel.text = "BTLocMsgEmptyPassword".localizedBTBaseString
        } else {
            loadingIndicator.startAnimating()
            loginButton.isEnabled = false
            accountTextField.isEnabled = false
            passwordTextField.isEnabled = false
            let loginStr = accountTextField.trimText!
            let isSalted = !String.isNullOrWhiteSpace(saltedPassword)
            let psw = isSalted ? saltedPassword! : passwordTextField.trimText!
            BTServiceContainer.getBTSessionService()?.login(loginStr, psw, passwordSalted: isSalted, autoFillPassword: false, respAction: { _, result in
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
                if String.regexTestStringWithPattern(value: textField.trimText, pattern: CommonRegexPatterns.PATTERN_ACCOUNT_ID)
                    || String.regexTestStringWithPattern(value: textField.trimText, pattern: CommonRegexPatterns.PATTERN_USERNAME)
                    || String.regexTestStringWithPattern(value: textField.trimText, pattern: CommonRegexPatterns.PATTERN_EMAIL) {
                    setCheckTag(accountCheckImage, true)
                    loginButton.isEnabled = true
                } else {
                    setCheckTag(accountCheckImage, false)
                    loginButton.isEnabled = false
                }
            } else if textField == passwordTextField {
                if String.regexTestStringWithPattern(value: textField.trimText, pattern: CommonRegexPatterns.PATTERN_PASSWORD) {
                    setCheckTag(accountCheckImage, true)
                    loginButton.isEnabled = true
                } else {
                    setCheckTag(accountCheckImage, false)
                    loginButton.isEnabled = false
                }
                saltedPassword = nil
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
        if let img = check as? UIImageView{
            img.tintColor = BTBaseUIConfig.GlobalTintColor
        }
        check.isHidden = !visible
    }

    deinit {
        debugLog("Deinited:\(self.description)")
    }
}
