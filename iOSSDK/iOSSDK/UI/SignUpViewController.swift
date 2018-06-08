//
//  SignUpViewController.swift
//  BTBaseSDK
//
//  Created by Alex Chow on 2018/6/4.
//  Copyright © 2018年 btbase. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {
    @IBOutlet var loadingIndicator: UIActivityIndicatorView! { didSet { loadingIndicator.hidesWhenStopped = true } }
    @IBOutlet var tipsLabel: UILabel!
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var confirmEmailTextField: UITextField!

    @IBOutlet var signupButton: UIButton!{ didSet { signupButton.SetupBTBaseUI() } }

    @IBOutlet var usernameCheckImage: UIImageView!
    @IBOutlet var passwordCheckImage: UIImageView!
    @IBOutlet var emailCheckImage: UIImageView!
    @IBOutlet var confirmEmailCheckImage: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        SetupBTBaseUI()
        for textField in [usernameTextField, passwordTextField, emailTextField, confirmEmailTextField] {
            textField?.addTarget(self, action: #selector(onTextFieldEditingDidBegin(sender:)), for: UIControlEvents.editingDidBegin)
            textField?.addTarget(self, action: #selector(onTextFieldEditingChanged(sender:)), for: UIControlEvents.editingChanged)
            textField?.addTarget(self, action: #selector(onTextFieldEditingDidEnd(sender:)), for: UIControlEvents.editingDidEnd)
        }
        setCheckTag(usernameCheckImage, false)
        setCheckTag(passwordCheckImage, false)
        setCheckTag(emailCheckImage, false)
        setCheckTag(confirmEmailCheckImage, false)
        usernameTextField.isEnabled = true
        passwordTextField.isEnabled = false
        emailTextField.isEnabled = false
        confirmEmailTextField.isEnabled = false
        tipsLabel.text = nil
    }

    @IBAction func onClickSignUp(_: Any) {
        loadingIndicator.startAnimating()
        confirmEmailTextField.isEnabled = false
        emailTextField.isEnabled = false
        usernameTextField.isEnabled = false
        passwordTextField.isEnabled = false
        signupButton.isEnabled = false
        BTServiceContainer.getBTAccountService()?.regist(username: usernameTextField.text!, password: passwordTextField.text!, email: emailTextField.text!, respAction: { _, result in
            self.loadingIndicator.stopAnimating()
            self.confirmEmailTextField.isEnabled = true
            self.emailTextField.isEnabled = true
            self.usernameTextField.isEnabled = true
            self.passwordTextField.isEnabled = true
            self.signupButton.isEnabled = false
            if result.isServerError {
                self.tipsLabel.text = "BTLocMsgServerErr".localizedBTBaseString
            } else if result.isHttpOK {
                self.showAlert("BTLocTitleRegistSuc".localizedBTBaseString, msg: String(format: "BTLocMsgYourAccountId_X".localizedBTBaseString, result.content.accountId), actions: [UIAlertAction(title: "BTLocOK".localizedBTBaseString, style: .default, handler: { _ in
                    self.navigationController?.popViewController(animated: true)
                })])
            } else if let msg = result.error.msgWithoutSpaces {
                self.tipsLabel.text = ("BTLocMsg\(msg)").localizedBTBaseString
            } else {
                self.tipsLabel.text = "BTLocMsgUnknow".localizedBTBaseString
            }

        })
    }

    @objc private func onTextFieldEditingChanged(sender: Any) {}
    @objc private func onTextFieldEditingDidBegin(sender: Any) {}
    @objc private func onTextFieldEditingDidEnd(sender: Any) {
        if let textField = sender as? UITextField {
            switch textField {
            case usernameTextField: onInputUserNameChanged()
            case passwordTextField: onPasswordChanged()
            case emailTextField: onEmailChanged()
            case confirmEmailTextField: onConfirmEmailChanged()
            default: break
            }
        }
    }

    private func onInputUserNameChanged() {
        if String.regexTestStringWithPattern(value: usernameTextField.text, pattern: CommonRegexPatterns.PATTERN_USERNAME) {
            passwordTextField.isEnabled = true
            tipsLabel.text = nil
            setCheckTag(usernameCheckImage, true)
        } else {
            setCheckTag(usernameCheckImage, false)
            passwordTextField.isEnabled = false
            if !String.isNullOrWhiteSpace(usernameTextField.text) {
                tipsLabel.text = "BTLocMsgInvalidUserName".localizedBTBaseString
            }
        }
        tryEnableSignUpButton()
    }

    private func onPasswordChanged() {
        if String.regexTestStringWithPattern(value: passwordTextField.text, pattern: CommonRegexPatterns.PATTERN_PASSWORD) {
            emailTextField.isEnabled = true
            tipsLabel.text = nil
            setCheckTag(passwordCheckImage, true)
        } else {
            setCheckTag(passwordCheckImage, false)
            emailTextField.isEnabled = false
            if !String.isNullOrWhiteSpace(passwordTextField.text) {
                tipsLabel.text = "BTLocMsgInvalidPassword".localizedBTBaseString
            }
        }
        tryEnableSignUpButton()
    }

    private func onEmailChanged() {
        if String.regexTestStringWithPattern(value: emailTextField.text, pattern: CommonRegexPatterns.PATTERN_EMAIL) {
            confirmEmailTextField.isEnabled = true
            tipsLabel.text = nil
            setCheckTag(emailCheckImage, true)
        } else {
            setCheckTag(emailCheckImage, false)
            confirmEmailTextField.isEnabled = false
            if !String.isNullOrWhiteSpace(emailTextField.text) {
                tipsLabel.text = "BTLocMsgNeedEmail".localizedBTBaseString
            }
        }
        tryEnableSignUpButton()
    }

    private func onConfirmEmailChanged() {
        if emailTextField.text == confirmEmailTextField.text {
            tipsLabel.text = nil
            setCheckTag(confirmEmailCheckImage, true)
        } else {
            setCheckTag(confirmEmailCheckImage, false)
            if !String.isNullOrWhiteSpace(confirmEmailTextField.text) {
                tipsLabel.text = "BTLocMsgDiffEmail".localizedBTBaseString
            }
        }
        tryEnableSignUpButton()
    }

    private func setCheckTag(_ check: UIView, _ visible: Bool) {
        check.isHidden = !visible
    }

    private func tryEnableSignUpButton() {
        var valid = String.regexTestStringWithPattern(value: usernameTextField.text, pattern: CommonRegexPatterns.PATTERN_USERNAME)
        valid = valid && String.regexTestStringWithPattern(value: passwordTextField.text, pattern: CommonRegexPatterns.PATTERN_PASSWORD)
        valid = valid && String.regexTestStringWithPattern(value: emailTextField.text, pattern: CommonRegexPatterns.PATTERN_EMAIL)
        signupButton.isEnabled = valid
    }
}
