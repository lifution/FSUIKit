//
//  FSTextView.swift
//  FSUIKitSwift
//
//  Created by Sheng on 2024/1/13.
//  Copyright © 2023 Sheng. All rights reserved.
//
//  代码参考于: https://github.com/Tencent/QMUI_iOS/blob/master/QMUIKit/QMUIComponents/QMUITextView.m

import UIKit

/// 自定义 UITextView。
///
/// 提供的特性如下：
/// 1. 支持 placeholder 并支持更改 placeholderColor；若使用了富文本文字，则 placeholder 的样式也会跟随文字的样式（除了 placeholder 颜色）。
/// 2. 支持在文字发生变化时计算内容高度并通知 delegate。
/// 3. 支持限制输入框最大高度，一般配合第 2 点使用。
/// 4. 支持限制输入的文本的最大长度，默认不限制。
/// 5. 修正系统 UITextView 在输入时自然换行的时候，contentOffset 的滚动位置没有考虑 textContainerInset.bottom。
///
/// - Note:
///   - FSTextView 内部已经实现了 delegate，外部设置 ``delegate`` 不会影响内部的代码运行。
///
open class FSTextView: _FSTempTextView {
    
    // MARK: Properties/Public
    
    /// placeholder 文本。
    open var placeholder: String? = nil {
        didSet {
            p_updatePlaceholderStyle()
        }
    }
    
    /// 富文本样式的 placeholder。
    ///
    /// - Note:
    ///   - 该属性比 placeholder 的优先级更高。
    ///   - 设置该属性需要使用者自己配置颜色，FSTextView 内部不会为其配置默认颜色，也不会使用 placeholderColor。
    ///
    open var attributedPlaceholder: NSAttributedString? = nil {
        didSet {
            p_updatePlaceholderStyle()
        }
    }
    
    /// placeholder 文本颜色。
    open var placeholderColor: UIColor? {
        didSet {
            p_updatePlaceholderStyle()
        }
    }
    
    /// placeholder 在默认位置上的偏移（默认位置会自动根据 textContainerInset、contentInset 来调整）。
    open var placeholderMargins: UIEdgeInsets = .zero
    
    /// 显示允许输入的最大文字长度，默认为 0，即不限制长度，
    open var maximumTextCount = 0
    
    /// 最大高度，当设置了这个属性后，超过这个高度值的 frame 是不生效的。默认为 CGFloat.greatestFiniteMagnitude，也即无限制。
    /// 设置为 0 也表示不限制。
    open var maximumHeight: CGFloat = CGFloat.greatestFiniteMagnitude {
        didSet {
            if maximumHeight <= 0.0 {
                maximumHeight = CGFloat.greatestFiniteMagnitude
            }
        }
    }
    
    /// 外部设置的代理对象，此处提供是为了方便外部从 FSTextView 读取外部设置的代理对象。
    open weak var delegate: (any FSTextViewDelegate)?
    
    /// 当通过 `text setter`、`attributedText setter` 等方式修改文字时，
    /// 是否应该自动触发 `UITextViewDelegate` 里的 `textView(:shouldChangeTextIn:replacementText:)`、`textViewDidChange(:)` 方法。
    /// 默认为 true。
    ///
    /// - Note: 系统的 UITextView 对这种行为默认是 false。
    ///
    open var shouldResponseToProgrammaticallyTextChanges = true
    
    /// 在使用 maximumTextCount 功能的时候，是否把文字长度按照「中文 2 个字符、英文 1 个字符」的方式来计算。
    /// 默认为 false。
    open var shouldCountingNonASCIICharacterAsTwo: Bool = false
    
    /// 高度更新回调，外部可实现该 closure 监听，也可实现 FSTextViewDelegate 监听。
    open var heightDidChangeHandler: ((_ newHeight: CGFloat) -> Void)?
    
    /// 达到最大限制数量时的回调，外部可实现该 closure 监听，也可实现 FSTextViewDelegate 监听。
    open var onDidHitMaximumTextCountHandler: ((_ textView: FSTextView) -> Void)?
    
    /// 控制输入框是否要出现「粘贴」menu。
    ///
    /// superReturnValue: `super.canPerformAction(:withSender:)` 的返回值，当你不需要控制这个 closure 的返回值时，可以返回 superReturnValue。
    /// closure return: 控制是否要出现「粘贴」menu，true 表示出现，false 表示不出现。当你想要返回系统默认的结果时，请返回参数 superReturnValue。
    open var canPerformPasteActionHandler: ((_ sender: Any?, _ superReturnValue: Bool) -> Bool)?
    
    /// 当输入框的「粘贴」事件被触发时，可通过这个 block 去接管事件的响应。
    /// sender: 「粘贴」事件触发的来源，例如可能是一个 UIMenuController。
    /// closure return: 用于控制是否要调用系统默认的 `paste(:)` 实现，true 表示执行完 closure 后继续调用系统默认实现，false 表示执行完 closure 后就结束了，不调用 super。
    open var pasteActionHandler: ((_ sender: Any?) -> Bool)?
    
    /// 当 `text` / `attributedText` 改变时，会调用该解析器去修改输入框内的文本内容。
    /// 比如需要高亮部分内容，或者插入表情，就可以在解析器相应的协议方法中处理。
    /// 默认为 nil。
    public var textParser: FSTextViewTextParseable?
    
    /// 纯文本，外部可读取该字段获取输入框内容的纯文本内容。
    open var plainText: String {
        var text = ""
        if let parser = textParser, let string = parser.plainText(of: attributedText, for: .init(location: 0, length: attributedText.length)) {
            text = string
        } else {
            text = attributedText.string
        }
        return text
    }
    
    /// 当前 view 的 size。
    /// 当该属性更新时会回调 `viewSizeDidChange` 方法。
    public private(set) var viewSize: CGSize = .zero
    
    // MARK: Properties/Private
    
    /// 如果在 `handleTextChanged(_:)` 里主动调整 contentOffset，则为了避免被系统的自动调整覆盖，会利用这个标记去屏蔽系统对 `setContentOffset(_:)` 的调用。
    private var shouldRejectSystemScroll: Bool = true
    
    /// placeholder 的默认颜色，当 placeholderColor 无效时就会使用该默认颜色。
    private let placeholderDefaultColor: UIColor? = UIColor.fs.color(hexed: "C4C8D0")
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12.0) // UITextView 默认字体，实测得到，勿改。
        label.alpha = 0.0
        label.numberOfLines = 0
        return label
    }()
    
    private let delegator = _FSTextViewDelegator()
    
    // MARK: Deinitialization
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Initialization
    
    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        p_didInitialize()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        p_didInitialize()
    }
    
    // MARK: Open
    
    /// 当 viewSize 更改后会回调该方法。
    dynamic open func viewSizeDidChange() {
        
    }
}

// MARK: - Override

extension FSTextView {
    
    open override var text: String! {
        get { return super.text }
        set {
            let value = newValue ?? ""
            
            // 如果前后文字没变化，则什么都不做。
            if !p_isCurrentTextDifferent(to: value) {
                super.text = value
                return
            }
            
            // 前后文字发生变化，则要根据是否主动接管 delegate 来决定是否要询问 delegate。
            if !shouldResponseToProgrammaticallyTextChanges {
                super.text = value
                // 如果不需要主动接管事件，则只要触发内部的监听即可，不用调用 delegate 系列方法。
                NotificationCenter.default.post(name: UITextView.textDidChangeNotification, object: self)
                return
            }
            
            let textBeforeChange = text ?? ""
            let shouldChangeText = delegator.textView(self, shouldChangeTextIn: .init(location: 0, length: textBeforeChange.count), replacementText: value)
            
            if !shouldChangeText {
                // 不应该改变文字，所以连 super 都不调用，直接结束方法。
                return
            }
            
            // 应该改变文字，则调用 super 来改变文字，然后主动调用 `textViewDidChange:`。
            super.text = value
            delegator.textViewDidChange(self)
            NotificationCenter.default.post(name: UITextView.textDidChangeNotification, object: self)
        }
    }
    
    open override var attributedText: NSAttributedString! {
        get { return super.attributedText }
        set {
            // Fix: 手动修改 text 后，undo 行为会导致 crash，在没找到更好的解决方法前，直接屏蔽 undo 行为。
            undoManager?.removeAllActions()
            
            // 如果前后文字没变化，则什么都不做。
            if !p_isCurrentTextDifferent(to: newValue.string) {
                super.attributedText = newValue
                return
            }
            
            // 前后文字发生变化，则要根据是否主动接管 delegate 来决定是否要询问 delegate。
            if !shouldResponseToProgrammaticallyTextChanges {
                super.attributedText = newValue
                // 如果不需要主动接管事件，则只要触发内部的监听即可，不用调用 delegate 系列方法。
                NotificationCenter.default.post(name: UITextView.textDidChangeNotification, object: self)
                return
            }
            
            let textBeforeChange = attributedText.string
            let shouldChangeText = delegator.textView(self, shouldChangeTextIn: .init(location: 0, length: textBeforeChange.count), replacementText: newValue.string)
            
            if !shouldChangeText {
                // 不应该改变文字，所以连 super 都不调用，直接结束方法。
                return
            }
            
            // 应该改变文字，则调用 super 来改变文字，然后主动调用 `textViewDidChange:`。
            super.attributedText = newValue
            delegator.textViewDidChange(self)
            NotificationCenter.default.post(name: UITextView.textDidChangeNotification, object: self)
        }
    }
    
    open override var font: UIFont? {
        didSet {
            p_updatePlaceholderStyle()
        }
    }
    
    open override var frame: CGRect {
        get { return super.frame }
        set {
            var newFrame = newValue
            newFrame.size.height = min(newFrame.height, maximumHeight)
            // 重写了 UITextView 的 drawRect: 后，对于带小数点的 frame 会导致文本框右边多出一条黑线，原因未明，暂时这样处理
            // https://github.com/Tencent/QMUI_iOS/issues/557
            super.frame = newFrame.fs.flatted()
        }
    }
    
    open override var bounds: CGRect {
        get { return super.bounds }
        set {
            // FIXME: 重写了 UITextView 的 `draw(:)` 后，对于带小数点的 frame 会导致文本框右边多出一条黑线，原因未明，暂时这样处理。
            // https://github.com/Tencent/QMUI_iOS/issues/557
            super.bounds = newValue.fs.flatted()
        }
    }
    
    open override var textAlignment: NSTextAlignment {
        didSet {
            p_updatePlaceholderStyle()
        }
    }
    
    open override var textContainerInset: UIEdgeInsets {
        didSet {
            if #available(iOS 11.0, *) {} else {
                // iOS 11 以下修改 textContainerInset 的时候无法自动触发 layoutSubview，导致 placeholderLabel 无法更新布局。
                setNeedsLayout()
            }
        }
    }
    
    open override var typingAttributes: [NSAttributedString.Key : Any] {
        didSet {
            p_updatePlaceholderStyle()
        }
    }
    
    open override var description: String {
        return "\(super.description); text.length: \(text.count) | \(p_count(of: text)); markedTextRange: \((markedTextRange != nil) ? "\(markedTextRange!)" : "nil")。"
    }
    
    open override func cut(_ sender: Any?) {
        guard let parser = textParser else {
            super.cut(sender)
            return
        }
        if let text = parser.plainText(of: attributedText, for: selectedRange) {
            UIPasteboard.general.string = text
        }
        let selectedRange = self.selectedRange
        let attributeContent = NSMutableAttributedString(attributedString: attributedText)
        attributeContent.replaceCharacters(in: selectedRange, with: "")
        attributedText = attributeContent
        self.selectedRange = .init(location: selectedRange.location, length: 0)
    }
    
    open override func copy(_ sender: Any?) {
        guard let parser = textParser else {
            super.copy(sender)
            return
        }
        if let text = parser.plainText(of: attributedText, for: selectedRange) {
            UIPasteboard.general.string = text
        }
    }
    
    open override func paste(_ sender: Any?) {
        var shouldCallSuper = true
        if let handler = pasteActionHandler {
            shouldCallSuper = handler(sender)
        }
        do {
            if let parser = textParser,
               let string = UIPasteboard.general.string,
               !string.isEmpty,
               let attributedPasteString = parser.parse(text: string)
            {
                shouldCallSuper = false
                
                let selectedRange = self.selectedRange
                let attributedContent = NSMutableAttributedString(attributedString: attributedText)
                attributedContent.replaceCharacters(in: selectedRange, with: attributedPasteString)
                self.attributedText = attributedContent
                self.selectedRange = .init(location: selectedRange.location + attributedPasteString.length, length: 0)
            }
        }
        if shouldCallSuper {
            super.paste(sender)
        }
    }
    
    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        let superReturnValue = super.canPerformAction(action, withSender: sender)
        if action == #selector(paste(_:)), let handler = canPerformPasteActionHandler {
            return handler(sender, superReturnValue)
        }
        return superReturnValue
    }
    
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        var result = super.sizeThatFits(size)
        result.height = min(result.height, maximumHeight)
        return result
    }
    
    open override func draw(_ rect: CGRect) {
        super.draw(rect)
        p_updatePlaceholderHiddenStatus()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        do {
            sendSubviewToBack(placeholderLabel)
            /// 当系统的 textView.textContainerInset 为 .zero 时，文字与 textView 边缘的间距。
            /// 实测得到，请勿修改（在输入框 font 大于 13 时准确，小于等于 12 时，y 有 -1px 的偏差）。
            let fixTextInsets: UIEdgeInsets = .init(top: 0.0, left: 6.0, bottom: 0.0, right: 5.0)
            let labelMargins: UIEdgeInsets = textContainerInset.fs.add(placeholderMargins).fs.add(fixTextInsets)
            let limitWidth = bounds.width - contentInset.fs.horizontalValue() - labelMargins.fs.horizontalValue()
            let limitHeight = bounds.height - contentInset.fs.verticalValue() - labelMargins.fs.verticalValue()
            var labelSize = placeholderLabel.sizeThatFits(.init(width: limitWidth, height: limitHeight))
            labelSize.height = min(limitHeight, labelSize.height)
            placeholderLabel.frame = CGRect.fs.flatRect(x: labelMargins.left, y: labelMargins.top, width: limitWidth, height: labelSize.height)
            if semanticContentAttribute == .forceRightToLeft {
                placeholderLabel.frame =  placeholderLabel.frame.fs.mirrorsForRTLLanguage(with: frame.width)
            }
        }
        do {
            if viewSize != frame.size {
                let old = viewSize
                viewSize = frame.size
                p_viewSizeDidChange()
                if old == .zero {
                    p_recalculateViewHeight()
                }
            }
        }
    }
}

// MARK: - Private

private extension FSTextView {
    
    /// Invoked after initialization.
    func p_didInitialize() {
        do {
            scrollsToTop = false
            contentInsetAdjustmentBehavior = .never
            textDragInteraction?.isEnabled = false
            delegator.textView = self
            set(delegate: delegator)
        }
        do {
            placeholderLabel.textColor = placeholderDefaultColor
            addSubview(placeholderLabel)
        }
        do {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(p_didReceive(notification:)),
                                                   name: UITextView.textDidChangeNotification,
                                                   object: nil)
        }
    }
    
    func p_viewSizeDidChange() {
        viewSizeDidChange()
    }
    
    func p_count(of string: String?) -> Int {
        guard let s = string, !s.isEmpty else {
            return 0
        }
        if shouldCountingNonASCIICharacterAsTwo {
            return s.fs.countOfNonASCIICharacterAsTwo
        }
        return s.count
    }
    
    func p_isCurrentTextDifferent(to text: String?) -> Bool {
        // UITextView 如果文字为空，self.text 永远返回 "" 而不是 nil（即便你设置为 nil 后立即 get 出来也是）。
        guard let text = text else {
            return !self.text.isEmpty
        }
        return (self.text != text)
    }
    
    func p_recalculateViewHeight() {
        let height = FSFlat(sizeThatFits(.init(width: viewSize.width, height: CGFloat.greatestFiniteMagnitude)).height)
        // 通知 delegate 去更新 textView 的高度。
        if height != FSFlat(viewSize.height) {
            heightDidChangeHandler?(height)
            delegator.textView(self, heightDidChangeTo: height)
        }
    }
    
    func p_updatePlaceholderStyle() {
        if let text = attributedPlaceholder {
            placeholderLabel.attributedText = text
        } else {
            var attributes = typingAttributes
            attributes[.foregroundColor] = placeholderColor ?? placeholderDefaultColor
            if semanticContentAttribute == .forceRightToLeft {
                let style = NSMutableParagraphStyle()
                style.alignment = .right
                attributes[.paragraphStyle] = style
            }
            placeholderLabel.attributedText = NSAttributedString(string: placeholder ?? "", attributes: attributes)
        }
        setNeedsLayout()
    }
    
    func p_updatePlaceholderHiddenStatus() {
        // 用 alpha 来让 placeholder 隐藏，从而尽量避免因为显隐 placeholder 导致 layout。
        if text.isEmpty, (!(placeholder?.isEmpty ?? true) || !(attributedPlaceholder?.string.isEmpty ?? true)) {
            placeholderLabel.alpha = 1.0
        } else {
            placeholderLabel.alpha = 0.0
        }
    }
    
    func p_scrollCaretToVisible(animated: Bool) {
        guard !bounds.isEmpty, let range = selectedTextRange else {
            return
        }
        let caretRect = self.caretRect(for: range.end)
        p_scrollRectToVisible(caretRect, animated: animated)
    }
    
    func p_scrollRectToVisible(_ rect: CGRect, animated: Bool) {
        // isScrollEnabled 为 false 时可能产生不合法的 rect 值 https://github.com/Tencent/QMUI_iOS/issues/205。
        if !rect.fs.isValidated {
            return
        }
        if rect.minY == (contentOffset.y + textContainerInset.top) {
            // 命中这个条件说明已经不用调整了，直接 return，避免继续走下面的判断，会重复调整，导致光标跳动。
            return
        }
        var contentOffsetY = contentOffset.y
        if rect.minY < (contentOffset.y + textContainerInset.top) {
            // 光标在可视区域上方，往下滚动。
            contentOffsetY = rect.minY - textContainerInset.top - contentInset.top
        } else if rect.maxY > (self.contentOffset.y + bounds.height - textContainerInset.bottom - contentInset.bottom) {
            // 光标在可视区域下方，往上滚动。
            contentOffsetY = rect.maxY - bounds.height + textContainerInset.bottom + contentInset.bottom
        } else {
            // 光标在可视区域内，不用调整。
            return
        }
        setContentOffset(.init(x: contentOffset.x, y: contentOffsetY), animated: animated)
    }
}

// MARK: - Actions

private extension FSTextView {
    
    @objc func p_didReceive(notification: Notification) {
        guard
            notification.name == UITextView.textDidChangeNotification,
            let textView = notification.object as? FSTextView,
            textView === self
        else {
            return
        }
        
        // 输入字符的时候，placeholder 隐藏。
        p_updatePlaceholderHiddenStatus()
        
        // 计算高度
        p_recalculateViewHeight()
        
        // textView 尚未被展示到界面上时，此时过早进行光标调整会计算错误。
        if window == nil {
            return
        }
        
        if !isEditable {
            return // 不可编辑的 textView 不会显示光标。
        }
        
        shouldRejectSystemScroll = true
        
        // 用 dispatch 延迟一下，因为在文字发生换行时，系统自己会做一些滚动，我们要延迟一点才能避免被系统的滚动覆盖。
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.shouldRejectSystemScroll = false
            self.p_scrollCaretToVisible(animated: false)
        }
    }
}

// MARK: - Parse Text

fileprivate extension FSTextView {
    
    func fp_parseText() {
        guard
            let parser = textParser,
            let attributedText = attributedText
        else {
            return
        }
        var range = selectedRange
        if let newText = parser.parse(attributedText: attributedText, selectedRange: &range) {
            let _text = NSMutableAttributedString(attributedString: newText)
            do {
                let spacing = UIScreen.fs.pixelOne * 2.0
                _text.addAttribute(.kern, value: spacing, range: .init(location: 0, length: newText.length))
                _text.fs.setLineSpacing(5.0, range: .init(location: 0, length: _text.length))
            }
            self.attributedText = _text
            self.selectedRange  = range
        }
    }
}


// MARK: - _FSTextViewDelegator

private class _FSTextViewDelegator: NSObject, FSTextViewDelegate {
    
    weak var textView: FSTextView?
    
    func textView(_ textView: FSTextView, heightDidChangeTo newHeight: CGFloat) {
        self.textView?.delegate?.textView?(textView, heightDidChangeTo: newHeight)
    }
    
    func textViewShouldReturn(_ textView: FSTextView) -> Bool {
        return self.textView?.delegate?.textViewShouldReturn?(textView) ?? true
    }
    
    func textView(_ textView: FSTextView, didPreventTextChangeIn range: NSRange, replacementText text: String) {
        self.textView?.onDidHitMaximumTextCountHandler?(textView)
        self.textView?.delegate?.textView?(textView, didPreventTextChangeIn: range, replacementText: text)
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return self.textView?.delegate?.textViewShouldBeginEditing?(textView) ?? true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        return self.textView?.delegate?.textViewShouldEndEditing?(textView) ?? true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.textView?.delegate?.textViewDidBeginEditing?(textView)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.textView?.delegate?.textViewDidEndEditing?(textView)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let textView = textView as? FSTextView else {
            return true
        }
        
        if text == "\n" {
            if self.textViewShouldReturn(textView) {
                /// `textViewShouldReturn(:)` 返回 true 表示程序认为当前的点击是为了进行类似「发送」之类的操作，
                /// 所以此处返回 false 阻止 "\n" 被输入到文本框里。
                return false
            }
        }
        
        if textView.maximumTextCount > 0 {
            
            /// 如果是中文输入法正在输入拼音的过程中（markedTextRange 不为 nil），
            /// 是不应该限制字数的（例如输入 "huang" 这5个字符，其实只是为了输入 "黄" 这一个字符），
            /// 所以在 shouldChange 这里不会限制，而是放在 didChange 那里限制。
            if let _ = textView.markedTextRange {
                return true
            }
            
            // deleting
            if range.length > 0, text.count <= 0 {
                /// String 的 count 是把 emoji 表情当作一个计算的，但是 emoji 表情所占的字符数量有 1、2、4、8 等，
                /// 而此处的 range 是按照实际字符数量计算的，如果和 String 的 count 相比较肯定不准确，
                /// 所以此处把 String 转成 utf16 计算整个字符串的长度。
                if NSMaxRange(range) > textView.text.utf16.count {
                    // https://github.com/Tencent/QMUI_iOS/issues/377
                    return false
                } else {
                    return true
                }
            }
            
            let rangeLength: Int = {
                if textView.shouldCountingNonASCIICharacterAsTwo {
                    if let r = Range(range, in: textView.text) {
                        let substring = String(textView.text[r])
                        return substring.fs.countOfNonASCIICharacterAsTwo
                    }
                }
                return range.length
            }()
            let textWillOutofMaximumTextCount = (textView.p_count(of: textView.text) - rangeLength + textView.p_count(of: text)) > textView.maximumTextCount
            if textWillOutofMaximumTextCount {
                /// 当输入的文本达到最大长度限制后，此时继续点击 return 按钮（相当于尝试插入 "\n"），就会认为总文字长度已经超过最大长度限制，
                /// 所以此次 return 按钮的点击被拦截，外界无法感知到有这个 return 事件发生，所以这里为这种情况做了特殊保护。
                if (textView.p_count(of: textView.text) - rangeLength) == textView.maximumTextCount, text == "\n" {
                    return false
                }
                
                // 将要插入的文字裁剪成多长，就可以让它插入了。
                let substringLength = textView.maximumTextCount - textView.p_count(of: textView.text) + rangeLength
                
                if substringLength > 0, textView.p_count(of: text) > substringLength {
                    let allowedText = text.fs.substringAvoidBreakingUpCharacterSequences(range: .init(location: 0, length: substringLength), lessValue: true, countingNonASCIICharacterAsTwo: textView.shouldCountingNonASCIICharacterAsTwo)
                    if textView.p_count(of: allowedText) <= substringLength, let insertRange = Range(range, in: textView.text) {
                        textView.text = textView.text.replacingCharacters(in: insertRange, with: allowedText)
                        textView.selectedRange = .init(location: range.location + substringLength, length: 0)
                        if !textView.shouldResponseToProgrammaticallyTextChanges {
                            self.textView?.delegate?.textViewDidChange?(textView)
                        }
                    }
                }
                
                self.textView(textView, didPreventTextChangeIn: range, replacementText: text)
                
                return false
            }
        }
        
        return self.textView?.delegate?.textView?(textView, shouldChangeTextIn: range, replacementText: text) ?? true
    }
    
    /// 1、iOS 10 以下的版本，从中文输入法的候选词里选词输入，是不会走到 `textView(:shouldChangeTextIn:replacementText:)` 的，所以要在这里截断文字。
    /// 2、如果是中文输入法正在输入拼音的过程中（markedTextRange 不为 nil），是不应该限制字数的（例如输入 "huang" 这5个字符，其实只是为了输入 "黄" 这一个字符），
    ///    所以在 shouldChange 那边不会限制，而是放在 didChange 这里限制。
    func textViewDidChange(_ textView: UITextView) {
        defer {
            self.textView?.delegate?.textViewDidChange?(textView)
        }
        if let range = textView.markedTextRange, let _ = textView.position(from: range.start, offset: 0) {
            // 正处于输入中文拼音还未点确定的中间状态，直接返回。
            return
        }
        guard
            let textView = textView as? FSTextView,
            textView.maximumTextCount > 0
        else {
            return
        }
        do {
            // 文本处理，比如插入表情。
            textView.fp_parseText()
        }
        if textView.p_count(of: textView.text) > textView.maximumTextCount {
            let range = NSRange(location: 0, length: textView.maximumTextCount)
            textView.text = textView.text.fs.substringAvoidBreakingUpCharacterSequences(range: range, lessValue: true, countingNonASCIICharacterAsTwo: textView.shouldCountingNonASCIICharacterAsTwo)
            /// 如果是在这里被截断，是无法得知截断前光标所处的位置及要输入的文本的，所以只能将当前的 selectedRange 传过去，而 replacementText 为 `""`。
            self.textView(textView, didPreventTextChangeIn: textView.selectedRange, replacementText: "")
        }
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        self.textView?.delegate?.textViewDidChangeSelection?(textView)
    }
    
    @available(iOS 10.0, *)
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return self.textView?.delegate?.textView?(textView, shouldInteractWith: URL, in: characterRange, interaction: interaction) ?? true
    }
    
    @available(iOS 10.0, *)
    func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return self.textView?.delegate?.textView?(textView, shouldInteractWith: textAttachment, in: characterRange, interaction: interaction) ?? true
    }
    
    @available(iOS, introduced: 7.0, deprecated: 10.0)
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        return self.textView?.delegate?.textView?(textView, shouldInteractWith: URL, in: characterRange) ?? true
    }

    @available(iOS, introduced: 7.0, deprecated: 10.0)
    func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange) -> Bool {
        return self.textView?.delegate?.textView?(textView, shouldInteractWith: textAttachment, in: characterRange) ?? true
    }
    
    @available(iOS 16.0, *)
    func textView(_ textView: UITextView, editMenuForTextIn range: NSRange, suggestedActions: [UIMenuElement]) -> UIMenu? {
        return self.textView?.delegate?.textView?(textView, editMenuForTextIn: range, suggestedActions: suggestedActions)
    }
    
    @available(iOS 16.0, *)
    func textView(_ textView: UITextView, willPresentEditMenuWith animator: any UIEditMenuInteractionAnimating) {
        self.textView?.delegate?.textView?(textView, willPresentEditMenuWith: animator)
    }
    
    @available(iOS 16.0, *)
    func textView(_ textView: UITextView, willDismissEditMenuWith animator: any UIEditMenuInteractionAnimating) {
        self.textView?.delegate?.textView?(textView, willDismissEditMenuWith: animator)
    }
    
    @available(iOS 17.0, *)
    func textView(_ textView: UITextView, primaryActionFor textItem: UITextItem, defaultAction: UIAction) -> UIAction? {
        self.textView?.delegate?.textView?(textView, primaryActionFor: textItem, defaultAction: defaultAction)
    }
    
    @available(iOS 17.0, *)
    func textView(_ textView: UITextView, menuConfigurationFor textItem: UITextItem, defaultMenu: UIMenu) -> UITextItem.MenuConfiguration? {
        self.textView?.delegate?.textView?(textView, menuConfigurationFor: textItem, defaultMenu: defaultMenu)
    }
    
    @available(iOS 17.0, *)
    func textView(_ textView: UITextView, textItemMenuWillDisplayFor textItem: UITextItem, animator: any UIContextMenuInteractionAnimating) {
        self.textView?.delegate?.textView?(textView, textItemMenuWillDisplayFor: textItem, animator: animator)
    }
    
    @available(iOS 17.0, *)
    func textView(_ textView: UITextView, textItemMenuWillEndFor textItem: UITextItem, animator: any UIContextMenuInteractionAnimating) {
        self.textView?.delegate?.textView?(textView, textItemMenuWillEndFor: textItem, animator: animator)
    }
    
    @available(iOS 18.0, *)
    func textViewWritingToolsWillBegin(_ textView: UITextView) {
        self.textView?.delegate?.textViewWritingToolsWillBegin?(textView)
    }
    
    @available(iOS 18.0, *)
    func textViewWritingToolsDidEnd(_ textView: UITextView) {
        self.textView?.delegate?.textViewWritingToolsDidEnd?(textView)
    }
    
    @available(iOS 18.0, *)
    func textView(_ textView: UITextView, writingToolsIgnoredRangesInEnclosingRange enclosingRange: NSRange) -> [NSValue] {
        return self.textView?.delegate?.textView?(textView, writingToolsIgnoredRangesInEnclosingRange: enclosingRange) ?? []
    }
    
    @available(iOS 18.0, *)
    func textView(_ textView: UITextView, willBeginFormattingWith viewController: UITextFormattingViewController) {
        self.textView?.delegate?.textView?(textView, willBeginFormattingWith: viewController)
    }
    
    @available(iOS 18.0, *)
    func textView(_ textView: UITextView, didBeginFormattingWith viewController: UITextFormattingViewController) {
        self.textView?.delegate?.textView?(textView, didBeginFormattingWith: viewController)
    }
    
    @available(iOS 18.0, *)
    func textView(_ textView: UITextView, willEndFormattingWith viewController: UITextFormattingViewController) {
        self.textView?.delegate?.textView?(textView, willEndFormattingWith: viewController)
    }
    
    @available(iOS 18.0, *)
    func textView(_ textView: UITextView, didEndFormattingWith viewController: UITextFormattingViewController) {
        self.textView?.delegate?.textView?(textView, didEndFormattingWith: viewController)
    }
    
    // MARK: UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        textView?.delegate?.scrollViewDidScroll?(scrollView)
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        textView?.delegate?.scrollViewDidZoom?(scrollView)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        textView?.delegate?.scrollViewWillBeginDragging?(scrollView)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        textView?.delegate?.scrollViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        textView?.delegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        textView?.delegate?.scrollViewWillBeginDecelerating?(scrollView)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        textView?.delegate?.scrollViewDidEndDecelerating?(scrollView)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        textView?.delegate?.scrollViewDidEndScrollingAnimation?(scrollView)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        textView?.delegate?.viewForZooming?(in: scrollView)
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        textView?.delegate?.scrollViewWillBeginZooming?(scrollView, with: view)
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        textView?.delegate?.scrollViewDidEndZooming?(scrollView, with: view, atScale: scale)
    }
    
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        return textView?.delegate?.scrollViewShouldScrollToTop?(scrollView) ?? true
    }
    
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        textView?.delegate?.scrollViewDidScrollToTop?(scrollView)
    }
    
    func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        textView?.delegate?.scrollViewDidChangeAdjustedContentInset?(scrollView)
    }
}

/// Can not use.
open class _FSTempTextView: UITextView {
    
    @available(*, unavailable)
    open weak override var delegate: (any UITextViewDelegate)? {
        get { return super.delegate }
        set { super.delegate = newValue }
    }
    
    fileprivate func set(delegate: (any UITextViewDelegate)?) {
        super.delegate = delegate
    }
}
