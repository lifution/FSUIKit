//
//  UINavigationController+FSFullscreenPopGesture.swift
//  FSUIKitSwift
//
//  Created by Sheng on 2024/5/10.
//  Copyright © 2024 Sheng. All rights reserved.
//

import UIKit
import ObjectiveC

private struct AssociatedKey {
    static var fullscreenPopGestureRecognizer = 0
    static var isViewControllerBasedNavigationBarAppearanceEnabled = 1
}

/// "UINavigation+FSFullscreenPopGesture" extends UINavigationController's swipe-
/// to-pop behavior in iOS 7+ by supporting fullscreen pan gesture. Instead of
/// screen edge, you can now swipe from any place on the screen and the onboard
/// interactive pop transition works seamlessly.
///
/// Adding the implementation file of this category to your target will
/// automatically patch UINavigationController with this feature.
public extension FSUIKitWrapper where Base: UINavigationController {
    
    /// The gesture recognizer that actually handles interactive pop.
    var fullscreenPopGestureRecognizer: UIPanGestureRecognizer {
        if let pan = objc_getAssociatedObject(base, &AssociatedKey.fullscreenPopGestureRecognizer) as? UIPanGestureRecognizer {
            return pan
        }
        let pan = UIPanGestureRecognizer()
        pan.maximumNumberOfTouches = 1
        objc_setAssociatedObject(base, &AssociatedKey.fullscreenPopGestureRecognizer, pan, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return pan
    }
    
    /// A view controller is able to control navigation bar's appearance by itself,
    /// rather than a global way, checking "prefersNavigationBarHidden" property.
    /// Default to true, disable it if you don't want so.
    var isViewControllerBasedNavigationBarAppearanceEnabled: Bool {
        get {
            if let value = objc_getAssociatedObject(base, &AssociatedKey.isViewControllerBasedNavigationBarAppearanceEnabled) as? Bool {
                return value
            }
            return true
        }
        set { objc_setAssociatedObject(base, &AssociatedKey.isViewControllerBasedNavigationBarAppearanceEnabled, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}
