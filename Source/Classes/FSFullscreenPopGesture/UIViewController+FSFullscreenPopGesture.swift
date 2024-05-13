//
//  UIViewController+FSFullscreenPopGesture.swift
//  FSUIKitSwift
//
//  Created by Sheng on 2024/5/10.
//  Copyright © 2024 Sheng. All rights reserved.
//

import UIKit
import ObjectiveC

private struct AssociatedKey {
    static var isInteractivePopEnabled = 0
    static var prefersNavigationBarHidden = 1
    static var interactivePopMaxAllowedInitialDistanceToLeftEdge = 2
}

/// Allows any view controller to disable interactive pop gesture, which might
/// be necessary when the view controller itself handles pan gesture in some
/// cases.
public extension FSUIKitWrapper where Base: UIViewController {
    
    /// Whether the interactive pop gesture is enabled when contained in a navigation stack.
    /// Default to true.
    var isInteractivePopEnabled: Bool {
        get {
            if let value = objc_getAssociatedObject(base, &AssociatedKey.isInteractivePopEnabled) as? Bool {
                return value
            }
            return true
        }
        set { objc_setAssociatedObject(base, &AssociatedKey.isInteractivePopEnabled, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    /// Indicate this view controller prefers its navigation bar hidden or not,
    /// checked when view controller based navigation bar's appearance is enabled.
    /// Default to false, bars are more likely to show.
    var prefersNavigationBarHidden: Bool {
        get {
            if let value = objc_getAssociatedObject(base, &AssociatedKey.prefersNavigationBarHidden) as? Bool {
                return value
            }
            return false
        }
        set { objc_setAssociatedObject(base, &AssociatedKey.prefersNavigationBarHidden, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    /// Max allowed initial distance to left edge when you begin the interactive pop
    /// gesture. 0 by default, which means it will ignore this limit.
    var interactivePopMaxAllowedInitialDistanceToLeftEdge: CGFloat {
        get {
            if let value = objc_getAssociatedObject(base, &AssociatedKey.interactivePopMaxAllowedInitialDistanceToLeftEdge) as? CGFloat {
                return value
            }
            return 0
        }
        set { objc_setAssociatedObject(base, &AssociatedKey.interactivePopMaxAllowedInitialDistanceToLeftEdge, max(0, newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}
