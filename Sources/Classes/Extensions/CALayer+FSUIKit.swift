//
//  CALayer+FSUIKit.swift
//  FSUIKit
//
//  Created by Sheng on 2023/12/24.
//  Copyright © 2023 Sheng. All rights reserved.
//

import UIKit

public extension FSUIKitWrapper where Base: CALayer {
    
    func removeDefaultAnimations() {
        var actions: [String: CAAction] = [
            NSStringFromSelector(#selector(getter: base.bounds)): NSNull(),
            NSStringFromSelector(#selector(getter: base.position)): NSNull(),
            NSStringFromSelector(#selector(getter: base.zPosition)): NSNull(),
            NSStringFromSelector(#selector(getter: base.anchorPoint)): NSNull(),
            NSStringFromSelector(#selector(getter: base.anchorPointZ)): NSNull(),
            NSStringFromSelector(#selector(getter: base.transform)): NSNull(),
            NSStringFromSelector(#selector(getter: base.isHidden)): NSNull(),
            NSStringFromSelector(#selector(getter: base.isDoubleSided)): NSNull(),
            NSStringFromSelector(#selector(getter: base.sublayerTransform)): NSNull(),
            NSStringFromSelector(#selector(getter: base.masksToBounds)): NSNull(),
            NSStringFromSelector(#selector(getter: base.contents)): NSNull(),
            NSStringFromSelector(#selector(getter: base.contentsRect)): NSNull(),
            NSStringFromSelector(#selector(getter: base.contentsScale)): NSNull(),
            NSStringFromSelector(#selector(getter: base.contentsCenter)): NSNull(),
            NSStringFromSelector(#selector(getter: base.minificationFilterBias)): NSNull(),
            NSStringFromSelector(#selector(getter: base.backgroundColor)): NSNull(),
            NSStringFromSelector(#selector(getter: base.cornerRadius)): NSNull(),
            NSStringFromSelector(#selector(getter: base.borderWidth)): NSNull(),
            NSStringFromSelector(#selector(getter: base.borderColor)): NSNull(),
            NSStringFromSelector(#selector(getter: base.opacity)): NSNull(),
            NSStringFromSelector(#selector(getter: base.compositingFilter)): NSNull(),
            NSStringFromSelector(#selector(getter: base.filters)): NSNull(),
            NSStringFromSelector(#selector(getter: base.backgroundFilters)): NSNull(),
            NSStringFromSelector(#selector(getter: base.shouldRasterize)): NSNull(),
            NSStringFromSelector(#selector(getter: base.rasterizationScale)): NSNull(),
            NSStringFromSelector(#selector(getter: base.shadowColor)): NSNull(),
            NSStringFromSelector(#selector(getter: base.shadowOpacity)): NSNull(),
            NSStringFromSelector(#selector(getter: base.shadowOffset)): NSNull(),
            NSStringFromSelector(#selector(getter: base.shadowRadius)): NSNull(),
            NSStringFromSelector(#selector(getter: base.shadowPath)): NSNull()
        ]
        if base is CAShapeLayer {
            let actions_: [String: CAAction] = [
                NSStringFromSelector(#selector(getter: CAShapeLayer.path)): NSNull(),
                NSStringFromSelector(#selector(getter: CAShapeLayer.fillColor)): NSNull(),
                NSStringFromSelector(#selector(getter: CAShapeLayer.strokeColor)): NSNull(),
                NSStringFromSelector(#selector(getter: CAShapeLayer.strokeStart)): NSNull(),
                NSStringFromSelector(#selector(getter: CAShapeLayer.strokeEnd)): NSNull(),
                NSStringFromSelector(#selector(getter: CAShapeLayer.lineWidth)): NSNull(),
                NSStringFromSelector(#selector(getter: CAShapeLayer.miterLimit)): NSNull(),
                NSStringFromSelector(#selector(getter: CAShapeLayer.lineDashPhase)): NSNull()
            ]
            actions.merge(actions_) { (first, _) in first }
        }
        if base is CAGradientLayer {
            let actions_: [String: CAAction] = [
                NSStringFromSelector(#selector(getter: CAGradientLayer.colors)): NSNull(),
                NSStringFromSelector(#selector(getter: CAGradientLayer.locations)): NSNull(),
                NSStringFromSelector(#selector(getter: CAGradientLayer.startPoint)): NSNull(),
                NSStringFromSelector(#selector(getter: CAGradientLayer.endPoint)): NSNull()
            ]
            actions.merge(actions_) { (first, _) in first }
        }
        base.actions = actions
    }
}
