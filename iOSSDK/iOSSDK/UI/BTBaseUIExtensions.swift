//
//  BTBaseUIExtensions.swift
//  BTBaseSDK
//
//  Created by Alex Chow on 2018/6/8.
//  Copyright © 2018年 btbase. All rights reserved.
//

import Foundation

public class BTBaseUIConfig {
    /// MARK: UIButton
    public static var ButtonBackgroundColor = UIColor(hexString: "73FA79")
    public static var ButtonCornerRadius: CGFloat = 8
    public static var ButtonContentInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    public static var ButtonHeight: CGFloat = 48
    public static var ButtonTitleFontSize: CGFloat = 16
    public static var ButtonTitleColor = UIColor.darkGray
}

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
