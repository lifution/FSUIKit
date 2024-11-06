//
//  UIBarButtonItem+Chain.swift
//  FSUIKitSwift
//
//  Created by VincentLee on 2024/11/6.
//

import UIKit

public extension FSUIKitWrapper where Base: UIBarButtonItem {
    
    @discardableResult
    func width(_ width: CGFloat) -> FSUIKitWrapper {
        base.width = width
        return self
    }
    
    @discardableResult
    func tintColor(_ tintColor: UIColor?) -> FSUIKitWrapper {
        base.tintColor = tintColor
        return self
    }
}
