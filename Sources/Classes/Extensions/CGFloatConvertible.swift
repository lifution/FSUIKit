//
//  CGFloatConvertible.swift
//  FSUIKit
//
//  Created by Sheng on 2024/3/13.
//

import CoreGraphics

public extension FSUIKitWrapper where Base: BinaryInteger {
    
    var cgFloat: CGFloat {
        return CGFloat(base)
    }
}

public extension FSUIKitWrapper where Base: BinaryFloatingPoint {
    
    var cgFloat: CGFloat {
        return CGFloat(base)
    }
}
