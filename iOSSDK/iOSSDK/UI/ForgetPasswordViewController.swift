//
//  ForgetPasswordViewController.swift
//  BTBaseSDK
//
//  Created by Alex Chow on 2018/6/4.
//  Copyright © 2018年 btbase. All rights reserved.
//

import UIKit

class ForgetPasswordViewController: UIViewController {
    @IBOutlet var tipsLabel: UILabel!
    @IBOutlet var accountIdTextField: UITextField! { didSet { accountIdTextField.SetupBTBaseUI() } }
    @IBOutlet var emailTextField: UITextField! { didSet { emailTextField.SetupBTBaseUI() } }
    @IBOutlet var securityCodeTextField: UITextField! { didSet { securityCodeTextField.SetupBTBaseUI() } }
    @IBOutlet var newPasswordTextField: UITextField! { didSet { newPasswordTextField.SetupBTBaseUI() } }
    @IBOutlet var sendCodeButton: UIButton!
    @IBOutlet var resetPasswordButton: UIButton! { didSet { resetPasswordButton.SetupBTBaseUI() } }
    @IBOutlet var accoundIdCheckImage: UIImageView!
    @IBOutlet var codeCheckImage: UIImageView!
    @IBOutlet var newPasswordCheckImage: UIImageView!
    private var resendAvailableTime = 0 {
        didSet {
            if resendAvailableTime <= 0 {
                sendCodeButton?.setTitle("BTLocSendCode".localizedBTBaseString, for: .normal)
            } else {
                sendCodeButton?.setTitle(String(format: "%ds", resendAvailableTime), for: .normal)
            }
        }
    }

    private var resendTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        SetupBTBaseUI()
        for textField in [accountIdTextField, emailTextField, securityCodeTextField, newPasswordTextField] {
            textField?.addTarget(self, action: #selector(onTextFieldEditingDidBegin(sender:)), for: UIControlEvents.editingDidBegin)
            textField?.addTarget(self, action: #selector(onTextFieldEditingChanged(sender:)), for: UIControlEvents.editingChanged)
            textField?.addTarget(self, action: #selector(onTextFieldEditingDidEnd(sender:)), for: UIControlEvents.editingDidEnd)
        }

        resetPasswordButton.isEnabled = false
        tipsLabel.text = nil
        sendCodeButton.isEnabled = false
        sendCodeButton.isHidden = true
        setCheckTag(accoundIdCheckImage, false)
        setCheckTag(codeCheckImage, false)
        setCheckTag(newPasswordCheckImage, false)
        accountIdTextField.isEnabled = true
        emailTextField.isEnabled = false
        securityCodeTextField.isEnabled = false
        newPasswordTextField.isEnabled = false
        resendAvailableTime = 0
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        resendTimer?.invalidate()
        resendTimer = nil
    }

    @objc private func onTextFieldEditingChanged(sender: Any) {
        if let textField = sender as? UITextField {
            switch textField {
            case accountIdTextField: onAccountIdChanged()
            case emailTextField: onEmailChanged()
            case securityCodeTextField: onSecurityCodeChanged()
            case newPasswordTextField: onNewPasswordChanged()
            default: break
            }
        }
    }

    @objc private func onTextFieldEditingDidBegin(sender _: Any) {
    }

    @objc private func onTextFieldEditingDidEnd(sender _: Any) {
    }

    @IBAction func onClickSendCode(_: Any) {
        sendCodeButton.isHidden = true
        emailTextField.isEnabled = false
        accountIdTextField.isEnabled = false
        BTServiceContainer.getBTAccountService()?.sendResetPasswordSecurityCode(accountId: accountIdTextField.trimText!, email: emailTextField.trimText!, respAction: { _, result in
            self.sendCodeButton.isHidden = false
            self.sendCodeButton.isEnabled = !result.isHttpOK
            self.emailTextField.isEnabled = true
            self.accountIdTextField.isEnabled = true
            if result.isHttpOK {
                self.securityCodeTextField.isEnabled = true
                self.securityCodeTextField.text = nil
                let ok = UIAlertAction(title: "BTLocOK".localizedBTBaseString, style: .default, handler: { _ in
                    self.resendAvailableTime = 30
                    self.resendTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ForgetPasswordViewController.resendCodeTimeTicking), userInfo: nil, repeats: true)
                })
                self.showAlert("BTLocTitleCodeSended".localizedBTBaseString, msg: "BTLocMsgCodeSended".localizedBTBaseString, actions: [ok])
            } else if result.isServerError {
                self.tipsLabel.text = "BTLocMsgServerErr".localizedBTBaseString
            } else if let err = result.error {
                self.tipsLabel.text = ("BTLocMsg\(err.msgWithoutSpaces)").localizedBTBaseString
            } else {
                self.tipsLabel.text = "BTLocMsgUnknow".localizedBTBaseString
            }
        })
    }

    @objc private func resendCodeTimeTicking() {
        if resendAvailableTime > 0 {
            resendAvailableTime -= 1
        } else {
            resendTimer?.invalidate()
            sendCodeButton.isEnabled = String.regexTestStringWithPattern(value: emailTextField.trimText, pattern: CommonRegexPatterns.PATTERN_EMAIL)
            resendTimer = nil
        }
    }

    @IBAction func onClickResetPassword(_: Any) {
        resetPasswordButton.isEnabled = false
        BTServiceContainer.getBTAccountService()?.resetPasswordWithSecurityCode(accountId: accountIdTextField.trimText!, newPassword: newPasswordTextField.trimText!, securityCode: securityCodeTextField.trimText!, respAction: { _, result in
            self.resetPasswordButton.isEnabled = true
            if result.isHttpOK {
                let actions = [UIAlertAction(title: "BTLocOK".localizedBTBaseString, style: .default, handler: { _ in
                    self.navigationController?.dismiss(animated: true, completion: nil)
                })]
                self.showAlert("BTLocTitlePasswordReseted".localizedBTBaseString, msg: "BTLocMsgPasswordResetedAndRelogin".localizedBTBaseString, actions: actions)
            } else if result.isServerError {
                self.tipsLabel.text = "BTLocMsgServerErr".localizedBTBaseString
            } else if let err = result.error {
                self.tipsLabel.text = ("BTLocMsg\(err.msgWithoutSpaces)").localizedBTBaseString
            } else {
                self.tipsLabel.text = "BTLocMsgUnknow".localizedBTBaseString
            }
        })
    }

    @IBAction func onClickCancel(_: Any) {
        navigationController?.dismiss(animated: true, completion: nil)
    }

    private func setCheckTag(_ check: UIView, _ visible: Bool) {
        check.isHidden = !visible
    }

    private func onAccountIdChanged() {
        if String.regexTestStringWithPattern(value: accountIdTextField.trimText, pattern: CommonRegexPatterns.PATTERN_ACCOUNT_ID) {
            emailTextField.isEnabled = true
            tipsLabel.text = nil
            setCheckTag(accoundIdCheckImage, true)

        } else {
            emailTextField.isEnabled = false
            setCheckTag(accoundIdCheckImage, false)
            if !String.isNullOrWhiteSpace(accountIdTextField.trimText) {
                tipsLabel.text = "BTLocMsgEnterValidAccountID".localizedBTBaseString
            }
        }
    }

    private func onEmailChanged() {
        if String.regexTestStringWithPattern(value: emailTextField.trimText, pattern: CommonRegexPatterns.PATTERN_EMAIL) {
            sendCodeButton.isEnabled = resendAvailableTime <= 0
            sendCodeButton.isHidden = false
            tipsLabel.text = nil

        } else {
            sendCodeButton.isEnabled = false
            if !String.isNullOrWhiteSpace(emailTextField.trimText) {
                tipsLabel.text = "BTLocMsgInvalidEmail".localizedBTBaseString
            }
        }
    }

    private func onSecurityCodeChanged() {
        if String.regexTestStringWithPattern(value: securityCodeTextField.trimText, pattern: CommonRegexPatterns.PATTERN_VERIFY_CODE) {
            newPasswordTextField.isEnabled = true
            tipsLabel.text = nil
            setCheckTag(codeCheckImage, true)
        } else {
            setCheckTag(codeCheckImage, false)
            newPasswordTextField.isEnabled = false
            if !String.isNullOrWhiteSpace(securityCodeTextField.trimText) {
                tipsLabel.text = "BTLocMsgEnterSecurityCode".localizedBTBaseString
            }
        }
    }

    private func onNewPasswordChanged() {
        if String.regexTestStringWithPattern(value: newPasswordTextField.trimText, pattern: CommonRegexPatterns.PATTERN_PASSWORD) {
            resetPasswordButton.isEnabled = true
            tipsLabel.text = nil
            setCheckTag(newPasswordCheckImage, true)
        } else {
            resetPasswordButton.isEnabled = false
            setCheckTag(newPasswordCheckImage, false)
            if !String.isNullOrWhiteSpace(newPasswordTextField.trimText) {
                tipsLabel.text = "BTLocMsgEnterNewValidPassword".localizedBTBaseString
            }
        }
    }
    deinit {
        debugLog("Deinited:\(self.description)")
    }
}
