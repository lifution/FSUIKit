//
//  FSTextField.swift
//  FSUIKitSwift
//
//  Created by VincentLee on 2024/11/7.
//  Copyright © 2024 VincentLee. All rights reserved.
//
//  代码参考于: https://github.com/Tencent/QMUI_iOS

import UIKit
import Foundation
import ObjectiveC

///
/// 支持的特性包括：
/// 1. 自定义 placeholderColor。
/// 2. 自定义 UITextField 的文字 padding。
/// 3. 支持限制输入的文字的长度。
/// 4. 修复 iOS 10 之后 UITextField 输入中文超过文本框宽度后再删除，文字往下掉的 bug。
///
open class FSTextField: _FSTempTextField {
    
    // MARK: Properties/Override
    
    open override var text: String? {
        didSet {
            if text != oldValue, shouldResponseToProgrammaticallyTextChanges {
                p_fireTextDidChangeEvent(for: self)
            }
        }
    }
    
    open override var attributedText: NSAttributedString? {
        didSet {
            let changed: Bool = {
                if attributedText == nil, oldValue == nil {
                    return false
                }
                if let oldValue {
                    return attributedText?.isEqual(to: oldValue) ?? false
                }
                return true
            }()
            if changed, shouldResponseToProgrammaticallyTextChanges {
                p_fireTextDidChangeEvent(for: self)
            }
        }
    }
    
    open override var placeholder: String? {
        didSet {
            if placeholder != oldValue {
                p_updateAttributedPlaceholder()
            }
        }
    }
    
    // MARK: Properties/Open
    
    weak open var delegate: (any FSTextFieldDelegate)?
    
    /// placeholder 的颜色，默认是 ``UIColor.fs.placeholder``。
    open var placeholderColor: UIColor? = .fs.placeholder {
        didSet {
            if !(placeholder?.isEmpty ?? true) {
                p_updateAttributedPlaceholder()
            }
        }
    }
    
    /// 文字在输入框内的 padding。如果出现 clearButton，则 textInsets.right 会控制 clearButton 的右边距。
    /// 默认为 {0, 7, 0, 7}
    open var textInsets: UIEdgeInsets = .init(top: 0.0, left: 7.0, bottom: 0.0, right: 7.0)
    
    /// clearButton 在默认位置上的偏移
    open var clearButtonPositionAdjustment: UIOffset = .zero
    
    /// 当通过 ``text{set}``、``attributedText{set}`` 等方式修改文字时，是否应该自动触发 UIControlEventEditingChanged 事件
    /// 及 UITextFieldTextDidChangeNotification 通知。
    ///
    /// 默认为 true（注意：系统的 UITextField 对这种行为默认是 false）
    ///
    open var shouldResponseToProgrammaticallyTextChanges = true
    
    /// 显示允许输入的最大文字长度，默认为 0，也即不限制长度。
    open var maximumTextCount = 0
    
    /// 在使用 `maximumTextCount` 功能的时候，是否应该把文字长度按照 ``string.fs.countOfNonASCIICharacterAsTwo`` 的方法来计算。
    ///
    /// 默认为 false
    ///
    open var shouldCountingNonASCIICharacterAsTwo = false
    
    /// 控制输入框是否要出现 "粘贴" menu
    ///
    /// - Parameters:
    ///   - sender: 触发这次询问事件的来源
    ///   - superReturnValue: ``super.canPerformAction(_:withSender:)`` 的返回值，当你不需要控制这个 closure 的返回值时，
    ///                       可以返回 superReturnValue。
    /// - Returns:
    ///   控制是否要出现 "粘贴" menu，true 表示出现，false 表示不出现。当你想要返回系统默认的结果时，请返回参数 superReturnValue。
    ///
    open var canPerformPasteActionHandler: ((_ sender: Any?, _ superReturnValue: Bool) -> Bool)?
    
    /// 当输入框的 "粘贴" 事件被触发时，可通过这个 closure 去接管事件的响应。
    ///
    /// - Parameters:
    ///   - sender: "粘贴" 事件触发的来源，例如可能是一个 UIMenuController
    ///
    /// - Returns:
    ///   返回值用于控制是否要调用系统默认的 ``paste(_:)`` 实现，true 表示执行完 closure 后继续调用系统默认实现，false 表示执行完 closure 后就结束了，不调用 super。
    ///
    open var pasteActionHandler: ((_ sender: Any?) -> Bool)?
    
    /// 当输入框达到最大限制字符数量时会回调该 closure
    open var onDidHitMaximumTextCountHandler: ((_ textField: FSTextField) -> Void)?
    
    // MARK: Properties/Private
    
    private let delegator = _FSTextFieldDelegator()
    
    // MARK: Initialization
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        p_didInitialize()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        p_didInitialize()
    }
    
    // MARK: Override
    
    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        let superReturnValue = super.canPerformAction(action, withSender: sender)
        if action == #selector(paste(_:)), let handler = canPerformPasteActionHandler {
            return handler(sender, superReturnValue)
        }
        return superReturnValue
    }
    
    open override func paste(_ sender: Any?) {
        if pasteActionHandler?(sender) ?? true {
            super.paste(sender)
        }
    }
    
    /// 这样写已经可以让 sizeThatFits 时高度加上 textInsets 的值了
    open override func textRect(forBounds bounds: CGRect) -> CGRect {
        return super.textRect(forBounds: bounds.inset(by: textInsets))
    }
    
    open override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return super.editingRect(forBounds: bounds.inset(by: textInsets))
    }
    
    open override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.clearButtonRect(forBounds: bounds)
        return rect.offsetBy(dx: clearButtonPositionAdjustment.horizontal,
                             dy: clearButtonPositionAdjustment.vertical)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        // 以下代码修复系统的 UITextField 在 iOS 10 下的 bug：https://github.com/Tencent/QMUI_iOS/issues/64
        // 默认 delegate 是为 nil 的，所以我们才利用 delegate 修复这 个 bug，如果哪一天 delegate 不为 nil，就先不处理了。
        if let scrollView = subviews.first as? UIScrollView, scrollView.delegate == nil {
            scrollView.delegate = delegator
        }
    }
}

// MARK: - Private

private extension FSTextField {
    
    /// Invoked after initialization.
    func p_didInitialize() {
        textColor = .black
        tintColor = nil
        delegator.textField = self
        set(delegate: delegator)
        addTarget(delegator, action: #selector(delegator.handleTextChangeEvent(of:)), for: .editingChanged)
    }
    
    func p_updateAttributedPlaceholder() {
        let color = placeholderColor ?? .clear
        attributedPlaceholder = .init(string: placeholder ?? "", attributes: [.foregroundColor: color])
    }
    
    func p_fireTextDidChangeEvent(for textField: FSTextField) {
        textField.sendActions(for: .editingChanged)
        NotificationCenter.default.post(name: UITextField.textDidChangeNotification, object: textField)
    }
    
    func p_count(of string: String) -> Int {
        return shouldCountingNonASCIICharacterAsTwo ? string.fs.countOfNonASCIICharacterAsTwo : string.count
    }
}

// MARK: - _FSTextFieldDelegator

private final class _FSTextFieldDelegator: NSObject, FSTextFieldDelegate, UIScrollViewDelegate {
    
    weak var textField: FSTextField?
    
    @objc
    func handleTextChangeEvent(of textField: FSTextField) {
        /// 1. iOS 10 以下的版本，从中文输入法的候选词里选词输入，是不会走到
        ///    ``textField(_:,shouldChangeCharactersIn:,replacementString:,originalValue:)`` 的，所以要在这里截断文字。
        /// 2. 如果是中文输入法正在输入拼音的过程中（markedTextRange 不为 nil），是不应该限制字数的（例如输入 "huang" 这5个字符，
        ///    其实只是为了输入 "黄" 这一个字符），所以在 shouldChange 那边不会限制，而是放在 didChange 这里限制。
        /// 3. 系统的三指撤销在文本框达到最大字符长度限制时可能引发 crash
        ///    https://github.com/Tencent/QMUI_iOS/issues/1168
        guard
            textField.maximumTextCount > 0,
            !(textField.undoManager?.isUndoing ?? false),
            !(textField.undoManager?.isRedoing ?? false),
            textField.markedTextRange == nil,
            let text = textField.text,
            textField.p_count(of: text) > textField.maximumTextCount
        else {
            return
        }
        let newText: String
        // selectedRange 是系统的，所以这里按 shouldCountingNonASCIICharacterAsTwo = false 来计算
        let lastLength = text.count - NSMaxRange(textField.fs.selectedRange)
        if lastLength > 0 {
            // 光标在中间就触发了最长文本限制，要从前面截断，不要影响光标后面的原始文本
            let lastText = (text as NSString).substring(from: NSMaxRange(textField.fs.selectedRange))
            let lastLengthInFS = textField.p_count(of: lastText)
            let preLengthInFS = textField.maximumTextCount - lastLengthInFS
            let preText = text.fs.substringAvoidBreakingUpCharacterSequences(to: preLengthInFS,
                                                                             lessValue: true,
                                                                             countingNonASCIICharacterAsTwo: textField.shouldCountingNonASCIICharacterAsTwo) ?? ""
            newText = preText + lastText
        } else {
            newText = text.fs.substringAvoidBreakingUpCharacterSequences(with: .init(location: 0, length: textField.maximumTextCount),
                                                                         lessValue: true,
                                                                         countingNonASCIICharacterAsTwo: textField.shouldCountingNonASCIICharacterAsTwo) ?? ""
        }
        textField.text = newText
        textField.fs.selectedRange = .init(location: text.count - lastLength, length: 0)
        textField.delegate?.textField?(textField, didPreventTextChangeIn: textField.fs.selectedRange, replacementString: nil)
        textField.onDidHitMaximumTextCountHandler?(textField)
    }
    
    // MARK: UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 以下代码修复系统的 UITextField 在 iOS 10 下的 bug：https://github.com/Tencent/QMUI_iOS/issues/64
        guard scrollView === textField?.subviews.first else {
            return
        }
        let lineHeight: CGFloat
        if let style = textField?.defaultTextAttributes[.paragraphStyle] as? NSParagraphStyle {
            lineHeight = style.minimumLineHeight
        } else if let font = textField?.defaultTextAttributes[.font] as? UIFont {
            lineHeight = font.lineHeight
        } else {
            lineHeight = 0.0
        }
        if scrollView.contentSize.height > ceil(lineHeight), scrollView.contentOffset.y < 0.0 {
            scrollView.contentOffset.y = 0.0
        }
    }
    
    // MARK: FSTextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textField = textField as? FSTextField else { return true }
        if textField.maximumTextCount > 0 {
            // 如果是中文输入法正在输入拼音的过程中（markedTextRange 不为 nil），
            // 是不应该限制字数的（例如输入 "huang" 这5个字符，其实只是为了输入 "黄" 这一个字符），
            // 所以在 shouldChange 这里不会限制，而是放在 didChange 那里限制。
            if let _ = textField.markedTextRange {
                return true
            }
            
            var range = range
            
            /// String 的 count 是把 emoji 表情当作一个计算的，但是 emoji 表情所占的字符数量有 1、2、4、8 等，
            /// 而此处的 range 是按照实际字符数量计算的，如果和 String 的 count 相比较肯定不准确，
            /// 所以此处把 String 转成 utf16 计算整个字符串的长度。
            if NSMaxRange(range) > (textField.text?.utf16.count ?? 0) {
                // 如果 range 越界了，继续返回 true 会造成 crash
                // https://github.com/Tencent/QMUI_iOS/issues/377
                // https://github.com/Tencent/QMUI_iOS/issues/1170
                // 这里的做法是本次返回 false，并将越界的 range 缩减到没有越界的范围，再手动做该范围的替换。
                range = NSMakeRange(range.location, range.length - (NSMaxRange(range) - (textField.text?.utf16.count ?? 0)))
                if range.length > 0, let textRange = textField.fs.convertUITextRangeFromNSRange(range) {
                    textField.replace(textRange, withText: string)
                }
                return false
            }
            
            if string.isEmpty, range.length > 0 {
                // 允许删除，这段必须放在上面 #377、#1170 的逻辑后面
                return true
            }
            
            let rangeLength: Int
            if textField.shouldCountingNonASCIICharacterAsTwo {
                rangeLength = (textField.text?.fs.substring(with: range) ?? "").fs.countOfNonASCIICharacterAsTwo
            } else {
                rangeLength = range.length
            }
            if textField.p_count(of: textField.text ?? "") - rangeLength + textField.p_count(of: string) > textField.maximumTextCount {
                // 将要插入的文字裁剪成这么长，就可以让它插入了
                let substringLength = textField.maximumTextCount - textField.p_count(of: textField.text ?? "") + rangeLength
                if substringLength > 0, textField.p_count(of: string) > substringLength {
                    let allowedText = string.fs.substringAvoidBreakingUpCharacterSequences(with: .init(location: 0, length: substringLength),
                                                                                           lessValue: true,
                                                                                           countingNonASCIICharacterAsTwo: textField.shouldCountingNonASCIICharacterAsTwo) ?? ""
                    if textField.p_count(of: allowedText) <= substringLength {
                        var shouldChange = true
                        if let delegate = textField.delegate {
                            shouldChange = delegate.textField?(textField, shouldChangeCharactersIn: range, replacementString: allowedText, originalValue: true) ?? true
                        }
                        if !shouldChange {
                            return false
                        }
                        textField.text = ((textField.text ?? "") as NSString).replacingCharacters(in: range, with: allowedText)
                        /// 通过代码 ``text{set}`` 修改的文字，默认光标位置会在插入的文字开头，通常这不符合预期，因此这里将光标定位到插入的那段字符串的末尾
                        /// 注意由于粘贴后系统也会在下一个 runloop 去修改光标位置，所以我们这里也要 dispatch 到下一个 runloop 才能生效，否则会被系统的覆盖
                        /// https://github.com/Tencent/QMUI_iOS/issues/1282
                        DispatchQueue.main.async {
                            textField.fs.selectedRange = .init(location: range.location + allowedText.count, length: 0)
                        }
                        if !textField.shouldResponseToProgrammaticallyTextChanges {
                            textField.p_fireTextDidChangeEvent(for: textField)
                        }
                    }
                }
                
                if let delegate = textField.delegate {
                    delegate.textField?(textField, didPreventTextChangeIn: range, replacementString: string)
                }
                
                textField.onDidHitMaximumTextCountHandler?(textField)
                
                return false
            }
        }
        if let delegate = textField.delegate {
            return delegate.textField?(textField, shouldChangeCharactersIn: range, replacementString: string, originalValue: true) ?? true
        }
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if let delegate = self.textField?.delegate {
            return delegate.textFieldShouldBeginEditing?(textField) ?? true
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let delegate = self.textField?.delegate {
            delegate.textFieldDidBeginEditing?(textField)
        }
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if let delegate = self.textField?.delegate {
            return delegate.textFieldShouldEndEditing?(textField) ?? true
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let delegate = self.textField?.delegate {
            delegate.textFieldDidEndEditing?(textField)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        if let delegate = self.textField?.delegate {
            delegate.textFieldDidEndEditing?(textField, reason: reason)
        }
    }

    @available(iOS 13.0, *)
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if let delegate = self.textField?.delegate {
            delegate.textFieldDidChangeSelection?(textField)
        }
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if let delegate = self.textField?.delegate {
            return delegate.textFieldShouldClear?(textField) ?? true
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let delegate = self.textField?.delegate {
            return delegate.textFieldShouldReturn?(textField) ?? true
        }
        return true
    }
    
    @available(iOS 16.0, *)
    func textField(_ textField: UITextField, editMenuForCharactersIn range: NSRange, suggestedActions: [UIMenuElement]) -> UIMenu? {
        if let delegate = self.textField?.delegate {
            return delegate.textField?(textField, editMenuForCharactersIn: range, suggestedActions: suggestedActions)
        }
        return nil
    }
    
    @available(iOS 16.0, *)
    func textField(_ textField: UITextField, willPresentEditMenuWith animator: any UIEditMenuInteractionAnimating) {
        if let delegate = self.textField?.delegate {
            delegate.textField?(textField, willPresentEditMenuWith: animator)
        }
    }
    
    @available(iOS 16.0, *)
    func textField(_ textField: UITextField, willDismissEditMenuWith animator: any UIEditMenuInteractionAnimating) {
        if let delegate = self.textField?.delegate {
            delegate.textField?(textField, willDismissEditMenuWith: animator)
        }
    }
}

/// Can not use.
open class _FSTempTextField: UITextField {
    
    @available(*, unavailable)
    weak open override var delegate: (any UITextFieldDelegate)? {
        get { return super.delegate }
        set { super.delegate = newValue }
    }
    
    fileprivate func set(delegate: (any UITextFieldDelegate)?) {
        super.delegate = delegate
    }
}
