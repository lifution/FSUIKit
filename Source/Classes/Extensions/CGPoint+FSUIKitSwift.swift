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
        return .init(x: FSFlat(base.x), y: FSFlat(base.y))
    }
    
    func floorFlatted() -> CGPoint {
        return .init(x: FSFloorFlat(base.x), y: FSFloorFlat(base.y))
    }
    
    func removedNaN() -> CGPoint {
        return .init(x: removeNaN(base.x), y: removeNaN(base.y))
    }
}
