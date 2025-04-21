//
//  PercentTextInputParser.swift
//  FSUIKit
//
//  Created by VincentLee on 2024/11/18.
//

import UIKit
import Foundation

public struct PercentTextInputParser: TextInputParsable {
    
    public typealias ValueType = Decimal
    
    public init() {}
    
    public func text(_ text: String, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", "[0-9.]+")
        guard predicate.evaluate(with: string) else {
            return false
        }
        if string.first == "." {
            if range.location == 0 {
                return false
            }
            if text.contains(".") {
                return false
            }
        }
        let text = (text as NSString).replacingCharacters(in: range, with: string)
        if text.first == "0" {
            if text.count >= 2, text.fs.substring(at: 1) != "." {
                return false
            }
        }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        if let value = formatter.number(from: text)?.doubleValue {
            if value > 100 { // 百分比是不能超过 100 的
                return false
            }
            if text.contains("."), let decimalComponent = text.components(separatedBy: ".").last {
                if decimalComponent.count > 2 {
                    return false
                }
            }
            return true
        }
        return false
    }
    
    public func formatting(_ text: String) -> String {
        guard let value = Double(text), value >= 0, value <= 100 else {
            return "0"
        }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.roundingMode = .down
        formatter.maximumFractionDigits = 2
        return formatter.string(from: Decimal(value) as NSDecimalNumber) ?? "0"
    }
    
    public func value(for text: String) -> Decimal {
        let text = formatting(text)
        guard let value = Double(text) else {
            return 0.0
        }
        return Decimal(value)
    }
}
