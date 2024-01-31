//
//  Float+FSUIKit.swift
//  FSUIKit
//
//  Created by Sheng on 2024/2/1.
//

import Foundation

public extension FSUIKitWrapper where Base == Float {
    
    /// Remove last zero of decimal part.
    /// e.g. 1.0 return "1".
    var nonDecimalLastZeroText: String {
        return base.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", base) : String(base)
    }
}
