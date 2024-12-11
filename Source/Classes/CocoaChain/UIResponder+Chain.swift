//
//  UIResponder+Chain.swift
//  FSUIKitSwift
//
//  Created by VincentLee on 2024/12/11.
//

import Foundation

public extension FSUIKitWrapper where Base: UIResponder {
    
    @discardableResult
    func becomeFirstResponder() -> FSUIKitWrapper {
        base.becomeFirstResponder()
        return self
    }
    
    @discardableResult
    func resignFirstResponder() -> FSUIKitWrapper {
        base.resignFirstResponder()
        return self
    }
}
