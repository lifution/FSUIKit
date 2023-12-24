//
//  CoreGraphics+FSUIKit.swift
//  FSUIKit
//
//  Created by Sheng on 2023/12/24.
//  Copyright © 2023 Sheng. All rights reserved.
//

import UIKit
import Foundation

/// 基于当前设备的屏幕缩放倍数，对传进来的 float 数值进行像素取整。
/// 例如传进来 "2.1"，在 2x 倍数下会返回 2.5（0.5pt 对应 1px），在 3x 倍数下会返回 2.333（0.333pt 对应 1px）。
public func FSFlat<T: FloatingPoint>(_ x: T) -> T {
    guard
        x != T.leastNormalMagnitude,
        x != T.leastNonzeroMagnitude,
        x != T.greatestFiniteMagnitude
    else {
        return x
    }
    let scale: T = T(Int(UIScreen.main.scale))
    let flattedValue = ceil(x * scale) / scale
    return flattedValue
}

public extension FSUIKitWrapper where Base == CGRect {
    
    /// Whether CGRect contains NaN value.
    var isNaN: Bool {
        return (base.origin.x.isNaN || base.origin.y.isNaN || base.width.isNaN || base.height.isNaN)
    }
    
    var isInfinite: Bool {
        return (base.origin.x.isInfinite || base.origin.y.isInfinite || base.width.isInfinite || base.height.isInfinite)
    }
    
    var isValidated: Bool {
        return (!base.isNull && !base.isInfinite && !base.fs.isNaN && !base.fs.isInfinite)
    }
    
    func flatted() -> CGRect {
        guard base.fs.isValidated else { return .zero }
        return CGRect.fs.flatRect(origin: base.origin, size: base.size)
    }
    
    static func flatRect(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) -> CGRect {
        let x = FSFlat(x)
        let y = FSFlat(y)
        let w = FSFlat(width)
        let h = FSFlat(height)
        return .init(x: x, y: y, width: w, height: h)
    }
    
    static func flatRect(origin: CGPoint, size: CGSize) -> CGRect {
        return flatRect(x: origin.x, y: origin.y, width: size.width, height: size.height)
    }
}
