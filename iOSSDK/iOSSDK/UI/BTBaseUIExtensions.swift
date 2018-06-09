//
//  BTBaseUIExtensions.swift
//  BTBaseSDK
//
//  Created by Alex Chow on 2018/6/8.
//  Copyright © 2018年 btbase. All rights reserved.
//

import Foundation

public class BTBaseUIConfigure {

    // MARK: UIButton

    public var ButtonBackgroundColor = UIColor(hexString: "73FA79")
    public var ButtonCornerRadius: CGFloat = 8
    public var ButtonContentInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    public var ButtonHeight: CGFloat = 42
    public var ButtonTitleFontSize: CGFloat = 16
    public var ButtonTitleColor = UIColor.darkGray

    // MARK: UITextField

    public var TextFieldHeight: CGFloat = 42
    public var TextFieldBorderColor = UIColor.lightGray
    public var TextFieldBorderWidth: CGFloat = 1
    public var TextFieldCornerRadius: CGFloat = 6

    public var TextFieldBackgroundColor = UIColor.white.withAlphaComponent(0.1)
    public var TextFieldTextColor = UIColor(hexString: "#eeeeee")
    public var TextFieldPlaceHolderColor = UIColor(hexString: "#bbbbbb")

    // MARK: UIViewController

    public var ViewControllerViewColor = UIColor.darkGray // UIColor(hexString: "#7D8080")
}

var BTBaseUIConfig = BTBaseUIConfigure()

extension UIButton {
    func SetupBTBaseUI() {
        contentEdgeInsets = BTBaseUIConfig.ButtonContentInsets
        backgroundColor = BTBaseUIConfig.ButtonBackgroundColor
        layer.cornerRadius = BTBaseUIConfig.ButtonCornerRadius
        if let height = (constraints.first { $0.firstAttribute == NSLayoutAttribute.height }) {
            height.constant = BTBaseUIConfig.ButtonHeight
        } else {
            let height = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.height, multiplier: 1, constant: BTBaseUIConfig.ButtonHeight)
            addConstraint(height)
        }
        setTitleColor(BTBaseUIConfig.ButtonTitleColor, for: .normal)
        titleLabel?.font = titleLabel!.font.withSize(BTBaseUIConfig.ButtonTitleFontSize)
    }
}

extension UITextField {
    func SetupBTBaseUI() {
        if let height = (constraints.first { $0.firstAttribute == NSLayoutAttribute.height }) {
            height.constant = BTBaseUIConfig.TextFieldHeight
        } else {
            let height = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.height, multiplier: 1, constant: BTBaseUIConfig.TextFieldHeight)
            addConstraint(height)
        }
        layer.borderColor = BTBaseUIConfig.TextFieldBorderColor.cgColor
        layer.borderWidth = BTBaseUIConfig.TextFieldBorderWidth
        layer.cornerRadius = BTBaseUIConfig.TextFieldCornerRadius
        backgroundColor = BTBaseUIConfig.TextFieldBackgroundColor
        textColor = BTBaseUIConfig.TextFieldTextColor
        setValue(BTBaseUIConfig.TextFieldPlaceHolderColor, forKeyPath: "_placeholderLabel.textColor")
    }
}

extension UIViewController {
    func SetupBTBaseUI() {
        self.view.backgroundColor = BTBaseUIConfig.ViewControllerViewColor
    }
}
