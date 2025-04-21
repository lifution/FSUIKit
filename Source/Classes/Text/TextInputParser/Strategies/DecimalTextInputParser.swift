//
//  DecimalTextInputParser.swift
//  FSUIKit
//
//  Created by VincentLee on 2024/11/18.
//

import UIKit
import Foundation

struct DecimalTextInputParser: TextInputParsable {
    
    typealias ValueType = Decimal
    
    var maximumFractionDigits: Int
    
    init(maximumFractionDigits: Int = 2) {
        self.maximumFractionDigits = maximumFractionDigits
    }
    
    func text(_ text: String, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
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
        if text.contains("."), let decimalComponent = text.components(separatedBy: ".").last {
            if decimalComponent.count > maximumFractionDigits {
                return false
            }
        }
        return true
    }
    
    func formatting(_ text: String) -> String {
        guard let value = Double(text) else {
            return "0"
        }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.roundingMode = .down
        formatter.maximumFractionDigits = maximumFractionDigits
        formatter.usesGroupingSeparator = false
        return formatter.string(from: Decimal(value) as NSDecimalNumber) ?? "0"
    }
    
    func value(for text: String) -> Decimal {
        let text = formatting(text)
        guard let value = Double(text) else {
            return 0.0
        }
        return Decimal(value)
    }
}
