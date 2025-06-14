//
//  CGPoint+FSUIKitSwift.swift
//  FSUIKitSwift
//
//  Created by VincentLee on 2025/6/6.
//

import UIKit

public extension FSUIKitWrapper where Base == CGPoint {
    
    /// Returns a new CGPoint offset by the specified x and y values.
    ///
    func offsetBy(x: CGFloat, y: CGFloat) -> CGPoint {
        return .init(x: base.x + x, y: base.y + y)
    }
    
    func ceiled() -> CGPoint {
        return .init(x: ceil(base.x), y: ceil(base.y))
    }
    
    func flatted() -> CGPoint {
        return .init(x: flat(base.x), y: flat(base.y))
    }
    
    func floorFlatted() -> CGPoint {
        return .init(x: floorFlat(base.x), y: floorFlat(base.y))
    }
    
    func removedNaN() -> CGPoint {
        return .init(x: removeNaN(base.x), y: removeNaN(base.y))
    }
    
    /// 比较当前 CGPoint 实例与另一个 CGPoint 实例在「误差范围」内是否相等。
    ///
    /// - Parameters:
    ///   - other: 另一个要比较的 CGPoint 实例
    ///   - tolerance: 误差范围
    /// - Returns: 在误差范围内相等则返回 true，否则返回 false.
    ///
    func isEqual(to other: CGPoint, tolerance: CGFloat) -> Bool {
        let x = abs(base.x - other.x)
        let y = abs(base.y - other.y)
        return x <= tolerance && y <= tolerance
    }
}
