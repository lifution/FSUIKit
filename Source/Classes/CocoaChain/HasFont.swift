//
//  HasFont.swift
//  FSUIKitSwift
//
//  Created by VincentLee on 2024/11/6.
//
//  Inspired by https://github.com/Pircate/CocoaChainKit
//

import UIKit

public protocol FSUIKitHasFont {
    
    func fs_set(font: UIFont)
}

extension UILabel: FSUIKitHasFont {
    
    public func fs_set(font: UIFont) {
        self.font = font
    }
}

extension UIButton: FSUIKitHasFont {
    
    public func fs_set(font: UIFont) {
        self.titleLabel?.font = font
    }
}

extension UITextField: FSUIKitHasFont {
    
    public func fs_set(font: UIFont) {
        self.font = font
    }
}

extension UITextView: FSUIKitHasFont {
    
    public func fs_set(font: UIFont) {
        self.font = font
    }
}
