//
//  RegexTextInputParser.swift
//  FSUIKit
//
//  Created by VincentLee on 2024/11/18.
//

import UIKit
import Foundation

struct RegexTextInputParser: TextInputParsable {
    
    typealias ValueType = String
    
    var regex: String
    
    init(regex: String) {
        self.regex = regex
    }
    
    func text(_ text: String, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: string)
    }
    
    func formatting(_ text: String) -> String {
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        guard predicate.evaluate(with: text) else {
            return ""
        }
        return text
    }
    
    func value(for text: String) -> String {
        return formatting(text)
    }
}
