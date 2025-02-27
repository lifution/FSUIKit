//
//  Double+FSUIKitSwift.swift
//  FSUIKitSwift
//
//  Created by Sheng on 2024/2/1.
//  Copyright © 2023 Sheng. All rights reserved.
//

import Foundation

public extension FSUIKitWrapper where Base == Double {
    
    static var pixelOne: Double {
        Double(UIScreen.fs.pixelOne)
    }
    
    /// Remove last zero of decimal part.
    /// e.g. 1.0 return "1".
    var nonDecimalLastZeroText: String {
        return base.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", base) : String(base)
    }
    
    /// 四舍五入保留指定数量的小数位
    func rounded(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (base * divisor).rounded() / divisor
    }
}
