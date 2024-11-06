//
//  HasFont+Chain.swift
//  FSUIKitSwift
//
//  Created by VincentLee on 2024/11/6.
//

import UIKit

public extension FSUIKitWrapper where Base: FSUIKitHasFont {
    
    @discardableResult
    func font(_ font: UIFont) -> FSUIKitWrapper {
        base.fs_set(font: font)
        return self
    }
    
    @discardableResult
    func systemFont(ofSize fontSize: CGFloat) -> FSUIKitWrapper {
        base.fs_set(font: UIFont.systemFont(ofSize: fontSize))
        return self
    }
    
    @discardableResult
    func boldSystemFont(ofSize fontSize: CGFloat) -> FSUIKitWrapper {
        base.fs_set(font: UIFont.boldSystemFont(ofSize: fontSize))
        return self
    }
    
    @discardableResult
    func systemFont(ofSize fontSize: CGFloat, weight: UIFont.Weight) -> FSUIKitWrapper {
        base.fs_set(font: UIFont.systemFont(ofSize: fontSize, weight: weight))
        return self
    }
}
