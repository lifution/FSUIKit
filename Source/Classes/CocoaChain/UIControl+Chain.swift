//
//  UIControl+Chain.swift
//  FSUIKitSwift
//
//  Created by VincentLee on 2024/11/6.
//

import UIKit

public extension FSUIKitWrapper where Base: UIControl {
    
    @discardableResult
    func isEnabled(_ isEnabled: Bool) -> FSUIKitWrapper {
        base.isEnabled = isEnabled
        return self
    }
    
    @discardableResult
    func isSelected(_ isSelected: Bool) -> FSUIKitWrapper {
        base.isSelected = isSelected
        return self
    }
    
    @discardableResult
    func isHighlighted(_ isHighlighted: Bool) -> FSUIKitWrapper {
        base.isHighlighted = isHighlighted
        return self
    }
    
    @discardableResult
    func addTarget(_ target: Any?, action: Selector, for controlEvents: UIControl.Event) -> FSUIKitWrapper {
        base.addTarget(target, action: action, for: controlEvents)
        return self
    }
}
