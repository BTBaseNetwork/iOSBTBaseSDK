//
//  UpdateNickViewController.swift
//  BTBaseSDK
//
//  Created by Alex Chow on 2018/6/4.
//  Copyright © 2018年 btbase. All rights reserved.
//

import UIKit

class UpdateNickViewController: UIViewController {
    @IBOutlet var updateNickButton: UIButton! { didSet { updateNickButton.SetupBTBaseUI() } }
    @IBOutlet var newNickTextField: UITextField! { didSet { newNickTextField.SetupBTBaseUI() } }

    @IBOutlet var newNickCheckImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        SetupBTBaseUI()
        for textField in [newNickTextField] {
            textField?.addTarget(self, action: #selector(onTextFieldEditingDidBegin(sender:)), for: UIControlEvents.editingDidBegin)
            textField?.addTarget(self, action: #selector(onTextFieldEditingChanged(sender:)), for: UIControlEvents.editingChanged)
            textField?.addTarget(self, action: #selector(onTextFieldEditingDidEnd(sender:)), for: UIControlEvents.editingDidEnd)
        }
        newNickCheckImage.isHidden = true
        newNickCheckImage.tintColor = BTBaseUIConfig.GlobalTintColor
        updateNickButton.isEnabled = false
        newNickTextField.isEnabled = true
    }

    @IBAction func onClickUpdateNick(_: Any) {
        updateNickButton.isEnabled = false
        newNickTextField.isEnabled = false
        BTServiceContainer.getBTAccountService()?.updateNick(newNick: newNickTextField.trimText!, respAction: { _, result in
            if result.isHttpOK {
                self.showAlert("BTLocTitleUpdateNickSuc".localizedBTBaseString, msg: nil, actions: [UIAlertAction(title: "BTLocOK".localizedBTBaseString, style: .default, handler: { _ in
                    self.navigationController?.popViewController(animated: true)
                })])
            } else {
                self.newNickTextField.isEnabled = true
                self.updateNickButton.isEnabled = true
                let msg = result.error != nil ? result.error.msgWithoutSpaces : "UnknowErr"
                self.showAlert("BTLocTitleUpdateNickErr".localizedBTBaseString, msg: "BTLocMsg\(msg)".localizedBTBaseString)
            }
        })
    }

    @objc private func onTextFieldEditingChanged(sender: Any) {
        if String.regexTestStringWithPattern(value: newNickTextField.trimText, pattern: CommonRegexPatterns.PATTERN_CHINESE_NICK) {
            newNickCheckImage.isHidden = false
            updateNickButton.isEnabled = true
        } else {
            newNickCheckImage.isHidden = true
            updateNickButton.isEnabled = false
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
