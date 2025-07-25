//
//  FSTextViewDelegate.swift
//  FSUIKitSwift
//
//  Created by Sheng on 2024/1/13.
//  Copyright © 2024 Sheng. All rights reserved.
//

import UIKit

@objc
public protocol FSTextViewDelegate: UITextViewDelegate {
    
    /// 输入框高度发生变化时的回调，当实现了这个方法后，文字输入过程中就会不断去计算输入框新内容的高度，并通过这个方法通知到 delegate。
    ///
    /// - Note: 只有当内容高度与当前输入框的高度不一致时才会调用到这里，所以无需在内部做高度是否变化的判断。
    ///
    @objc
    optional
    func textView(_ textView: FSTextView, heightDidChangeTo newHeight: CGFloat)
    
    /// 用户点击键盘的 return 按钮时的回调（return 按钮本质上是输入换行符 "\n"）。
    ///
    /// - SeeAlso: FSTextView.maximumTextLength
    ///
    /// - Returns: 返回 true 表示程序认为当前的点击是为了进行类似「发送」之类的操作，所以最终 "\n" 并不会被输入到文本框里。
    ///            返回 false 表示程序认为当前的点击只是普通的输入，所以会继续询问 `textView(_:shouldChangeTextIn:replacementText:)` 方法，
    ///            根据该方法的返回结果来决定是否要输入这个 "\n"。
    ///
    @objc
    optional
    func textViewShouldReturn(_ textView: FSTextView) -> Bool
    
    /// 由于 `maximumTextCount` 的实现方式导致业务无法再重写自己的 shouldChangeText，否则会丢失 `maximumTextCount` 的功能。
    /// 所以这里提供一个额外的 delegate，在 FSTextView 内部逻辑返回 true 的时候会再询问一次这个 delegate，从而给业务提供一个机会
    /// 去限制自己的输入内容。如果 FSTextView 内部逻辑本身就返回 false（例如超过了 maximumTextCount 的长度），则不会触发这个方法。
    /// 当输入被这个方法拦截时，由于拦截逻辑是业务自己写的，业务能轻松获取到这个拦截的时机，所以此时不会调用
    /// ``textView(_:didPreventTextChangeIn:replacementText:)``。如果有类似 tips 之类的操作，可以直接在 return false 之前处理。
    @objc
    optional
    func textView(_ textView: FSTextView, shouldChangeTextIn range: NSRange, replacementText text: String, originalValue: Bool) -> Bool
    
    /// 配合 `maximumTextLength` 属性使用，在输入文字超过限制时被调用。
    /// 例如如果你的输入框在按下键盘 "Done" 按键时做一些发送操作，就可以在这个方法里判断 `text == "\n"`。
    ///
    /// - Parameters:
    ///   - textView: 触发回调该方法的 FSTextView 实例。
    ///   - range:    要变化的文字的位置，如果在 `textViewDidChange(_:)` 里，这里的 range 也即文字变化后的 range，所以可能比最大长度要大。
    ///   - text:     要变化的文字，如果在 `textViewDidChange(_:)` 里则这里永远传入 `""`。
    ///
    /// - Warning:
    ///     在 `textViewDidChange(_:)` 里也会触发文字长度拦截，由于此时 textView 的文字已经改变完，所以无法得知发生改变的文本位置及改变的文本内容，
    ///     所以此时 range 和 replacementText 这两个参数的值也会比较特殊，具体请看参数讲解。
    ///
    @objc
    optional
    func textView(_ textView: FSTextView, didPreventTextChangeIn range: NSRange, replacementText text: String)
}
