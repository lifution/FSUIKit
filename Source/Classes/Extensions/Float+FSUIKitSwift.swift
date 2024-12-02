//
//  Float+FSUIKitSwift.swift
//  FSUIKitSwift
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
    
    /// 四舍五入保留指定数量的小数位
    func rounded(to places: Int) -> Float {
        let divisor = pow(10.0, Float(places))
        return (base * divisor).rounded() / divisor
    }
}
