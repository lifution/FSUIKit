//
//  Decimal+FSUIKit.swift
//  FSUIKit
//
//  Created by Sheng on 2024/2/21.
//

import Foundation

public extension FSUIKitWrapper where Base == Decimal {
    
    func formatted(withMaximumFractionDigits maximumFractionDigits: Int = 2) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = maximumFractionDigits
        return formatter.string(from: base as NSDecimalNumber) ?? "0"
    }
}
