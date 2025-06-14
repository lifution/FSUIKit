//
//  CGSize+FSUIKitSwift.swift
//  FSUIKitSwift
//
//  Created by Sheng on 2024/3/25.
//  Copyright © 2024 Sheng. All rights reserved.
//

import UIKit

public extension FSUIKitWrapper where Base == CGSize {
    
    /// Returns a size that is smaller or larger than the source size.
    ///
    func insetBy(horizontal: CGFloat, vertical: CGFloat) -> CGSize {
        let width = base.width - horizontal
        let height = base.height - vertical
        return .init(width: max(0, width), height: max(0, height))
    }
    
    func ceiled() -> CGSize {
        return .init(width: ceil(base.width), height: ceil(base.height))
    }
    
    func flatted() -> CGSize {
        return .init(width: flat(base.width), height: flat(base.height))
    }
    
    func floorFlatted() -> CGSize {
        return .init(width: floorFlat(base.width), height: floorFlat(base.height))
    }
    
    func removedNaN() -> CGSize {
        return .init(width: removeNaN(base.width), height: removeNaN(base.height))
    }
    
    /// 比较当前 CGSize 实例与另一个 CGSize 实例在「误差范围」内是否相等。
    ///
    /// - Parameters:
    ///   - other: 另一个要比较的 CGSize 实例
    ///   - tolerance: 误差范围
    /// - Returns: 在误差范围内相等则返回 true，否则返回 false.
    ///
    func isEqual(to other: CGSize, tolerance: CGFloat) -> Bool {
        let width = abs(base.width - other.width)
        let height = abs(base.height - other.height)
        return width <= tolerance && height <= tolerance
    }
}
