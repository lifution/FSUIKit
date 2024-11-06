//
//  HasText+FSUIKitWrapper.swift
//  FSUIKitSwift
//
//  Created by VincentLee on 2024/11/6.
//

import UIKit

public extension FSUIKitWrapper where Base: FSUIKitHasText {
    
    @discardableResult
    func text(_ text: String?) -> FSUIKitWrapper {
        base.fs_set(text: text)
        return self
    }
    
    @discardableResult
    func attributedText(_ attributedText: NSAttributedString?) -> FSUIKitWrapper {
        base.fs_set(attributedText: attributedText)
        return self
    }
    
    @discardableResult
    func textColor(_ textColor: UIColor) -> FSUIKitWrapper {
        base.fs_set(color: textColor)
        return self
    }
    
    @discardableResult
    func textAlignment(_ textAlignment: NSTextAlignment) -> FSUIKitWrapper {
        base.fs_set(alignment: textAlignment)
        return self
    }
}
