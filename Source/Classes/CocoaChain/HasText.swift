//
//  HasText.swift
//  FSUIKitSwift
//
//  Created by VincentLee on 2024/11/6.
//

import UIKit

public protocol FSUIKitHasText {
    
    func fs_set(text: String?)
    
    func fs_set(attributedText: NSAttributedString?)
    
    func fs_set(color: UIColor)
    
    func fs_set(alignment: NSTextAlignment)
}

extension UILabel: FSUIKitHasText {
    
    public func fs_set(text: String?) {
        self.text = text
    }
    
    public func fs_set(attributedText: NSAttributedString?) {
        self.attributedText = attributedText
    }
    
    public func fs_set(color: UIColor) {
        self.textColor = color
    }
    
    public func fs_set(alignment: NSTextAlignment) {
        self.textAlignment = alignment
    }
}

extension UITextField: FSUIKitHasText {
    
    public func fs_set(text: String?) {
        self.text = text
    }
    
    public func fs_set(attributedText: NSAttributedString?) {
        self.attributedText = attributedText
    }
    
    public func fs_set(color: UIColor) {
        self.textColor = color
    }
    
    public func fs_set(alignment: NSTextAlignment) {
        self.textAlignment = alignment
    }
}

extension UITextView: FSUIKitHasText {
    
    public func fs_set(text: String?) {
        self.text = text
    }
    
    public func fs_set(attributedText: NSAttributedString?) {
        self.attributedText = attributedText
    }
    
    public func fs_set(color: UIColor) {
        self.textColor = color
    }
    
    public func fs_set(alignment: NSTextAlignment) {
        self.textAlignment = alignment
    }
}
