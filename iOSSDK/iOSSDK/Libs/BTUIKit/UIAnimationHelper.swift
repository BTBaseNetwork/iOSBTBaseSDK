//
//  UIAnimationHelper.swift
//  iDiaries
//
//  Created by AlexChow on 15/12/6.
//  Copyright © 2015年 GStudio. All rights reserved.
//

import QuartzCore
import UIKit

typealias AnimationCompletedHandler = () -> Void

fileprivate class UIViewCAAnimationDelegate: NSObject, CAAnimationDelegate {
    var handler: AnimationCompletedHandler?

    public func animationDidStop(_: CAAnimation, finished _: Bool) {
        if let dg = UIAnimationHelper.instance.animationCompleted.remove(self) {
            dg.handler?()
        }
    }
}

extension UIView {
    func startFlash(_ duration: TimeInterval = 0.8) {
        UIAnimationHelper.flashView(self, duration: duration)
    }

    func stopFlash() {
        UIAnimationHelper.stopFlashView(self)
    }

    func shakeAnimationForView(_ repeatTimes: Float = 3, completion: AnimationCompletedHandler! = nil) {
        UIAnimationHelper.shakeAnimationForView(self, repeatTimes: repeatTimes, completion: completion)
    }

    func animationMaxToMin(_ duration: Double = 0.2, maxScale: CGFloat = 1.1, repeatCount: Float = 0, completion: AnimationCompletedHandler! = nil) {
        UIAnimationHelper.animationMaxToMin(self, duration: duration, maxScale: maxScale, repeatCount: repeatCount, completion: completion)
    }
}

class UIAnimationHelper {
    fileprivate var animationCompleted = Set<UIViewCAAnimationDelegate>()
    fileprivate static let instance = UIAnimationHelper()

    static func animationPageCurlView(_ view: UIView, duration: TimeInterval, completion: AnimationCompletedHandler! = nil) {
        // 获取到当前的View

        let viewLayer = view.layer

        // 设置动画

        let animation = CATransition()

        animation.duration = duration

        animation.type = convertToCATransitionType("pageCurl")

        animation.subtype = CATransitionSubtype.fromBottom

        // 添加上动画
        viewLayer.add(animation, forKey: nil)

        playAnimation(view, animation: animation, key: "animationPageCurl", completion: completion)
    }

    static func shakeAnimationForView(_ view: UIView, repeatTimes: Float, completion: AnimationCompletedHandler! = nil) {
        // 获取到当前的View

        let viewLayer = view.layer

        // 获取当前View的位置

        let position: CGPoint = viewLayer.position

        // 移动的两个终点位置

        let a = CGPoint(x: position.x + 10, y: position.y)

        let b = CGPoint(x: position.x - 10, y: position.y)

        // 设置动画

        let animation = CABasicAnimation(keyPath: "position")
        // 设置运动形式
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.default)

        // 设置开始位置
        animation.fromValue = NSValue(cgPoint: a)

        // 设置结束位置
        animation.toValue = NSValue(cgPoint: b)

        // 设置自动反转
        animation.autoreverses = true

        // 设置时间
        animation.duration = 0.05

        // 设置次数
        animation.repeatCount = repeatTimes

        // 添加上动画
        viewLayer.add(animation, forKey: nil)

        playAnimation(view, animation: animation, key: "shakeAnimationForView", completion: completion)
    }

    static func flyToTopForView(_ startPosition: CGPoint, view: UIView, completion: AnimationCompletedHandler! = nil) {
        // 获取到当前的View

        let viewLayer = view.layer

        // 获取当前View的位置

        let position: CGPoint = viewLayer.position

        // 移动的两个终点位置

        let a = startPosition

        let b = CGPoint(x: position.x, y: -10)

        // 设置动画

        let animation = CABasicAnimation(keyPath: "position")
        // 设置运动形式
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.default)

        // 设置开始位置
        animation.fromValue = NSValue(cgPoint: a)

        // 设置结束位置
        animation.toValue = NSValue(cgPoint: b)

        // 设置时间
        animation.duration = 1

        playAnimation(view, animation: animation, key: "flyToTopForView", completion: completion)
    }

    static func animationMaxToMin(_ view: UIView, duration: Double, maxScale: CGFloat, repeatCount: Float = 0, completion: AnimationCompletedHandler! = nil) {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.fromValue = 1.0
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation.toValue = maxScale
        animation.duration = duration
        animation.repeatCount = repeatCount
        animation.autoreverses = true
        animation.isRemovedOnCompletion = true
        animation.fillMode = CAMediaTimingFillMode.forwards
        playAnimation(view, animation: animation, key: "animationMaxToMin", completion: completion)
    }

    static func playAnimation(_ view: UIView, animation: CAAnimation, key: String? = nil, completion: AnimationCompletedHandler! = nil) {
        let dg = UIViewCAAnimationDelegate()
        dg.handler = completion
        UIAnimationHelper.instance.animationCompleted.insert(dg)
        animation.delegate = dg
        view.layer.add(animation, forKey: key)
    }

    static func flashView(_ view: UIView, duration: TimeInterval = 0.8, autoStop: Bool = false, stopAfterMs: UInt64 = 3000, completion: AnimationCompletedHandler! = nil) {
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 1.0
        animation.toValue = 0.0
        animation.autoreverses = true
        animation.duration = duration
        animation.repeatCount = MAXFLOAT
        animation.isRemovedOnCompletion = false
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        view.layer.add(animation, forKey: "Flash")
        if autoStop {
            let time = DispatchTime.now() + Double(NSNumber(value: NSEC_PER_MSEC * stopAfterMs as UInt64).int64Value) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: time, execute: {
                stopFlashView(view)
                completion?()
            })
        }
    }

    static func stopFlashView(_ view: UIView) {
        view.layer.removeAnimation(forKey: "Flash")
    }
}

extension CAAnimation {
    func setStorePropertyOnComplete() {
        isRemovedOnCompletion = false
        fillMode = CAMediaTimingFillMode.forwards
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToCATransitionType(_ input: String) -> CATransitionType {
	return CATransitionType(rawValue: input)
}
