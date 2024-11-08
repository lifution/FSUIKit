//
//  FSTextFieldDelegate.swift
//  FSUIKitSwift
//
//  Created by VincentLee on 2024/11/7.
//  Copyright © 2024 VincentLee. All rights reserved.
//

import UIKit

@objc
public protocol FSTextFieldDelegate: UITextFieldDelegate {
    
    /// 由于 `maximumTextLength` 的实现方式导致业务无法再重写自己的 shouldChangeCharacters，否则会丢失 `maximumTextLength` 的功能。
    /// 所以这里提供一个额外的 delegate，在 FSTextField 内部逻辑返回 true 的时候会再询问一次这个 delegate，从而给业务提供一个机会
    /// 去限制自己的输入内容。如果 FSTextField 内部逻辑本身就返回 false（例如超过了 maximumTextLength 的长度），则不会触发这个方法。
    /// 当输入被这个方法拦截时，由于拦截逻辑是业务自己写的，业务能轻松获取到这个拦截的时机，所以此时不会调用
    /// ``textField(_:didPreventTextChangeIn:replacementString:)``。如果有类似 tips 之类的操作，可以直接在 return false 之前处理。
    @objc optional
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String, originalValue: Bool) -> Bool
    
    /// 配合 `maximumTextLength` 属性使用，在输入文字超过限制时被调用。
    ///
    /// - Warning:
    ///   在 UIControlEventEditingChanged 里也会触发文字长度拦截，由于此时 textField 的文字已经改变完，
    ///   所以无法得知发生改变的文本位置及改变的文本内容，所以此时 range 和 replacementString 这两个参数的值也会比较特殊，具体请看参数讲解。
    ///
    /// - Parameters:
    ///   range: 要变化的文字的位置，如果在 UIControlEventEditingChanged 里，这里的 range 也即文字变化后的 range，所以可能比最大长度要大。
    ///   string: 要变化的文字，如果在 UIControlEventEditingChanged 里，这里永远传入 nil。
    ///
    @objc optional
    func textField(_ textField: UITextField, didPreventTextChangeIn range: NSRange, replacementString string: String?)
}
