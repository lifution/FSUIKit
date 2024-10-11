//
//  UIView+FSUIKitSwift.swift
//  FSUIKitSwift
//
//  Created by Sheng on 2024/3/3.
//

import UIKit

public extension FSUIKitWrapper where Base: UIView {
    
    /// 查找当前 view 所在的 UIViewController。
    var locatedViewController: UIViewController? {
        var next = base.superview
        repeat {
            if let responder = next?.next as? UIViewController {
                return responder
            }
            next = next?.superview
        } while next != nil
        return nil
    }
    
    /// 给当前 view 添加一个左右摆动震动动画
    func shake(shouldFeedback: Bool = true) {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.values = [-20, 20, -20, 20, -10, 10, -5, 5, 0]
        animation.duration = 0.6
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        base.layer.add(animation, forKey: "_kShakeHorizontal")
        if shouldFeedback {
            FSTapticEngine.notification.feedback(.error)
        }
    }
}
