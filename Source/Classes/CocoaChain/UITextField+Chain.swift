//
//  UITextField+Chain.swift
//  FSUIKitSwift
//
//  Created by VincentLee on 2024/11/6.
//

import UIKit

public extension FSUIKitWrapper where Base: UITextField {
    
    @discardableResult
    func delegate(_ delegate: UITextFieldDelegate?) -> FSUIKitWrapper {
        base.delegate = delegate
        return self
    }
    
    @discardableResult
    func placeholder(_ placeholder: String?) -> FSUIKitWrapper {
        base.placeholder = placeholder
        return self
    }
    
    @discardableResult
    func attributedPlaceholder(_ attributedPlaceholder: NSAttributedString?) -> FSUIKitWrapper {
        base.attributedPlaceholder = attributedPlaceholder
        return self
    }
    
    @discardableResult
    func borderStyle(_ borderStyle: UITextField.BorderStyle) -> FSUIKitWrapper {
        base.borderStyle = borderStyle
        return self
    }
    
    @discardableResult
    func defaultTextAttributes(_ defaultTextAttributes: [String: Any]) -> FSUIKitWrapper {
        base.defaultTextAttributes = Dictionary(uniqueKeysWithValues: defaultTextAttributes.map { key, value in
            (NSAttributedString.Key(rawValue: key), value)
        })
        return self
    }
    
    @discardableResult
    func clearsOnBeginEditing(_ clearsOnBeginEditing: Bool) -> FSUIKitWrapper {
        base.clearsOnBeginEditing = clearsOnBeginEditing
        return self
    }
    
    @discardableResult
    func adjustsFontSizeToFitWidth(_ adjustsFontSizeToFitWidth: Bool) -> FSUIKitWrapper {
        base.adjustsFontSizeToFitWidth = adjustsFontSizeToFitWidth
        return self
    }
    
    @discardableResult
    func minimumFontSize(_ minimumFontSize: CGFloat) -> FSUIKitWrapper {
        base.minimumFontSize = minimumFontSize
        return self
    }
    
    @discardableResult
    func allowsEditingTextAttributes(_ allowsEditingTextAttributes: Bool) -> FSUIKitWrapper {
        base.allowsEditingTextAttributes = allowsEditingTextAttributes
        return self
    }
    
    @discardableResult
    func typingAttributes(_ typingAttributes: [String: Any]?) -> FSUIKitWrapper {
        base.typingAttributes = {
            guard let typingAttributes = typingAttributes else { return nil }
            return Dictionary(uniqueKeysWithValues: typingAttributes.map { key, value in
                (NSAttributedString.Key(rawValue: key), value)
            })
        }()
        return self
    }
    
    @discardableResult
    func clearButtonMode(_ clearButtonMode: UITextField.ViewMode) -> FSUIKitWrapper {
        base.clearButtonMode = clearButtonMode
        return self
    }
    
    @discardableResult
    func leftView(_ leftView: UIView?) -> FSUIKitWrapper {
        base.leftView = leftView
        return self
    }
    
    @discardableResult
    func leftViewMode(_ leftViewMode: UITextField.ViewMode) -> FSUIKitWrapper {
        base.leftViewMode = leftViewMode
        return self
    }
    
    @discardableResult
    func rightView(_ rightView: UIView?) -> FSUIKitWrapper {
        base.rightView = rightView
        return self
    }
    
    @discardableResult
    func rightViewMode(_ rightViewMode: UITextField.ViewMode) -> FSUIKitWrapper {
        base.rightViewMode = rightViewMode
        return self
    }
    
    @discardableResult
    func keyboardType(_ keyboardType: UIKeyboardType) -> FSUIKitWrapper {
        base.keyboardType = keyboardType
        return self
    }
    
    @discardableResult
    func returnKeyType(_ returnKeyType: UIReturnKeyType) -> FSUIKitWrapper {
        base.returnKeyType = returnKeyType
        return self
    }
    
    @discardableResult
    func isSecureTextEntry(_ isSecureTextEntry: Bool) -> FSUIKitWrapper {
        base.isSecureTextEntry = isSecureTextEntry
        return self
    }
    
    @discardableResult
    func textContentType(_ textContentType: UITextContentType) -> FSUIKitWrapper {
        if #available(iOS 10.0, *) {
            base.textContentType = textContentType
        }
        return self
    }
}
