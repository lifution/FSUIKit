//
//  CGFloatConvertible.swift
//  FSUIKitSwift
//
//  Created by Sheng on 2024/3/13.
//  Copyright © 2024 Sheng. All rights reserved.
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
