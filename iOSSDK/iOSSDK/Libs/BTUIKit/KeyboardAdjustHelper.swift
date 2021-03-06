//
//  KeyboardAdjustHelper.swift
//  Bahamut
//
//  Created by AlexChow on 15/12/2.
//  Copyright © 2015年 GStudio. All rights reserved.
//

import Foundation
import UIKit

// MARK: Keyboard

extension UIViewController {
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        hideKeyBoard()
    }

    func hideKeyBoard() {
        if let v = self.view {
            DispatchQueue.main.async(execute: { () -> Void in
                v.endEditing(false)
            })
        }
    }
}

class ControllerViewAdjustByKeyboardProxy: NSObject {
    fileprivate weak var controller: UIViewController!

    init(controller: UIViewController) {
        self.controller = controller
    }

    func removeObserverForKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self)
    }

    func registerForKeyboardNotifications(_ views: [UIView]) {
        keyBoardAdjuetResponderViews = views
        NotificationCenter.default.addObserver(self, selector: #selector(ControllerViewAdjustByKeyboardProxy.keyboardChanged(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ControllerViewAdjustByKeyboardProxy.keyboardChanged(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    fileprivate var keyBoardAdjuetResponderViews = [UIView]()

    fileprivate var offset: CGFloat = 0
    @objc func keyboardChanged(_ aNotification: Notification) {
        if let userInfo = aNotification.userInfo {
            if let responderView = (keyBoardAdjuetResponderViews.filter { $0.isFirstResponder }.first) {
                adjustViewAdaptKeyboard(aNotification.name, userInfo: userInfo, responderView: responderView)
            }
        }
    }

    var viewOriginHeight: CGFloat!

    fileprivate func adjustViewAdaptKeyboard(_ keyboardNotification: NSNotification.Name, userInfo: [AnyHashable: Any], responderView: UIView) {
        if viewOriginHeight == nil {
            viewOriginHeight = controller.view.frame.size.height
        }
        let info = userInfo
        if !responderView.isFirstResponder {
            return
        }
        if let kbFrame = (info[UIResponder.keyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue {
            let tfFrame = responderView.frame

            if keyboardNotification == UIResponder.keyboardDidShowNotification {
                offset = tfFrame.origin.y + tfFrame.size.height + 7 - kbFrame.origin.y
                if offset <= 0 {
                    return
                }
                var animationDuration: TimeInterval
                var animationCurve: UIView.AnimationCurve
                let curve = info[UIResponder.keyboardAnimationCurveUserInfoKey] as! Int
                animationCurve = UIView.AnimationCurve(rawValue: curve)!
                animationDuration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
                UIView.beginAnimations(nil, context: nil)
                UIView.setAnimationDuration(animationDuration)
                UIView.setAnimationCurve(animationCurve)
                for c in responderView.constraints {
                    if c.firstAttribute == .bottom && (c.firstItem as! NSObject == controller.view || c.secondItem as! NSObject == controller.view) {
                        c.constant = c.constant + offset
                    }
                }
                // controller.view.frame.size.height = viewOriginHeight - offset

                controller.view.layoutIfNeeded()
                UIView.commitAnimations()
            } else {
                if offset <= 0 {
                    return
                }
                responderView.constraints.forEach({ (c) -> Void in
                    if c.firstAttribute == .bottom && (c.firstItem as! NSObject == controller.view || c.secondItem as! NSObject == controller.view) {
                        c.constant = c.constant - offset
                    }
                })
                // controller.view.frame.size.height = viewOriginHeight
                controller.view.layoutIfNeeded()
            }
        }
    }
}
