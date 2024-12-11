//
//  UINavigationItem+Chain.swift
//  FSUIKitSwift
//
//  Created by VincentLee on 2024/12/11.
//

import Foundation

public extension FSUIKitWrapper where Base: UINavigationItem {
    
    @discardableResult
    func title(_ title: String?) -> FSUIKitWrapper {
        base.title = title
        return self
    }
    
    @discardableResult
    func titleView(_ titleView: UIView?) -> FSUIKitWrapper {
        base.titleView = titleView
        return self
    }
    
    @discardableResult
    func leftBarButtonItem(_ leftBarButtonItem: UIBarButtonItem?) -> FSUIKitWrapper {
        base.leftBarButtonItem = leftBarButtonItem
        return self
    }
    
    @discardableResult
    func rightBarButtonItem(_ rightBarButtonItem: UIBarButtonItem?) -> FSUIKitWrapper {
        base.rightBarButtonItem = rightBarButtonItem
        return self
    }
    
    @discardableResult
    func leftBarButtonItems(_ leftBarButtonItems: [UIBarButtonItem]?) -> FSUIKitWrapper {
        base.leftBarButtonItems = leftBarButtonItems
        return self
    }
    
    @discardableResult
    func rightBarButtonItems(_ rightBarButtonItems: [UIBarButtonItem]?) -> FSUIKitWrapper {
        base.rightBarButtonItems = rightBarButtonItems
        return self
    }
}
