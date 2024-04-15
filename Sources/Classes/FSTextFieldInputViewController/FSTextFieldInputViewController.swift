//
//  FSTextFieldInputViewController.swift
//  FSUIKitSwift
//
//  Created by Sheng on 2024/1/19.
//  Copyright © 2024 Sheng. All rights reserved.
//

import UIKit

open class FSTextFieldInputViewController: UIViewController {
    
    // MARK: Properties/Public
    
    public var onDidConfirmText: ((_ text: String) -> Void)?
    
    public let textField = UITextField()
    
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
    public var shouldChangeCharactersHandler: ((_ textField: UITextField, _ range: NSRange, _ string: String) -> Bool)?
    
    /// 用于过滤字符的正则，比如限制只能输入数字: "[0-9]+"
    public var regex: String?
    
    /// 是否自动启用 `确定` 按钮。
    /// 如果为 false 则 `确定` 按钮一直可交互，如果为 ture 则 `确定` 按钮只有在输入内容后才能点击。
    /// 默认为 true。
    public var enablesConfirmKeyAutomatically = true {
        didSet {
            textField.enablesReturnKeyAutomatically = enablesConfirmKeyAutomatically
            p_updateConfirmKeyStatus()
        }
    }
    
    // MARK: Properties/Private
    
    private let keyboardObserver = FSKeyboardObserver()
    private let textFieldDelegator = _InternalTextFieldDelegator()
    
    private let toolBar = FSToolBar()
    private let summaryLabel = UILabel()
    private let confirmButton = FSButton()
    
    private var toolBarHeightConstraint: NSLayoutConstraint!
    private var toolBarBottomConstraint: NSLayoutConstraint!
    private var textFieldTopSummaryConstraint: NSLayoutConstraint!
    private var textFieldTopToolBarConstraint: NSLayoutConstraint!
    
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

extension FSTextFieldInputViewController {
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        p_setupViews()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        keyboardObserver.start()
        textField.becomeFirstResponder()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        keyboardObserver.stop()
    }
}

// MARK: - Private

private extension FSTextFieldInputViewController {
    
    /// Invoked after initialization.
    func p_didInitialize() {
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overFullScreen
        
        keyboardObserver.onKeyboardDidChange = { [weak self] transition in
            guard let self = self else { return }
            self.p_keyboardChanged(transition)
        }
        
        textFieldDelegator.shouldReturn = { [weak self] textField in
            guard let self = self else { return false }
            if let text = textField.text, !text.isEmpty {
                self.p_didPressConfirmButton()
            }
            return false
        }
        textFieldDelegator.shouldChangeCharacters = { (textField, range, string) in
            // Prvents keyboard new line.
            if string == "\n\u{07}" {
                return false
            }
            // Prvents white-space in first location.
            if range.location == 0, !string.isEmpty {
                let s = string.trimmingCharacters(in: .whitespacesAndNewlines)
                if s.isEmpty {
                    return false
                }
            }
            if let handler = self.shouldChangeCharactersHandler {
                return handler(textField, range, string)
            } else if let regex = self.regex, !string.isEmpty {
                let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
                return predicate.evaluate(with: string)
            }
            return true
        }
    }
    
    /// Invoked in the `viewDidLoad` method.
    func p_setupViews() {
        defer {
            p_updateSummary()
            p_textFieldDidChange()
        }
        do {
            view.backgroundColor = .clear
            toolBar.translatesAutoresizingMaskIntoConstraints = false
            summaryLabel.translatesAutoresizingMaskIntoConstraints = false
            textField.translatesAutoresizingMaskIntoConstraints = false
            confirmButton.translatesAutoresizingMaskIntoConstraints = false
        }
        do {
            summaryLabel.font = .systemFont(ofSize: 16.0)
//            summaryLabel.textColor = .fs.color(light: .black, dark: .fs.color(hexed: "ECECEC")!)
            summaryLabel.textColor = .fs.subtitle
            summaryLabel.numberOfLines = 0
        }
        do {
            textField.delegate = textFieldDelegator
            textField.font = .systemFont(ofSize: 16.0)
            textField.textColor = .fs.color(light: .black, dark: .fs.color(hexed: "ECECEC")!)
            textField.placeholder = "请输入..."
            textField.returnKeyType = .done
            textField.clipsToBounds = true
            textField.clearButtonMode = .always
            textField.backgroundColor = .fs.color(light: .white, dark: .fs.color(hexed: "#2f2f2e")!)
            textField.layer.cornerRadius = 6.0
            textField.enablesReturnKeyAutomatically = true
            textField.addTarget(self, action: #selector(p_textFieldDidChange), for: .editingChanged)
            do {
                let leftView = UIView()
                leftView.frame.size.width = 6.0
                textField.leftView = leftView
                textField.leftViewMode = .always
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
            toolBar.addSubview(textField)
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
                toolBar.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-12-[field]-8-[button]",
                                                                      metrics: nil,
                                                                      views: ["field": textField, "button": confirmButton]))
                toolBar.addConstraint(NSLayoutConstraint(item: textField,
                                                         attribute: .height,
                                                         relatedBy: .equal,
                                                         toItem: nil,
                                                         attribute: .notAnAttribute,
                                                         multiplier: 1,
                                                         constant: 35.0))
                toolBar.addConstraint(NSLayoutConstraint(item: textField,
                                                         attribute: .bottom,
                                                         relatedBy: .lessThanOrEqual,
                                                         toItem: toolBar,
                                                         attribute: .bottom,
                                                         multiplier: 1,
                                                         constant: -8))
                do {
                    let constraint = NSLayoutConstraint(item: textField,
                                                        attribute: .top,
                                                        relatedBy: .equal,
                                                        toItem: summaryLabel,
                                                        attribute: .bottom,
                                                        multiplier: 1,
                                                        constant: 8)
                    toolBar.addConstraint(constraint)
                    textFieldTopSummaryConstraint = constraint
                }
                textFieldTopToolBarConstraint = NSLayoutConstraint(item: textField,
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
                                                         attribute: .centerY,
                                                         relatedBy: .equal,
                                                         toItem: textField,
                                                         attribute: .centerY,
                                                         multiplier: 1,
                                                         constant: 0))
            }
        }
    }
    
    func p_updateToolBarLayout() {
        guard isViewLoaded else {
            return
        }
        view.layoutIfNeeded()
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
            toolBar.removeConstraint(textFieldTopSummaryConstraint)
            toolBar.addConstraint(textFieldTopToolBarConstraint)
        } else {
            toolBar.removeConstraint(textFieldTopToolBarConstraint)
            toolBar.addConstraint(textFieldTopSummaryConstraint)
        }
    }
    
    func p_updateConfirmKeyStatus() {
        if !enablesConfirmKeyAutomatically {
            confirmButton.isEnabled = true
        } else {
            if let text = textField.text {
                confirmButton.isEnabled = !text.isEmpty
            } else {
                confirmButton.isEnabled = false
            }
        }
    }
    
    func p_keyboardChanged(_ transition: FSKeyboardTransition) {
        let inputBarOffset: CGFloat
        if transition.isToVisible {
            inputBarOffset = -transition.toFrame.height + view.safeAreaInsets.bottom
        } else {
            inputBarOffset = 0.0
        }
        toolBarBottomConstraint.constant = inputBarOffset
        UIView.animate(withDuration: transition.animationDuration,
                       delay: 0.0,
                       options: transition.animationOption) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - Private/Actions

private extension FSTextFieldInputViewController {
    
    @objc
    func p_didTapBlankArea() {
        confirmButton.isUserInteractionEnabled = false
        textField.resignFirstResponder()
        dismiss(animated: true)
    }
    
    @objc
    func p_didPressConfirmButton() {
        if let text = textField.text, !text.isEmpty {
            onDidConfirmText?(text)
            p_didTapBlankArea()
        }
    }
    
    @objc
    func p_textFieldDidChange() {
        if let range = textField.markedTextRange, let _ = textField.position(from: range.start, offset: 0) {
            // 正处于输入中文拼音还未点确定的中间状态，直接返回。
            return
        }
        p_updateConfirmKeyStatus()
    }
}
