//
//  IntegerTextInputParser.swift
//  FSUIKit
//
//  Created by VincentLee on 2024/11/18.
//

import UIKit
import Foundation

public struct IntegerTextInputParser: TextInputParsable {
    
    public typealias ValueType = Int
    
    public var isFirstNonzero: Bool
    
    public init(isFirstNonzero: Bool = true) {
        self.isFirstNonzero = isFirstNonzero
    }
    
    public func text(_ text: String, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if range.location == 0, string.first == "0", isFirstNonzero {
            return false
        }
        let predicate = NSPredicate(format: "SELF MATCHES %@", "[0-9]+")
        return predicate.evaluate(with: string)
    }
    
    public func formatting(_ text: String) -> String {
        let predicate = NSPredicate(format: "SELF MATCHES %@", "[0-9]+")
        guard predicate.evaluate(with: text) else {
            return "0"
        }
        var text = text
        if isFirstNonzero {
            while text.first == "0" {
                text.removeFirst()
            }
        }
        return text
    }
    
    public func value(for text: String) -> Int {
        let text = formatting(text).replacingOccurrences(of: ",", with: "")
        return Int(text) ?? 0
    }
}
