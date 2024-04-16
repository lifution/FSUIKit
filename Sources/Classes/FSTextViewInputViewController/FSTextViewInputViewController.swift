//
//  FSTextViewInputViewController.swift
//  FSUIKitSwift
//
//  Created by Sheng on 2024/1/19.
//  Copyright © 2024 Sheng. All rights reserved.
//

import UIKit

open class FSTextViewInputViewController: FSViewController {
    
    // MARK: Properties/Public
    
    public var onDidConfirmText: ((_ text: String) -> Void)?
    
    public let textView = FSTextView()
    
    /// 顶部简介说明
    public var summary: String? {
        didSet {
            if isViewLoaded {
                p_updateSummary()
            }
        }
    }
    
    /// 顶部简介说明文字颜色
    public var summaryTextColor: UIColor? {
        didSet {
            summaryLabel.textColor = summaryTextColor ?? .fs.subtitle
        }
    }
    
    /// 判断是否允许输入，完全把输入的控制交由外部。
    /// 当该 closure 有效时，`regex` 属性不会再生效。
    var shouldChangeCharactersHandler: ((_ textView: UITextView, _ range: NSRange, _ text: String) -> Bool)?
    
    /// 用于过滤字符的正则，比如限制只能输入数字: "[0-9]+"
    public var regex: String?
    
    /// 是否自动启用 `确定` 按钮。
    /// 如果为 false 则 `确定` 按钮一直可交互，如果为 ture 则 `确定` 按钮只有在输入内容后才能点击。
    /// 默认为 true。
    public var enablesConfirmKeyAutomatically = true {
        didSet {
            textView.enablesReturnKeyAutomatically = enablesConfirmKeyAutomatically
            p_updateConfirmKeyStatus()
        }
    }
    
    // MARK: Properties/Private
    
    private let keyboardObserver = FSKeyboardObserver()
    private let textViewDelegator = _InternalTextViewDelegator()
    
    private let toolBar = FSToolBar()
    private let summaryLabel = UILabel()
    private let confirmButton = FSButton()
    
    private var toolBarHeightConstraint: NSLayoutConstraint!
    private var toolBarBottomConstraint: NSLayoutConstraint!
    private var textViewHeightConstraint: NSLayoutConstraint!
    private var textViewTopSummaryConstraint: NSLayoutConstraint!
    private var textViewTopToolBarConstraint: NSLayoutConstraint!
    
    private let textViewMinimalHeight = 35.0
    
    // MARK: Initialization
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        p_didInitialize()
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Life Cycle

extension FSTextViewInputViewController {
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        p_setupViews()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        keyboardObserver.start()
        textView.becomeFirstResponder()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        keyboardObserver.stop()
    }
}

// MARK: - Override

extension FSTextViewInputViewController {
    
    open override func viewSizeDidChange() {
        super.viewSizeDidChange()
        p_updateToolBarLayout()
    }
}

// MARK: - Private

private extension FSTextViewInputViewController {
    
    /// Invoked after initialization.
    func p_didInitialize() {
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overFullScreen
        
        keyboardObserver.onKeyboardDidChange = { [weak self] transition in
            guard let self = self else { return }
            self.p_keyboardChanged(transition)
        }
        
        textViewDelegator.textDidChange = { [weak self] textView in
            guard let self = self else { return }
            self.p_textDidChange()
        }
        textViewDelegator.shouldChangeText = { [weak self] (textView, range, text) in
            guard let self = self else { return false }
            if text == "\n" {
                self.p_didPressConfirmButton()
                return false
            }
            // Prvents white-space in first location.
            if range.location == 0, !text.isEmpty {
                let s = text.trimmingCharacters(in: .whitespacesAndNewlines)
                if s.isEmpty {
                    return false
                }
            }
            if let handler = shouldChangeCharactersHandler {
                return handler(textView, range, text)
            } else if let regex = regex, !text.isEmpty {
                let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
                return predicate.evaluate(with: text)
            }
            return true
        }
    }
    
    /// Invoked in the `viewDidLoad` method.
    func p_setupViews() {
        defer {
            p_updateSummary()
            p_textDidChange()
            if !textView.text.isEmpty {
                textView.layoutIfNeeded()
            }
        }
        do {
            view.backgroundColor = .clear
            toolBar.translatesAutoresizingMaskIntoConstraints = false
            summaryLabel.translatesAutoresizingMaskIntoConstraints = false
            textView.translatesAutoresizingMaskIntoConstraints = false
            confirmButton.translatesAutoresizingMaskIntoConstraints = false
        }
        do {
            summaryLabel.font = .systemFont(ofSize: 14.0)
            summaryLabel.textColor = .fs.subtitle
            summaryLabel.numberOfLines = 0
        }
        do {
            textView.delegate = textViewDelegator
            textView.font = .systemFont(ofSize: 16.0)
            textView.textColor = .fs.color(light: .black, dark: .fs.color(hexed: "ECECEC")!)
            textView.placeholder = "请输入..."
            textView.returnKeyType = .done
            textView.clipsToBounds = true
            textView.backgroundColor = .fs.color(light: .white, dark: .fs.color(hexed: "#2f2f2e")!)
            textView.layer.cornerRadius = 6.0
            textView.enablesReturnKeyAutomatically = true
            textView.maximumHeight = 100.0
            textView.heightDidChangeHandler = { [unowned self] height in
                self.p_textViewPrefersUpdateTo(height: height)
            }
        }
        do {
            confirmButton.isEnabled = false
            confirmButton.backgroundColor = .fs.color(hexed: "#387bfb")
            confirmButton.titleLabel?.font = .boldSystemFont(ofSize: 16.0)
            confirmButton.layer.cornerRadius = 6.0
            confirmButton.setTitle("确定", for: .normal)
            confirmButton.setTitleColor(.fs.color(hexed: "ECECEC"), for: .normal)
            confirmButton.addTarget(self, action: #selector(p_didPressConfirmButton), for: .touchUpInside)
            NSLayoutConstraint.activate([
                confirmButton.widthAnchor.constraint(equalToConstant: 60.0),
                confirmButton.heightAnchor.constraint(equalToConstant: 35.0)
            ])
        }
        do {
            let backgroundView = UIView()
            backgroundView.backgroundColor = .black.withAlphaComponent(0.2)
            backgroundView.isUserInteractionEnabled = false
            backgroundView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(backgroundView)
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|",
                                                               metrics: nil,
                                                               views: ["view": backgroundView]))
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|",
                                                               metrics: nil,
                                                               views: ["view": backgroundView]))
        }
        do {
            toolBar.backgroundView.backgroundColor = .fs.color(light: .fs.color(hexed: "#f4f4f3")!, dark: .fs.color(hexed: "#242423")!)
            view.addSubview(toolBar)
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|",
                                                               metrics: nil,
                                                               views: ["view": toolBar]))
            let height = NSLayoutConstraint(item: toolBar,
                                            attribute: .height,
                                            relatedBy: .equal,
                                            toItem: nil,
                                            attribute: .notAnAttribute,
                                            multiplier: 1.0,
                                            constant: 100.0)
            toolBarHeightConstraint = height
            view.addConstraint(height)
            let bottom = NSLayoutConstraint(item: toolBar,
                                            attribute: .bottom,
                                            relatedBy: .equal,
                                            toItem: view.safeAreaLayoutGuide,
                                            attribute: .bottom,
                                            multiplier: 1.0,
                                            constant: 0)
            toolBarBottomConstraint = bottom
            view.addConstraint(bottom)
            // tap view
            do {
                let tapView = UIView()
                tapView.isUserInteractionEnabled = true
                tapView.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(tapView)
                view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|",
                                                                   metrics: nil,
                                                                   views: ["view": tapView]))
                view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[tap][tool]",
                                                                   metrics: nil,
                                                                   views: ["tap": tapView, "tool": toolBar]))
                let tap = UITapGestureRecognizer(target: self, action: #selector(p_didTapBlankArea))
                tapView.addGestureRecognizer(tap)
            }
        }
        do {
            toolBar.addSubview(summaryLabel)
            toolBar.addSubview(textView)
            toolBar.addSubview(confirmButton)
            do {
                toolBar.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-12-[view]->=12-|",
                                                                      metrics: nil,
                                                                      views: ["view": summaryLabel]))
                toolBar.addConstraint(NSLayoutConstraint(item: summaryLabel,
                                                         attribute: .top,
                                                         relatedBy: .equal,
                                                         toItem: toolBar,
                                                         attribute: .top,
                                                         multiplier: 1,
                                                         constant: 8))
            }
            do {
                toolBar.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-12-[view]-8-[button]",
                                                                      metrics: nil,
                                                                      views: ["view": textView, "button": confirmButton]))
                toolBar.addConstraint(NSLayoutConstraint(item: textView,
                                                         attribute: .bottom,
                                                         relatedBy: .lessThanOrEqual,
                                                         toItem: toolBar,
                                                         attribute: .bottom,
                                                         multiplier: 1,
                                                         constant: -8))
                do {
                    let constraint = NSLayoutConstraint(item: textView,
                                                        attribute: .height,
                                                        relatedBy: .equal,
                                                        toItem: nil,
                                                        attribute: .notAnAttribute,
                                                        multiplier: 1,
                                                        constant: textViewMinimalHeight)
                    toolBar.addConstraint(constraint)
                    textViewHeightConstraint = constraint
                }
                do {
                    let constraint = NSLayoutConstraint(item: textView,
                                                        attribute: .top,
                                                        relatedBy: .equal,
                                                        toItem: summaryLabel,
                                                        attribute: .bottom,
                                                        multiplier: 1,
                                                        constant: 8)
                    toolBar.addConstraint(constraint)
                    textViewTopSummaryConstraint = constraint
                }
                textViewTopToolBarConstraint = NSLayoutConstraint(item: textView,
                                                                  attribute: .top,
                                                                  relatedBy: .equal,
                                                                  toItem: toolBar,
                                                                  attribute: .top,
                                                                  multiplier: 1,
                                                                  constant: 8)
            }
            do {
                toolBar.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[view]-12-|",
                                                                      metrics: nil,
                                                                      views: ["view": confirmButton]))
                toolBar.addConstraint(NSLayoutConstraint(item: confirmButton,
                                                         attribute: .bottom,
                                                         relatedBy: .equal,
                                                         toItem: textView,
                                                         attribute: .bottom,
                                                         multiplier: 1,
                                                         constant: 0))
            }
        }
    }
    
    func p_textViewPrefersUpdateTo(height: CGFloat) {
        textViewHeightConstraint.constant = max(textViewMinimalHeight, height)
        p_updateToolBarLayout()
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    func p_updateToolBarLayout() {
        guard isViewLoaded else {
            return
        }
        if !summaryLabel.isHidden {
            summaryLabel.preferredMaxLayoutWidth = toolBar.frame.width - 24.0
        }
        let size = toolBar.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        toolBarHeightConstraint.constant = FSFlat(size.height)
    }
    
    func p_updateSummary() {
        defer {
            p_updateToolBarLayout()
        }
        summaryLabel.text = summary
        summaryLabel.isHidden = summary?.isEmpty ?? true
        if summaryLabel.isHidden {
            toolBar.removeConstraint(textViewTopSummaryConstraint)
            toolBar.addConstraint(textViewTopToolBarConstraint)
        } else {
            toolBar.removeConstraint(textViewTopToolBarConstraint)
            toolBar.addConstraint(textViewTopSummaryConstraint)
        }
    }
    
    func p_updateConfirmKeyStatus() {
        if !enablesConfirmKeyAutomatically {
            confirmButton.isEnabled = true
        } else {
            if let text = textView.text {
                confirmButton.isEnabled = !text.isEmpty
            } else {
                confirmButton.isEnabled = false
            }
        }
    }
    
    func p_textDidChange() {
        if let range = textView.markedTextRange, let _ = textView.position(from: range.start, offset: 0) {
            // 正处于输入中文拼音还未点确定的中间状态，直接返回。
            return
        }
        p_updateConfirmKeyStatus()
    }
    
    func p_keyboardChanged(_ transition: FSKeyboardTransition) {
        do {
            let inputBarOffset: CGFloat
            if transition.isToVisible {
                inputBarOffset = -transition.toFrame.height + view.safeAreaInsets.bottom
            } else {
                inputBarOffset = 0.0
            }
            toolBarBottomConstraint?.constant = inputBarOffset
        }
        UIView.animate(withDuration: transition.animationDuration,
                       delay: 0.0,
                       options: transition.animationOption) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - Private/Actions

private extension FSTextViewInputViewController {
    
    @objc
    func p_didTapBlankArea() {
        confirmButton.isUserInteractionEnabled = false
        textView.resignFirstResponder()
        dismiss(animated: true)
    }
    
    @objc
    func p_didPressConfirmButton() {
        if let text = textView.text, !text.isEmpty {
            onDidConfirmText?(text)
            p_didTapBlankArea()
        }
    }
}
