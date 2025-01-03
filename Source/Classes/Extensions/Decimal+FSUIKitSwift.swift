//
//  Decimal+FSUIKitSwift.swift
//  FSUIKitSwift
//
//  Created by Sheng on 2024/2/21.
//  Copyright © 2023 Sheng. All rights reserved.
//

import Foundation

public extension FSUIKitWrapper where Base == Decimal {
    
    func formatted(withMaximumFractionDigits maximumFractionDigits: Int = 2,
                   roundingMode: NumberFormatter.RoundingMode = .down) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.roundingMode = roundingMode
        formatter.maximumFractionDigits = maximumFractionDigits
        return formatter.string(from: base as NSDecimalNumber) ?? "0"
    }
}
