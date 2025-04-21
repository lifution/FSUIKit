//
//  DefaultTextInputParser.swift
//  FSUIKit
//
//  Created by VincentLee on 2024/11/18.
//

import UIKit
import Foundation

public struct DefaultTextInputParser: TextInputParsable {
    
    public typealias ValueType = String
    
    /// 是否允许输入 emoji，默认为 false。
    public var allowsEmoji = false
    
    public init() {}
    
    public func text(_ text: String, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if !allowsEmoji, string.fs.containsEmoji {
            return false
        }
        return true
    }
    
    public func formatting(_ text: String) -> String {
        var text = text
        if !allowsEmoji {
            text = text.fs.nonEmojiString
        }
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    public func value(for text: String) -> String {
        return formatting(text)
    }
}
