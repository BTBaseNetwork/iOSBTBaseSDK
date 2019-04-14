//
//  LoginedBanner.swift
//  BTBaseSDK
//
//  Created by Alex Chow on 2019/1/11.
//  Copyright © 2019 btbase. All rights reserved.
//

import UIKit

class WelcomeToast: UIView {
    private var iconImageView:UIImageView!
    private var messageLabel:UILabel!
    
    static let toastSize = CGSize(width: 240, height: 48)
    static let toastIconSize = CGSize(width: 32, height: 32)
    static let toastTextSize:CGFloat = 16
    static let toastTextLabelMaxWidth:CGFloat = 168
    static let toastStayDuration:TimeInterval = 2
    static var toastIcon:UIImage?{ return UIImage.BTSDKUIImage(named: "game_service_icon")?.withRenderingMode(.alwaysTemplate) }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = CGRect(origin: CGPoint.zero, size: WelcomeToast.toastSize)
        self.center = CGPoint(x: UIScreen.main.bounds.size.width / 2, y: UIScreen.main.bounds.size.height / 3)
        self.layer.cornerRadius = self.frame.height / 2
        self.backgroundColor = UIColor.darkGray
        iconImageView = UIImageView()
        iconImageView.image = WelcomeToast.toastIcon
        iconImageView.tintColor = BTBaseUIConfig.GlobalTintColor
        self.addSubview(iconImageView)
        iconImageView.frame = CGRect(origin: CGPoint.zero, size: WelcomeToast.toastIconSize)
        messageLabel = UILabel()
        if #available(iOS 8.2, *) {
            messageLabel.font = UIFont.systemFont(ofSize: WelcomeToast.toastTextSize, weight: .medium)
        } else {
            messageLabel.font = UIFont.systemFont(ofSize: WelcomeToast.toastTextSize)
        }
        messageLabel.numberOfLines = 1
        messageLabel.textColor = UIColor.white
        if let nick = BTServiceContainer.getBTAccountService()?.localAccount.nick{
            let msg = String(format:"BTLocWelcomeBackX".localizedBTBaseString,nick)
            messageLabel.text = msg
        }
        messageLabel.sizeToFit()
        if messageLabel.frame.width > WelcomeToast.toastTextLabelMaxWidth {
            var msgFrame = messageLabel.frame
            msgFrame.size.width = WelcomeToast.toastTextLabelMaxWidth
            messageLabel.frame = msgFrame
        }
        self.addSubview(messageLabel)
        
        let centerY = self.frame.height / 2
        let midX = iconImageView.frame.width / 2
        let midWidth = (self.frame.width - iconImageView.frame.width - messageLabel.frame.width - 10) / 2
        let iconCenterX = midX + midWidth
        let msgLabelCenterX = iconCenterX + iconImageView.frame.width / 2 + 10 + messageLabel.frame.width / 2
        
        iconImageView.center = CGPoint(x: iconCenterX, y: centerY)
        messageLabel.center = CGPoint(x: msgLabelCenterX,y: centerY)
    }
    
    static func play() -> Bool{
        if BTBaseSDK.isLogined && !String.isNullOrWhiteSpace(BTServiceContainer.getBTAccountService()?.localAccount?.nick) {
            let toast = WelcomeToast(frame: CGRect.zero)
            toast.alpha = 0
            UIApplication.shared.keyWindow?.addSubview(toast)
            UIView.animate(withDuration: 0.5, animations: {
                toast.alpha = 1
            }) { (_) in
                DispatchQueue.main.afterMS(UInt64(toastStayDuration * 1000), handler: {
                    UIView.animate(withDuration: 0.5, animations: {
                        toast.alpha = 0
                    }, completion: { (_) in
                        toast.removeFromSuperview()
                    })
                })
            }
            return true
        }
        return false
    }
    
}
