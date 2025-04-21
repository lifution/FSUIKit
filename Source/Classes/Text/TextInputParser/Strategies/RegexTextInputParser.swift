//
//  RegexTextInputParser.swift
//  FSUIKit
//
//  Created by VincentLee on 2024/11/18.
//

import UIKit
import Foundation

public struct RegexTextInputParser: TextInputParsable {
    
    public typealias ValueType = String
    
    public var regex: String
    
    public init(regex: String) {
        self.regex = regex
    }
    
    public func text(_ text: String, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: string)
    }
    
    public func formatting(_ text: String) -> String {
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        guard predicate.evaluate(with: text) else {
            return ""
        }
        return text
    }
    
    public func value(for text: String) -> String {
        return formatting(text)
    }
}
