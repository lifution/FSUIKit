//
//  TextFieldInputParser.swift
//  FSUIKit
//
//  Created by VincentLee on 2024/11/16.
//

import UIKit

public struct TextFieldInputParser {
    
    /// 文本处理类型
    /// 该属性的优先级比 ``shouldChangeCharactersHandler`` 低
    public var kind: TextInputKind = .default
    
    /// 判断是否允许输入，完全把输入的控制交由外部。
    /// 当该 closure 有效时，``kind`` 属性不会再生效。
    public var shouldChangeCharactersHandler: ((_ textField: UITextField, _ range: NSRange, _ string: String) -> Bool)?
    
    public init(kind: TextInputKind = .default, shouldChangeCharactersHandler: ((_ textField: UITextField, _ range: NSRange, _ string: String) -> Bool)? = nil) {
        self.kind = kind
        self.shouldChangeCharactersHandler = shouldChangeCharactersHandler
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Prvents keyboard new line.
        if string == "\n\u{07}" || string == "\n" {
            return false
        }
        // Prvents white-space in first location.
        if range.location == 0, !string.isEmpty {
            let s = string.trimmingCharacters(in: .whitespacesAndNewlines)
            if s.isEmpty {
                return false
            }
        }
        if let handler = shouldChangeCharactersHandler {
            return handler(textField, range, string)
        } else if !string.isEmpty {
            let parser = kind.parser
            return parser.text(textField.text ?? "", shouldChangeCharactersIn: range, replacementString: string)
        }
        return true
    }
}
