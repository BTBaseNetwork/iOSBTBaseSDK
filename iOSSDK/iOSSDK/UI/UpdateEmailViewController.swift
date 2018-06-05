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
    @IBOutlet var curEmailTextField: UITextField!
    @IBOutlet var securityCodeTextField: UITextField!
    @IBOutlet var newEmailTextField: UITextField!
    @IBOutlet var confirmNewEmailTextField: UITextField!
    @IBOutlet var sendCodeButton: UIButton!
    @IBOutlet var updateEmailButton: UIButton!

    @IBOutlet var securityCodeCheckImage: UIImageView!
    @IBOutlet var newEmailCheckImage: UIImageView!
    @IBOutlet var confirmNewEmailCheckImage: UIImageView!
    private var resendAvailableTime = 0 {
        didSet {
            if resendAvailableTime <= 0 {
                sendCodeButton?.titleLabel?.text = "BTLocSendCode".localizedBTBaseString
            } else {
                sendCodeButton?.titleLabel?.text = String(format: "%@s", resendAvailableTime)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateEmailButton.isEnabled = false
        tipsLabel.text = nil
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
        BTServiceContainer.getBTAccountService()?.sendUpdateEmailSecurityCode(email: curEmailTextField.text!, respAction: { _, result in
            self.sendCodeButton.isHidden = result.code == 200
            self.curEmailTextField.isEnabled = true
            if result.code == 200 {
                self.securityCodeTextField.isEnabled = true
                self.securityCodeTextField.text = nil
                self.resendAvailableTime = 30
                Timer(timeInterval: 1, target: self, selector: #selector(self.resendCodeTimeTicking(timer:)), userInfo: nil, repeats: true).fire()
                self.showAlert("BTLocTitleCodeSended".localizedBTBaseString, msg: "BTLocMsgCodeSended".localizedBTBaseString)
            } else if result.code == 500 {
                self.tipsLabel.text = "BTLocMsgNetworkErr".localizedBTBaseString
            } else if let msg = result.error.msgWithoutSpaces {
                self.tipsLabel.text = ("BTLocMsg\(msg)").localizedBTBaseString
            } else {
                self.tipsLabel.text = "BTLocMsgUnknow".localizedBTBaseString
            }
        })
    }

    @objc private func resendCodeTimeTicking(timer: Timer) {
        if resendAvailableTime > 0 {
            resendAvailableTime -= 1
        } else {
            timer.invalidate()
            sendCodeButton.isEnabled = String.regexTestStringWithPattern(value: curEmailTextField.text, pattern: CommonRegexPatterns.PATTERN_EMAIL)
        }
    }

    @IBAction func onClickUpdateEmail(_: Any) {
        updateEmailButton.isEnabled = false
        BTServiceContainer.getBTAccountService()?.updateEmailWithSecurityCode(newEmail: newEmailTextField.text!, securityCode: securityCodeTextField.text!, respAction: { _, result in
            self.updateEmailButton.isEnabled = true
            if result.code == 200 {
                self.showAlert("BTLocTitleEmailUpdated".localizedBTBaseString, msg: nil, actions: [UIAlertAction(title: "BTLocOK".localizedBTBaseString, style: .default, handler: { _ in
                    self.navigationController?.popViewController(animated: true)
                })])
            } else {
                self.showAlert("BTLocTitleUpdateEmailErr".localizedBTBaseString, msg: ("BTLocMsg\(result.error.msgWithoutSpaces ?? "UnknowErr")").localizedBTBaseString)
            }
        })
    }

    @IBAction func onTextFieldEditingChanged(_ sender: Any) {
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

    @IBAction func onTextFieldEditingDidBegin(_: Any) {
    }

    @IBAction func onTextFieldEditingDidEnd(_: Any) {
    }

    private func onCurrentEmailChanged() {
        if String.regexTestStringWithPattern(value: curEmailTextField.text, pattern: CommonRegexPatterns.PATTERN_EMAIL) {
            sendCodeButton.isEnabled = true
            tipsLabel.text = nil

        } else {
            sendCodeButton.isEnabled = false
            tipsLabel.text = "BTLocMsgInvalidEmail".localizedBTBaseString
        }
    }

    private func onSecurityCodeChanged() {
        if String.regexTestStringWithPattern(value: securityCodeTextField.text, pattern: CommonRegexPatterns.PATTERN_VERIFY_CODE) {
            newEmailTextField.isEnabled = true
            tipsLabel.text = nil
            setCheckTag(securityCodeCheckImage, true)
        } else {
            setCheckTag(securityCodeCheckImage, false)
            newEmailTextField.isEnabled = false
            tipsLabel.text = "BTLocMsgEnterSecurityCode".localizedBTBaseString
        }
    }

    private func onNewEmailChanged() {
        if String.regexTestStringWithPattern(value: newEmailTextField.text, pattern: CommonRegexPatterns.PATTERN_EMAIL) {
            confirmNewEmailTextField.isEnabled = true
            tipsLabel.text = nil
            setCheckTag(confirmNewEmailCheckImage, true)
        } else {
            setCheckTag(confirmNewEmailCheckImage, false)
            confirmNewEmailTextField.isEnabled = false
            tipsLabel.text = "BTLocMsgInvalidNewEmail".localizedBTBaseString
        }
    }

    private func onConfirmNewEmailChanged() {
        if newEmailTextField.text == confirmNewEmailTextField.text {
            updateEmailButton.isEnabled = true
            tipsLabel.text = nil
            setCheckTag(confirmNewEmailCheckImage, true)
        } else {
            updateEmailButton.isEnabled = false
            setCheckTag(confirmNewEmailCheckImage, false)
            tipsLabel.text = "BTLocMsgEmailNotMatch".localizedBTBaseString
        }
    }

    private func setCheckTag(_ check: UIView, _ visible: Bool) {
        check.isHidden = !visible
    }
}
