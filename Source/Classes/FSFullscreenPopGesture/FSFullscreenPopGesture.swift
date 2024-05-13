//
//  FSFullscreenPopGesture.swift
//  FSUIKitSwift
//
//  Created by Sheng on 2024/5/10.
//  Copyright © 2024 Sheng. All rights reserved.
//

import UIKit
import ObjectiveC

private struct AssociatedKey {
    static var willAppearInjection = 0
    static var popGestureRecognizerDelegate = 1
}

fileprivate typealias _FSViewControllerWillAppearInjectHandler = (_ viewController: UIViewController, _ animated: Bool) -> Void

// MARK: - Extension/UIViewController

extension UIViewController {
    
    // MARK: Properties/Fileprivate
    
    fileprivate var willAppearInjectHandler: _FSViewControllerWillAppearInjectHandler? {
        get { return objc_getAssociatedObject(self, &AssociatedKey.willAppearInjection) as? _FSViewControllerWillAppearInjectHandler }
        set { objc_setAssociatedObject(self, &AssociatedKey.willAppearInjection, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC) }
    }
    
    // MARK: Internal
    
    static func fullscreenPop_swizzling() {
        if let originalMethod = class_getInstanceMethod(self, #selector(viewWillAppear(_:))),
           let swizzledMethod = class_getInstanceMethod(self, #selector(fullscreenPop_viewWillAppear(_:))) {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
        if let originalMethod = class_getInstanceMethod(self, #selector(viewWillDisappear(_:))),
           let swizzledMethod = class_getInstanceMethod(self, #selector(fullscreenPop_viewWillDisappear(_:))) {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }
    
    // MARK: Private
    
    @objc
    private func fullscreenPop_viewWillAppear(_ animated: Bool) {
        fullscreenPop_viewWillAppear(animated)
        willAppearInjectHandler?(self, animated)
    }
    
    @objc
    private func fullscreenPop_viewWillDisappear(_ animated: Bool) {
        fullscreenPop_viewWillDisappear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            if let viewController = self.navigationController?.viewControllers.last, !viewController.fs.prefersNavigationBarHidden {
                self.navigationController?.setNavigationBarHidden(false, animated: false)
            }
        }
    }
}

// MARK: - Extension/UINavigationController

extension UINavigationController {
    
    // MARK: Properties/Private
    
    private var popGestureRecognizerDelegate: FSFullscreenPopGestureRecognizerDelegate {
        if let delegate = objc_getAssociatedObject(self, &AssociatedKey.popGestureRecognizerDelegate) as? FSFullscreenPopGestureRecognizerDelegate {
            return delegate
        }
        let delegate = FSFullscreenPopGestureRecognizerDelegate(navigationController: self)
        objc_setAssociatedObject(self, &AssociatedKey.popGestureRecognizerDelegate, delegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return delegate
    }
    
    // MARK: Internal
    
    static func nc_fullscreenPop_swizzling() {
        let originalSelector = #selector(pushViewController(_:animated:))
        let swizzledSelector = #selector(fullscreenPop_pushViewController(_:animated:))
        guard
            let originalMethod = class_getInstanceMethod(self, originalSelector),
            let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
        else {
            return
        }
        if class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod)) {
            class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }
    
    // MARK: Private
    
    @objc
    private func fullscreenPop_pushViewController(_ viewController: UIViewController, animated: Bool) {
        if let interactivePopGestureRecognizer = interactivePopGestureRecognizer,
           let view = interactivePopGestureRecognizer.view,
           !(view.gestureRecognizers?.contains(where: { $0 === fs.fullscreenPopGestureRecognizer }) ?? false) {
            
            // Add our own gesture recognizer to where the onboard screen edge pan gesture recognizer is attached to.
            view.addGestureRecognizer(fs.fullscreenPopGestureRecognizer)
            fs.fullscreenPopGestureRecognizer.delegate = popGestureRecognizerDelegate
            
            // Forward the gesture events to the private handler of the onboard gesture recognizer.
            if let internalTargets = interactivePopGestureRecognizer.value(forKey: "targets") as? [NSObject],
               let target = internalTargets.first,
               let internalTarget = target.value(forKey: "target") {
                let internalAction = NSSelectorFromString("handleNavigationTransition:")
                fs.fullscreenPopGestureRecognizer.addTarget(internalTarget, action: internalAction)
            }
            
            // Disable the onboard gesture recognizer.
            interactivePopGestureRecognizer.isEnabled = false
        }
        
        // Handle perferred navigation bar appearance.
        p_setupViewControllerBasedNavigationBarAppearanceIfNeeded(viewController)
        
        // Forward to primary implementation.
        if !viewControllers.contains(where: { $0 === viewController }) {
            fullscreenPop_pushViewController(viewController, animated: animated)
        }
    }
    
    private func p_setupViewControllerBasedNavigationBarAppearanceIfNeeded(_ appearingViewController: UIViewController) {
        guard fs.isViewControllerBasedNavigationBarAppearanceEnabled else {
            return
        }
        let handler: _FSViewControllerWillAppearInjectHandler = { [weak self] (viewController, animated) in
            guard let self = self else { return }
            self.setNavigationBarHidden(viewController.fs.prefersNavigationBarHidden, animated: animated)
        }
        // Setup will appear inject block to appearing view controller.
        // Setup disappearing view controller as well, because not every view controller is added into
        // stack by pushing, maybe by "-setViewControllers:".
        appearingViewController.willAppearInjectHandler = handler
        if let disappearingViewController = viewControllers.last, disappearingViewController.willAppearInjectHandler == nil {
            disappearingViewController.willAppearInjectHandler = handler
        }
    }
}
