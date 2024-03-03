//
//  UIView+FSUIKit.swift
//  FSUIKit
//
//  Created by Sheng on 2024/3/3.
//

import UIKit

public extension FSUIKitWrapper where Base: UIView {
    
    /// 查找当前 view 所在的 UIViewController。
    var locatedViewController: UIViewController? {
        var next = base.superview
        repeat {
            if let responder = next?.next as? UIViewController {
                return responder
            }
            next = next?.superview
        } while next != nil
        return nil
    }
}
