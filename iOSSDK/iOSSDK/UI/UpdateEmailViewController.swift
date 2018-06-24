//
//  UpdateEmailViewController.swift
//  BTBaseSDK
//
//  Created by Alex Chow on 2018/6/4.
//  Copyright © 2018年 btbase. All rights reserved.
//

import UIKit

class UpdateEmailViewController: UIViewController {
    @IBOutlet var tipsLabel: UILabel!
    @IBOutlet var curEmailTextField: UITextField! { didSet { curEmailTextField.SetupBTBaseUI() } }
    @IBOutlet var securityCodeTextField: UITextField! { didSet { securityCodeTextField.SetupBTBaseUI() } }
    @IBOutlet var newEmailTextField: UITextField! { didSet { newEmailTextField.SetupBTBaseUI() } }
    @IBOutlet var confirmNewEmailTextField: UITextField! { didSet { confirmNewEmailTextField.SetupBTBaseUI() } }
    @IBOutlet var sendCodeButton: UIButton!
    @IBOutlet var updateEmailButton: UIButton! { didSet { updateEmailButton.SetupBTBaseUI() } }

    @IBOutlet var securityCodeCheckImage: UIImageView!
    @IBOutlet var newEmailCheckImage: UIImageView!
    @IBOutlet var confirmNewEmailCheckImage: UIImageView!
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
        for textField in [curEmailTextField, securityCodeTextField, newEmailTextField, confirmNewEmailTextField] {
            textField?.addTarget(self, action: #selector(onTextFieldEditingDidBegin(sender:)), for: UIControlEvents.editingDidBegin)
            textField?.addTarget(self, action: #selector(onTextFieldEditingChanged(sender:)), for: UIControlEvents.editingChanged)
            textField?.addTarget(self, action: #selector(onTextFieldEditingDidEnd(sender:)), for: UIControlEvents.editingDidEnd)
        }
        updateEmailButton.isEnabled = false
        tipsLabel.text = nil
        sendCodeButton.isHidden = true
        sendCodeButton.isEnabled = false
        setCheckTag(securityCodeCheckImage, false)
        setCheckTag(newEmailCheckImage, false)
        setCheckTag(confirmNewEmailCheckImage, false)
        curEmailTextField.isEnabled = true
        securityCodeTextField.isEnabled = false
        newEmailTextField.isEnabled = false
        confirmNewEmailTextField.isEnabled = false
        resendAvailableTime = 0
    }

    @IBAction func onClickSendCode(_: Any) {
        sendCodeButton.isHidden = true
        curEmailTextField.isEnabled = false
        BTServiceContainer.getBTAccountService()?.sendUpdateEmailSecurityCode(email: curEmailTextField.trimText!, respAction: { _, result in
            self.sendCodeButton.isHidden = false
            self.sendCodeButton.isEnabled = !result.isHttpOK
            self.curEmailTextField.isEnabled = true

            if result.isHttpOK {
                self.securityCodeTextField.isEnabled = true
                self.securityCodeTextField.text = nil
                let ok = UIAlertAction(title: "BTLocOK".localizedBTBaseString, style: .default, handler: { _ in
                    self.resendAvailableTime = 30
                    self.resendTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(UpdateEmailViewController.resendCodeTimeTicking), userInfo: nil, repeats: true)
                })
                self.showAlert("BTLocTitleCodeSended".localizedBTBaseString, msg: "BTLocMsgCodeSended".localizedBTBaseString, actions: [ok])
            } else if result.isServerError {
                self.tipsLabel.text = "BTLocMsgServerErr".localizedBTBaseString
            } else if let err = result.error {
                self.tipsLabel.text = ("BTLocMsg\(err.msgWithoutSpaces)").localizedBTBaseString
            } else {
                self.tipsLabel.text = "BTLocMsgUnknowErr".localizedBTBaseString
            }
        })
    }

    @objc private func resendCodeTimeTicking() {
        if resendAvailableTime > 0 {
            resendAvailableTime -= 1
        } else {
            resendTimer?.invalidate()
            sendCodeButton.isEnabled = String.regexTestStringWithPattern(value: curEmailTextField.trimText, pattern: CommonRegexPatterns.PATTERN_EMAIL)
            resendTimer = nil
        }
    }

    @IBAction func onClickUpdateEmail(_: Any) {
        updateEmailButton.isEnabled = false
        BTServiceContainer.getBTAccountService()?.updateEmailWithSecurityCode(newEmail: newEmailTextField.trimText!, securityCode: securityCodeTextField.trimText!, respAction: { _, result in
            self.updateEmailButton.isEnabled = true
            if result.isHttpOK {
                self.showAlert("BTLocTitleEmailUpdated".localizedBTBaseString, msg: nil, actions: [UIAlertAction(title: "BTLocOK".localizedBTBaseString, style: .default, handler: { _ in
                    self.navigationController?.popViewController(animated: true)
                })])
            } else {
                let msg = result.error != nil ? result.error.msgWithoutSpaces : "UnknowErr"
                self.showAlert("BTLocTitleUpdateEmailErr".localizedBTBaseString, msg: ("BTLocMsg\(msg)").localizedBTBaseString)
            }
        })
    }

    @IBAction func onTextFieldEditingChanged(sender: Any) {
        if let textField = sender as? UITextField {
            switch textField {
            case curEmailTextField: onCurrentEmailChanged()
            case securityCodeTextField: onSecurityCodeChanged()
            case newEmailTextField: onNewEmailChanged()
            case confirmNewEmailTextField: onCurrentEmailChanged()
            default: break
            }
        }
    }

    @IBAction func onTextFieldEditingDidBegin(sender _: Any) {
    }

    @IBAction func onTextFieldEditingDidEnd(sender _: Any) {
    }

    private func onCurrentEmailChanged() {
        if String.regexTestStringWithPattern(value: curEmailTextField.trimText, pattern: CommonRegexPatterns.PATTERN_EMAIL) {
            sendCodeButton.isEnabled = resendAvailableTime <= 0
            sendCodeButton.isHidden = false
            tipsLabel.text = nil

        } else {
            sendCodeButton.isEnabled = false
            if !String.isNullOrWhiteSpace(curEmailTextField.trimText) {
                tipsLabel.text = "BTLocMsgInvalidEmail".localizedBTBaseString
            }
        }
    }

    private func onSecurityCodeChanged() {
        if String.regexTestStringWithPattern(value: securityCodeTextField.trimText, pattern: CommonRegexPatterns.PATTERN_VERIFY_CODE) {
            newEmailTextField.isEnabled = true
            tipsLabel.text = nil
            setCheckTag(securityCodeCheckImage, true)
        } else {
            setCheckTag(securityCodeCheckImage, false)
            newEmailTextField.isEnabled = false
            if !String.isNullOrWhiteSpace(securityCodeTextField.trimText) {
                tipsLabel.text = "BTLocMsgEnterSecurityCode".localizedBTBaseString
            }
        }
    }

    private func onNewEmailChanged() {
        if String.regexTestStringWithPattern(value: newEmailTextField.trimText, pattern: CommonRegexPatterns.PATTERN_EMAIL) {
            confirmNewEmailTextField.isEnabled = true
            tipsLabel.text = nil
            setCheckTag(confirmNewEmailCheckImage, true)
        } else {
            setCheckTag(confirmNewEmailCheckImage, false)
            confirmNewEmailTextField.isEnabled = false
            if !String.isNullOrWhiteSpace(newEmailTextField.trimText) {
                tipsLabel.text = "BTLocMsgInvalidNewEmail".localizedBTBaseString
            }
        }
    }

    private func onConfirmNewEmailChanged() {
        if newEmailTextField.trimText == confirmNewEmailTextField.trimText {
            updateEmailButton.isEnabled = true
            tipsLabel.text = nil
            setCheckTag(confirmNewEmailCheckImage, true)
        } else {
            updateEmailButton.isEnabled = false
            setCheckTag(confirmNewEmailCheckImage, false)
            if !String.isNullOrWhiteSpace(newEmailTextField.trimText) {
                tipsLabel.text = "BTLocMsgEmailNotMatch".localizedBTBaseString
            }
        }
    }

    private func setCheckTag(_ check: UIView, _ visible: Bool) {
        if let img = check as? UIImageView {
            img.tintColor = BTBaseUIConfig.GlobalTintColor
        }
        check.isHidden = !visible
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
