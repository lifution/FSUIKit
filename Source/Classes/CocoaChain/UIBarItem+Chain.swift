//
//  UIBarItem+Chain.swift
//  FSUIKitSwift
//
//  Created by VincentLee on 2024/12/11.
//

import Foundation

public extension FSUIKitWrapper where Base: UIBarItem {
    
    @discardableResult
    func isEnabled(_ isEnabled: Bool) -> FSUIKitWrapper {
        base.isEnabled = isEnabled
        return self
    }
    
    @discardableResult
    func titleTextAttributes(_ titleTextAttributes: [NSAttributedString.Key: Any]?,
                             for state: UIControl.State...) -> FSUIKitWrapper {
        state.forEach { base.setTitleTextAttributes(titleTextAttributes, for: $0) }
        return self
    }
}
