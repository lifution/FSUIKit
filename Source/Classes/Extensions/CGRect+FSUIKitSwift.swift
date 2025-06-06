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
            x: RemoveNaN(base.origin.x),
            y: RemoveNaN(base.origin.y),
            width: RemoveNaN(base.width),
            height: RemoveNaN(base.height)
        )
    }
}
