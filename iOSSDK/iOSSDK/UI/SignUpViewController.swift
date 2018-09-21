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
    @IBOutlet var usernameTextField: UITextField! { didSet { usernameTextField.SetupBTBaseUI() } }
    @IBOutlet var passwordTextField: UITextField! { didSet { passwordTextField.SetupBTBaseUI() } }
    @IBOutlet var emailTextField: UITextField! { didSet { emailTextField.SetupBTBaseUI() } }
    @IBOutlet var confirmEmailTextField: UITextField! { didSet { confirmEmailTextField.SetupBTBaseUI() } }

    @IBOutlet var signupButton: UIButton! { didSet { signupButton.SetupBTBaseUI() } }

    @IBOutlet var usernameCheckImage: UIImageView!
    @IBOutlet var passwordCheckImage: UIImageView!
    @IBOutlet var emailCheckImage: UIImageView!
    @IBOutlet var confirmEmailCheckImage: UIImageView!
    
    var onSignUpComplete:((_ username:String,_ accountId:String)->Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        SetupBTBaseUI()
        for textField in [usernameTextField, passwordTextField, emailTextField, confirmEmailTextField] {
            textField?.addTarget(self, action: #selector(onTextFieldEditingDidBegin(sender:)), for: UIControl.Event.editingDidBegin)
            textField?.addTarget(self, action: #selector(onTextFieldEditingChanged(sender:)), for: UIControl.Event.editingChanged)
            textField?.addTarget(self, action: #selector(onTextFieldEditingDidEnd(sender:)), for: UIControl.Event.editingDidEnd)
        }
        setCheckTag(usernameCheckImage, false)
        setCheckTag(passwordCheckImage, false)
        setCheckTag(emailCheckImage, false)
        setCheckTag(confirmEmailCheckImage, false)
        usernameTextField.isEnabled = true
        passwordTextField.isEnabled = false
        emailTextField.isEnabled = false
        confirmEmailTextField.isEnabled = false
        signupButton.isEnabled = false
        tipsLabel.text = nil
    }

    @IBAction func onClickPrivacy(_: Any) {
        let url = "http://applistapi-btbasenetwork.7e14.starter-us-west-2.openshiftapps.com/privacy.html"
        SimpleBrowser.openUrl(self, url: url, title: "BTLocPrivacy".localizedBTBaseString)
    }

    @IBAction func onClickSignUp(_: Any) {
        loadingIndicator.startAnimating()
        confirmEmailTextField.isEnabled = false
        emailTextField.isEnabled = false
        usernameTextField.isEnabled = false
        passwordTextField.isEnabled = false
        signupButton.isEnabled = false
        BTServiceContainer.getBTAccountService()?.regist(username: usernameTextField.trimText!, password: passwordTextField.trimText!, email: emailTextField.trimText!, respAction: { _, result in
            self.loadingIndicator.stopAnimating()
            self.confirmEmailTextField.isEnabled = true
            self.emailTextField.isEnabled = true
            self.usernameTextField.isEnabled = true
            self.passwordTextField.isEnabled = true
            self.signupButton.isEnabled = false
            if result.isServerError {
                self.tipsLabel.text = "BTLocMsgServerErr".localizedBTBaseString
            } else if result.isHttpOK {
                self.onSignUpComplete?(result.content.userName,result.content.accountId)
                
                self.showAlert("BTLocTitleRegistSuc".localizedBTBaseString, msg: String(format: "BTLocMsgYourAccountId_X".localizedBTBaseString, result.content.accountId), actions: [UIAlertAction(title: "BTLocOK".localizedBTBaseString, style: .default, handler: { _ in
                    self.navigationController?.popViewController(animated: true)
                    self.onSignUpComplete = nil
                })])
            } else if let err = result.error {
                self.tipsLabel.text = ("BTLocMsg\(err.msgWithoutSpaces)").localizedBTBaseString
            } else {
                self.tipsLabel.text = "BTLocMsgUnknow".localizedBTBaseString
            }

        })
    }

    @objc private func onTextFieldEditingChanged(sender _: Any) {}
    @objc private func onTextFieldEditingDidBegin(sender _: Any) {}
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
        if String.regexTestStringWithPattern(value: usernameTextField.trimText, pattern: CommonRegexPatterns.PATTERN_USERNAME) {
            passwordTextField.isEnabled = true
            tipsLabel.text = nil
            setCheckTag(usernameCheckImage, true)
        } else {
            setCheckTag(usernameCheckImage, false)
            passwordTextField.isEnabled = false
            if !String.isNullOrWhiteSpace(usernameTextField.trimText) {
                tipsLabel.text = "BTLocMsgInvalidUserName".localizedBTBaseString
            }
        }
        tryEnableSignUpButton()
    }

    private func onPasswordChanged() {
        if String.regexTestStringWithPattern(value: passwordTextField.trimText, pattern: CommonRegexPatterns.PATTERN_PASSWORD) {
            emailTextField.isEnabled = true
            tipsLabel.text = nil
            setCheckTag(passwordCheckImage, true)
        } else {
            setCheckTag(passwordCheckImage, false)
            emailTextField.isEnabled = false
            if !String.isNullOrWhiteSpace(passwordTextField.trimText) {
                tipsLabel.text = "BTLocMsgInvalidPassword".localizedBTBaseString
            }
        }
        tryEnableSignUpButton()
    }

    private func onEmailChanged() {
        if String.regexTestStringWithPattern(value: emailTextField.trimText, pattern: CommonRegexPatterns.PATTERN_EMAIL) {
            confirmEmailTextField.isEnabled = true
            tipsLabel.text = nil
            setCheckTag(emailCheckImage, true)
        } else {
            setCheckTag(emailCheckImage, false)
            confirmEmailTextField.isEnabled = false
            if !String.isNullOrWhiteSpace(emailTextField.trimText) {
                tipsLabel.text = "BTLocMsgNeedEmail".localizedBTBaseString
            }
        }
        tryEnableSignUpButton()
    }

    private func onConfirmEmailChanged() {
        if emailTextField.trimText == confirmEmailTextField.trimText {
            tipsLabel.text = nil
            setCheckTag(confirmEmailCheckImage, true)
        } else {
            setCheckTag(confirmEmailCheckImage, false)
            if !String.isNullOrWhiteSpace(confirmEmailTextField.trimText) {
                tipsLabel.text = "BTLocMsgDiffEmail".localizedBTBaseString
            }
        }
        tryEnableSignUpButton()
    }

    private func setCheckTag(_ check: UIView, _ visible: Bool) {
        if let img = check as? UIImageView{
            img.tintColor = BTBaseUIConfig.GlobalTintColor
        }
        check.isHidden = !visible
    }

    private func tryEnableSignUpButton() {
        var valid = String.regexTestStringWithPattern(value: usernameTextField.trimText, pattern: CommonRegexPatterns.PATTERN_USERNAME)
        valid = valid && String.regexTestStringWithPattern(value: passwordTextField.trimText, pattern: CommonRegexPatterns.PATTERN_PASSWORD)
        valid = valid && String.regexTestStringWithPattern(value: emailTextField.trimText, pattern: CommonRegexPatterns.PATTERN_EMAIL)
        signupButton.isEnabled = valid
    }
    
    deinit {
        debugLog("Deinited:\(self.description)")
    }
}
