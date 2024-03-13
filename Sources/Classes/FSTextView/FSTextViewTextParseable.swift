//
//  FSTextViewTextParseable.swift
//  FSUIKit
//
//  Created by Sheng on 2024/1/13.
//  Copyright © 2024 Sheng. All rights reserved.
//

import UIKit

public protocol FSTextViewTextParseable {
    
    /// 转换一段纯文本。
    func parse(text: String) -> NSAttributedString?
    
    /// 转换一段富文本，一般该方法用于 UITextView 的表情输入。
    func parse(attributedText: NSAttributedString, selectedRange: NSRangePointer?) -> NSAttributedString?
    
    /// 把一段富文本转换为纯文本。
    func plainText(of attributedText: NSAttributedString, for range: NSRange) -> String?
}

// Optional
public extension FSTextViewTextParseable {
    func parse(text: String) -> NSAttributedString? { return nil }
    func parse(attributedText: NSAttributedString, selectedRange: NSRangePointer?) -> NSAttributedString? { return nil }
    func plainText(of attributedText: NSAttributedString, for range: NSRange) -> String? { return nil }
}
