//
//  FSToastAnimation.swift
//  FSUIKit
//
//  Created by Sheng on 2024/2/6.
//  Copyright © 2024 Sheng. All rights reserved.
//

import UIKit

/// FSUIKit 提供的默认 FSToast 动画。
open class FSToastAnimation: FSToastAnimatedTransitioning {
    
    public enum Kind {
        case fade
        case scale
        case slideDown
        case slideUp
    }
    
    // MARK: Properties/Open
    
    open var duration: TimeInterval = 0.38
    
    // MARK: Properties/Public
    
    public let kind: FSToastAnimation.Kind
    
    // MARK: Initialization
    
    public init(kind: FSToastAnimation.Kind = .fade) {
        self.kind = kind
    }
    
    // MARK: <FSToastAnimatedTransitioning>
    
    open func presentingAnimationBehavior(for toastView: UIView, in containerView: UIView, completion: (() -> Void)?) {
        
        var animations: (() -> Void)?
        
        switch kind {
        case .fade:
            do {
                toastView.alpha = 0.0
                animations = {
                    toastView.alpha = 1.0
                }
            }
        case .scale:
            do {
                toastView.alpha = 0.0
                toastView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                animations = {
                    toastView.alpha = 1.0
                    toastView.transform = .identity
                }
            }
        case .slideDown:
            do {
                toastView.alpha = 0.0
                toastView.transform = CGAffineTransform(translationX: 0.0, y: -20.0)
                animations = {
                    toastView.alpha = 1.0
                    toastView.transform = .identity
                }
            }
        case .slideUp:
            do {
                toastView.alpha = 0.0
                toastView.transform = CGAffineTransform(translationX: 0.0, y: 20.0)
                animations = {
                    toastView.alpha = 1.0
                    toastView.transform = .identity
                }
            }
        }
        
        if let animations = animations {
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: duration,
                                                           delay: 0.0,
                                                           options: .curveEaseOut,
                                                           animations: animations) { _ in
                completion?()
            }
        } else {
            completion?()
        }
    }
    
    open func dismissingAnimationBehavior(for toastView: UIView, in containerView: UIView, completion: (() -> Void)?) {
        
        var animations: (() -> Void)?
        
        switch kind {
        case .fade:
            do {
                animations = {
                    toastView.alpha = 0.0
                }
            }
        case .scale:
            do {
                animations = {
                    toastView.alpha = 0.0
                    toastView.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
                }
            }
        case .slideDown:
            do {
                animations = {
                    toastView.alpha = 0.0
                    toastView.transform = CGAffineTransform(translationX: 0.0, y: -20.0)
                }
            }
        case .slideUp:
            do {
                animations = {
                    toastView.alpha = 0.0
                    toastView.transform = CGAffineTransform(translationX: 0.0, y: 20.0)
                }
            }
        }
        
        if let animations = animations {
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: duration,
                                                           delay: 0.0,
                                                           options: .curveEaseOut,
                                                           animations: animations) { _ in
                completion?()
            }
        } else {
            completion?()
        }
    }
}
