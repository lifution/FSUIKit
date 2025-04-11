//
//  CoreGraphics+FSUIKitSwift.swift
//  FSUIKitSwift
//
//  Created by Sheng on 2023/12/24.
//  Copyright © 2023 Sheng. All rights reserved.
//

import UIKit

public extension FSUIKitWrapper where Base == CGRect {
    
    var center: CGPoint {
        get { return .init(x: base.midX, y: base.midY) }
        set {
            base.origin.x = newValue.x - base.width * 0.5
            base.origin.y = newValue.y - base.height * 0.5
        }
    }
    
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
