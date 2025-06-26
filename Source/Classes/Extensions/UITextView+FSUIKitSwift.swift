//
//  UITextView+FSUIKitSwift.swift
//  FSUIKitSwift
//
//  Created by VincentLee on 2025/6/26.
//

import UIKit

public extension FSUIKitWrapper where Base: UITextView {
    
    var selectedRange: NSRange {
        get {
            guard let range = base.selectedTextRange else {
                return convertNSRangeFromUITextRange(UITextRange())
            }
            return convertNSRangeFromUITextRange(range)
        }
        set {
            base.selectedTextRange = convertUITextRangeFromNSRange(newValue)
        }
    }
    
    func convertNSRangeFromUITextRange(_ range: UITextRange) -> NSRange {
        let location = base.offset(from: base.beginningOfDocument, to: range.start)
        let length = base.offset(from: range.start, to: range.end)
        return .init(location: location, length: length)
    }
    
    func convertUITextRangeFromNSRange(_ range: NSRange) -> UITextRange? {
        guard
            range.location != NSNotFound,
            NSMaxRange(range) <= (base.text?.count ?? 0)
        else {
            return nil
        }
        let beginning = base.beginningOfDocument
        guard
            let start = base.position(from: beginning, offset: range.location),
            let end = base.position(from: beginning, offset: NSMaxRange(range))
        else {
            return nil
        }
        return base.textRange(from: start, to: end)
    }
}
