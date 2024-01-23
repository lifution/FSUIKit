//
//  FSTextFieldInputViewController.swift
//  FSUIKit
//
//  Created by Sheng on 2024/1/19.
//  Copyright © 2024 Sheng. All rights reserved.
//

import UIKit

open class FSTextFieldInputViewController: UIViewController {
    
    // MARK: Properties/Internal
    
    public var onDidConfirmText: ((_ text: String) -> Void)?
    
    public let textField = UITextField()
    
    // MARK: Properties/Private
    
    private let keyboardObserver = _KeyboardObserver()
    private let textFieldDelegator = _InternalTextFieldDelegator()
    
    private let toolBar = FSToolBar()
    private let confirmButton = FSButton()
    private var toolBarBottomConstraint: NSLayoutConstraint?
    
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
        
        do {
            textFieldDelegator.shouldReturn = { [weak self] textField in
                guard let self = self else { return false }
                if let text = textField.text, !text.isEmpty {
                    self.p_didPressConfirmButton()
                }
                return false
            }
            textFieldDelegator.shouldChangeCharacters = { [weak self] (textField, range, string) in
                guard let self = self else { return false }
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
                return true
            }
        }
    }
    
    /// Invoked in the `viewDidLoad` method.
    func p_setupViews() {
        do {
            view.backgroundColor = .clear
            toolBar.translatesAutoresizingMaskIntoConstraints = false
            textField.translatesAutoresizingMaskIntoConstraints = false
            confirmButton.translatesAutoresizingMaskIntoConstraints = false
        }
        do {
            textField.delegate = textFieldDelegator
            textField.placeholder = "请输入..."
            textField.returnKeyType = .done
            textField.clipsToBounds = true
            textField.clearButtonMode = .always
            textField.layer.borderWidth = UIScreen.fs.pixelOne
            textField.layer.borderColor = UIColor.fs.color(hexed: "B5B5B5")?.cgColor
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
            confirmButton.setTitleColor(.white, for: .normal)
            confirmButton.addTarget(self, action: #selector(p_didPressConfirmButton), for: .touchUpInside)
            NSLayoutConstraint.activate([
                confirmButton.widthAnchor.constraint(equalToConstant: 60.0),
                confirmButton.heightAnchor.constraint(equalToConstant: 34.0)
            ])
        }
        do {
            view.addSubview(toolBar)
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|",
                                                               metrics: nil,
                                                               views: ["view": toolBar]))
            let bottom = NSLayoutConstraint(item: toolBar,
                                            attribute: .bottom,
                                            relatedBy: .equal,
                                            toItem: view.safeAreaLayoutGuide,
                                            attribute: .bottom,
                                            multiplier: 1.0,
                                            constant: 0)
            view.addConstraint(bottom)
            toolBarBottomConstraint = bottom
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
            toolBar.addSubview(textField)
            toolBar.addSubview(confirmButton)
            do {
                toolBar.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[view]-12-|",
                                                                      metrics: nil,
                                                                      views: ["view": confirmButton]))
                toolBar.addConstraint(NSLayoutConstraint(item: confirmButton,
                                                         attribute: .centerY,
                                                         relatedBy: .equal,
                                                         toItem: toolBar,
                                                         attribute: .centerY,
                                                         multiplier: 1,
                                                         constant: 0))
            }
            do {
                toolBar.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-12-[field]-8-[button]",
                                                                      metrics: nil,
                                                                      views: ["field": textField, "button": confirmButton]))
                toolBar.addConstraint(NSLayoutConstraint(item: textField,
                                                         attribute: .centerY,
                                                         relatedBy: .equal,
                                                         toItem: toolBar,
                                                         attribute: .centerY,
                                                         multiplier: 1,
                                                         constant: 0))
                toolBar.addConstraint(NSLayoutConstraint(item: textField,
                                                         attribute: .height,
                                                         relatedBy: .equal,
                                                         toItem: nil,
                                                         attribute: .notAnAttribute,
                                                         multiplier: 1,
                                                         constant: 34.0))
            }
        }
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
        if let text = textField.text {
            confirmButton.isEnabled = !text.isEmpty
        } else {
            confirmButton.isEnabled = false
        }
    }
}
