//
//  CGRect+FSUIKitSwift.swift
//  FSUIKitSwift
//
//  Created by VincentLee on 2024/8/16.
//

import UIKit

public extension FSUIKitWrapper where Base == CGRect {
    
    func mirrorsForRTLLanguage(with containerWidth: CGFloat) -> CGRect {
        var frame = base
        frame.origin.x = containerWidth - base.minX - base.width
        return frame
    }
    
    func removedNaN() -> CGRect {
        return .init(
            x: removeNaN(base.origin.x),
            y: removeNaN(base.origin.y),
            width: removeNaN(base.width),
            height: removeNaN(base.height)
        )
    }
    
    /// 比较当前 CGRect 实例与另一个 CGRect 实例在「误差范围」内是否相等。
    ///
    /// - Parameters:
    ///   - other: 另一个要比较的 CGRect 实例
    ///   - tolerance: 误差范围
    /// - Returns: 在误差范围内相等则返回 true，否则返回 false.
    ///
    func isEqual(to other: CGRect, tolerance: CGFloat) -> Bool {
        let x = abs(base.origin.x - other.origin.x)
        let y = abs(base.origin.y - other.origin.y)
        let width = abs(base.size.width - other.size.width)
        let height = abs(base.size.height - other.size.height)
        return x <= tolerance && y <= tolerance && width <= tolerance && height <= tolerance
    }
}
