//
//  TextViewInputParser.swift
//  FSUIKit
//
//  Created by VincentLee on 2024/11/22.
//

import UIKit

struct TextViewInputParser {
    
    /// 文本处理类型
    /// 该属性的优先级比 ``shouldChangeCharactersHandler`` 低
    var kind: TextInputKind = .default
    
    /// 判断是否允许输入，完全把输入的控制交由外部。
    /// 当该 closure 有效时，``kind`` 属性不会再生效。
    var shouldChangeCharactersHandler: ((_ textView: UITextView, _ range: NSRange, _ string: String) -> Bool)?
    
    init() {}
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if let handler = shouldChangeCharactersHandler {
            return handler(textView, range, text)
        } else if !text.isEmpty {
            let parser = kind.parser
            return parser.text(textView.text ?? "", shouldChangeCharactersIn: range, replacementString: text)
        }
        return true
    }
}
