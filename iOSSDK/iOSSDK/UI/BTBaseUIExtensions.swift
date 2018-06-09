//
//  BTBaseUIExtensions.swift
//  BTBaseSDK
//
//  Created by Alex Chow on 2018/6/8.
//  Copyright © 2018年 btbase. All rights reserved.
//

import Foundation

public class BTBaseUIStateColorSet {
    private var colorSet = [UInt: UIColor]()
    private var defaultColor: UIColor
    init(defaultColor: UIColor) {
        self.defaultColor = defaultColor
    }

    public func add(state: UIControlState, color: UIColor) -> BTBaseUIStateColorSet {
        self.colorSet[state.rawValue] = color
        return self
    }

    public func colorOf(state: UIControlState) -> UIColor {
        if let c = colorSet[state.rawValue] {
            return c
        }
        return self.defaultColor
    }
}

public class BTBaseUIConfigure {

    // MARK: Global Tint Color

    public var GlobalTintColor = UIColor(hexString: "73FA79")

    // MARK: UIButton

    public var ButtonBackgroundColor = BTBaseUIStateColorSet(defaultColor: UIColor(hexString: "73FA79"))
        .add(state: .disabled, color: UIColor.lightGray)
        .add(state: .highlighted, color: UIColor(hexString: "74FB8A"))

    public var ButtonCornerRadius: CGFloat = 8
    public var ButtonContentInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    public var ButtonHeight: CGFloat = 42
    public var ButtonTitleFontSize: CGFloat = 16

    public var ButtonTitleColor = BTBaseUIStateColorSet(defaultColor: UIColor.darkGray)
        .add(state: .highlighted, color: UIColor.lightGray)
        .add(state: .disabled, color: UIColor.darkGray)

    // MARK: UITextField

    public var TextFieldHeight: CGFloat = 42
    public var TextFieldBorderColor = UIColor.lightGray
    public var TextFieldBorderWidth: CGFloat = 1
    public var TextFieldCornerRadius: CGFloat = 6

    public var TextFieldBackgroundColor = BTBaseUIStateColorSet(defaultColor: UIColor.white.withAlphaComponent(0.1))
        .add(state: .disabled, color: UIColor.darkGray.withAlphaComponent(0.1))

    public var TextFieldTextColor = BTBaseUIStateColorSet(defaultColor: UIColor(hexString: "#eeeeee"))
        .add(state: .disabled, color: UIColor(hexString: "#666666"))

    public var TextFieldPlaceHolderColor = BTBaseUIStateColorSet(defaultColor: UIColor(hexString: "#bbbbbb"))
        .add(state: .disabled, color: UIColor(hexString: "#aaaaaa"))
    // public var TextFieldBackgroundColor = UIColor.white.withAlphaComponent(0.1)
    // public var TextFieldTextColor = UIColor(hexString: "#eeeeee")
    // public var TextFieldPlaceHolderColor = UIColor(hexString: "#bbbbbb")

    // MARK: UIViewController

    public var ViewControllerViewColor = UIColor.darkGray // UIColor(hexString: "#7D8080")
}

var BTBaseUIConfig = BTBaseUIConfigure()

private class BTBaseUIViewObserver: NSObject {
    private var myContext = 0
    fileprivate weak var objectToObserve: NSObject!

    private var keyPath: String

    var onValueChanged: ((_ object: Any) -> Void)?

    required init(objectToObserve: NSObject, keyPath: String) {
        self.keyPath = keyPath
        super.init()
        self.objectToObserve = objectToObserve
        self.objectToObserve.addObserver(self, forKeyPath: keyPath, options: .new, context: &self.myContext)
        BTBaseUIViewObserverManager.regist(observer: self)
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if context == &self.myContext {
            if let _ = change?[NSKeyValueChangeKey.newKey], let obj = object {
                self.onValueChanged?(obj)
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }

    #if DEBUG
    deinit {
        debugLog("BTBaseUIViewObserver Deinited")
    }
    #endif
}

fileprivate class BTBaseUIViewObserverManager {
    static var observers = [BTBaseUIViewObserver]()
    static var firstReigist = true
    static func regist(observer: BTBaseUIViewObserver) {
        if self.firstReigist {
            self.firstReigist = false
            NotificationCenter.default.addObserver(forName: Notification.Name.BTBaseHomeEntryClosed, object: nil, queue: nil) { _ in
                DispatchQueue.main.async {
                    self.gc()
                }
            }
        }
        self.observers.append(observer)
    }

    static func gc() {
        #if DEBUG
        let cnt = (observers.removeElement { $0.objectToObserve == nil }).count
        debugLog("BTBaseUIViewObserverManager GC: %d Observer Deinited", cnt)
        #else
        _ = (self.observers.removeElement { $0.objectToObserve == nil }).count
        #endif
    }
}

extension UIButton {
    public func SetupBTBaseUI() {
        contentEdgeInsets = BTBaseUIConfig.ButtonContentInsets
        backgroundColor = BTBaseUIConfig.ButtonBackgroundColor.colorOf(state: .normal)
        layer.cornerRadius = BTBaseUIConfig.ButtonCornerRadius
        if let height = (constraints.first { $0.firstAttribute == NSLayoutAttribute.height }) {
            height.constant = BTBaseUIConfig.ButtonHeight
        } else {
            let height = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.height, multiplier: 1, constant: BTBaseUIConfig.ButtonHeight)
            addConstraint(height)
        }
        setTitleColor(BTBaseUIConfig.ButtonTitleColor.colorOf(state: .normal), for: .normal)
        setTitleColor(BTBaseUIConfig.ButtonTitleColor.colorOf(state: .highlighted), for: .highlighted)
        setTitleColor(BTBaseUIConfig.ButtonTitleColor.colorOf(state: .disabled), for: .disabled)
        titleLabel?.font = titleLabel!.font.withSize(BTBaseUIConfig.ButtonTitleFontSize)
        self.addTarget(self, action: #selector(self.onButtonPressed(sender:)), for: UIControlEvents.touchDown)
        self.addTarget(self, action: #selector(self.onButtonReleased(sender:)), for: UIControlEvents.touchUpInside)

        let observer = BTBaseUIViewObserver(objectToObserve: self, keyPath: "enabled")
        observer.onValueChanged = { obj in
            if let btn = obj as? UIButton {
                let state = btn.isEnabled ? UIControlState.normal : UIControlState.disabled
                btn.backgroundColor = BTBaseUIConfig.ButtonBackgroundColor.colorOf(state: state)
            }
        }
    }

    @objc private func onButtonPressed(sender: UIButton) {
        backgroundColor = BTBaseUIConfig.ButtonBackgroundColor.colorOf(state: .highlighted)
    }

    @objc private func onButtonReleased(sender: UIButton) {
        backgroundColor = BTBaseUIConfig.ButtonBackgroundColor.colorOf(state: .normal)
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
        backgroundColor = BTBaseUIConfig.TextFieldBackgroundColor.colorOf(state: .normal)
        textColor = BTBaseUIConfig.TextFieldTextColor.colorOf(state: .normal)
        self.setPlaceholderTextColor(color: BTBaseUIConfig.TextFieldPlaceHolderColor.colorOf(state: .normal))
        let observer = BTBaseUIViewObserver(objectToObserve: self, keyPath: "enabled")
        observer.onValueChanged = { obj in
            if let textField = obj as? UITextField {
                let state = textField.isEnabled ? UIControlState.normal : UIControlState.disabled
                textField.backgroundColor = BTBaseUIConfig.TextFieldBackgroundColor.colorOf(state: state)
                textField.textColor = BTBaseUIConfig.TextFieldTextColor.colorOf(state: state)
                textField.setPlaceholderTextColor(color: BTBaseUIConfig.TextFieldPlaceHolderColor.colorOf(state: state))
            }
        }
    }

    private func setPlaceholderTextColor(color: UIColor) {
        setValue(color, forKeyPath: "_placeholderLabel.textColor")
    }
}

extension UIViewController {
    func SetupBTBaseUI() {
        self.view.backgroundColor = BTBaseUIConfig.ViewControllerViewColor
    }
}
