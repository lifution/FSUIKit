//
//  UIEdgeInsets+FSUIKit.swift
//  FSUIKit
//
//  Created by Sheng on 2023/12/26.
//  Copyright © 2023 Sheng. All rights reserved.
//

import UIKit

public extension FSUIKitWrapper where Base == UIEdgeInsets {
    
    /// 获取 UIEdgeInsets 在水平方向上的总值。
    func horizontalValue() -> CGFloat {
        return (base.left + base.right)
    }
    
    /// 获取 UIEdgeInsets 在垂直方向上的总值。
    func verticalValue() -> CGFloat {
        return (base.top + base.bottom)
    }
    
    /// 相当于 `UIEdgeInsets + UIEdgeInsets`。
    /// 不使用 '+' 操作符是为了避免冲突。
    func add(_ inset: UIEdgeInsets) -> UIEdgeInsets {
        var newInset = base
        newInset.top    += inset.top
        newInset.left   += inset.left
        newInset.bottom += inset.bottom
        newInset.right  += inset.right
        return newInset
    }
    
    /// 使用一个默认的数值创建一个 UIEdgeInsets。
    ///
    ///     let insets = UIEdgeInsets.fs.create(with: 1.0)
    ///     print(insets) // UIEdgeInsets(top: 1.0, left: 1.0, bottom: 1.0, right: 1.0)
    ///
    static func create(with value: CGFloat) -> UIEdgeInsets {
        return .init(top: value, left: value, bottom: value, right: value)
    }
}
