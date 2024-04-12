//
//  FSKeyboardTransition.swift
//  FSUIKitSwift
//
//  Created by Sheng on 2024/1/19.
//  Copyright © 2024 Sheng. All rights reserved.
//

import UIKit

/**
 System keyboard transition information.
 Use `FSKeyboardManager.shared.convert(_:to:)` to convert frame to specified view.
 */
public struct FSKeyboardTransition {
    
    /// Keyboard visible before transition.
    public var isFromVisible = false
    
    /// Keyboard visible after transition.
    public var isToVisible = false
    
    /// Keyboard frame before transition.
    public var fromFrame: CGRect = .zero
    
    /// Keyboard frame after transition.
    public var toFrame: CGRect = .zero
    
    /// Keyboard transition animation duration.
    public var animationDuration: TimeInterval = 0.0
    
    /// Keyboard transition animation curve.
    public var animationCurve: UIView.AnimationCurve = .easeInOut
    
    /// Keybaord transition animation option.
    public var animationOption: UIView.AnimationOptions = []
    
    public init() {}
}
