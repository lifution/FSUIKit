//
//  FSFullscreenPopGestureRecognizerDelegate.swift
//  FSUIKitSwift
//
//  Created by Sheng on 2024/5/11.
//  Copyright © 2024 Sheng. All rights reserved.
//

import UIKit

/// Simultaneously with other gesture recognizer.
/// Example:
/// ```
/// func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
///     if contentOffset.x <= 0, otherGestureRecognizer.delegate is FSFullscreenPopGestureRecognizerDelegate {
///         return true
///     }
///     return false
/// }
/// ```
public final class FSFullscreenPopGestureRecognizerDelegate: NSObject, UIGestureRecognizerDelegate {
    
    // MARK: Properties/Fileprivate
    
    weak var navigationController: UINavigationController?
    
    // MARK: Initialization
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        super.init()
    }
    
    // MARK: UIGestureRecognizerDelegate
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        guard let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer else {
            return false
        }
        
        guard let navigationController else {
            return false
        }
        
        // Ignore when no view controller is pushed into the navigation stack.
        guard navigationController.viewControllers.count > 1 else {
            return false
        }
        
        guard let topViewController = navigationController.viewControllers.last else {
            return false
        }
        
        // Ignore when the active view controller doesn't allow interactive pop.
        if !topViewController.fs.isInteractivePopEnabled {
            return false
        }
        
        // Ignore when the beginning location is beyond max allowed initial distance to left edge.
        let beginningLocation = panGestureRecognizer.location(in: panGestureRecognizer.view)
        let maxAllowedInitialDistance = topViewController.fs.interactivePopMaxAllowedInitialDistanceToLeftEdge
        if maxAllowedInitialDistance > 0, beginningLocation.x > maxAllowedInitialDistance {
            return false
        }
        
        // Ignore pan gesture when the navigation controller is currently in transition.
        if let isTransitioning = navigationController.value(forKey: "_isTransitioning") as? Bool, isTransitioning {
            return false
        }
        
        // Prevent calling the handler when the gesture begins in an opposite direction.
        let translation = panGestureRecognizer.translation(in: panGestureRecognizer.view)
        let isLeftToRight = UIApplication.shared.userInterfaceLayoutDirection == .leftToRight
        let multiplier: CGFloat = isLeftToRight ? 1 : -1
        if translation.x * multiplier <= 0 {
            return false
        }
        
        return true
    }
}
