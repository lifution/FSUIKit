//
//  FSVisualEffectView.swift
//  FSUIKitSwift
//
//  Created by Sheng on 2024/2/6.
//  Copyright © 2024 Sheng. All rights reserved.
//
//  Sourced from: https://github.com/efremidze/VisualEffectView
//

import UIKit

/// FSVisualEffectView is a dynamic background blur view.
open class FSVisualEffectView: UIVisualEffectView {
    
    /// Returns the instance of UIBlurEffect.
    private let blurEffect = (NSClassFromString("_UICustomBlurEffect") as! UIBlurEffect.Type).init()
    
    /// Tint color.
    /// The default value is nil.
    open var color: UIColor? {
        get {
            if #available(iOS 14, *) {
                return ios14_colorTint
            } else {
                return _value(forKey: .colorTint)
            }
        }
        set {
            if #available(iOS 14, *) {
                ios14_colorTint = newValue
            } else {
                _setValue(newValue, forKey: .colorTint)
            }
        }
    }
    
    /// Tint color alpha.
    /// Don't use it unless `color` is not nil.
    /// The default value is 0.0.
    open var colorAlpha: CGFloat {
        get { return _value(forKey: .colorTintAlpha) ?? 0.0 }
        set {
            if #available(iOS 14, *) {
                ios14_colorTint = ios14_colorTint?.withAlphaComponent(newValue)
            } else {
                _setValue(newValue, forKey: .colorTintAlpha)
            }
        }
    }
    
    /// Blur radius.
    /// The default value is 0.0.
    open var blurRadius: CGFloat {
        get {
            if #available(iOS 14, *) {
                return ios14_blurRadius
            } else {
                return _value(forKey: .blurRadius) ?? 0.0
            }
        }
        set {
            if #available(iOS 14, *) {
                ios14_blurRadius = newValue
            } else {
                _setValue(newValue, forKey: .blurRadius)
            }
        }
    }
    
    /// Scale factor.
    /// The scale factor determines how content in the view is mapped from the logical
    /// coordinate space (measured in points) to the device coordinate space (measured in pixels).
    /// The default value is 1.0.
    open var scale: CGFloat {
        get { return _value(forKey: .scale) ?? 1.0 }
        set { _setValue(newValue, forKey: .scale) }
    }
    
    // MARK: - Initialization
    
    public override init(effect: UIVisualEffect?) {
        super.init(effect: effect)
        scale = 1
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        scale = 1
    }
}

// MARK: - Private

private extension FSVisualEffectView {
    
    /// Returns the value for the key on the blurEffect.
    func _value<T>(forKey key: Key) -> T? {
        return blurEffect.value(forKeyPath: key.rawValue) as? T
    }
    
    /// Sets the value for the key on the blurEffect.
    func _setValue<T>(_ value: T?, forKey key: Key) {
        blurEffect.setValue(value, forKeyPath: key.rawValue)
        if #unavailable(iOS 14) {
            self.effect = blurEffect
        }
    }
    
    enum Key: String {
        case colorTint, colorTintAlpha, blurRadius, scale
    }
}

// ["grayscaleTintLevel", "grayscaleTintAlpha", "lightenGrayscaleWithSourceOver", "colorTint", "colorTintAlpha", "colorBurnTintLevel", "colorBurnTintAlpha", "darkeningTintAlpha", "darkeningTintHue", "darkeningTintSaturation", "darkenWithSourceOver", "blurRadius", "saturationDeltaFactor", "scale", "zoom"]
