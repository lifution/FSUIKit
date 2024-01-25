//
//  FSTextViewInputViewController.swift
//  FSUIKit
//
//  Created by Sheng on 2024/1/19.
//  Copyright © 2024 Sheng. All rights reserved.
//

import UIKit

open class FSTextViewInputViewController: UIViewController {
    
    // MARK: Properties/Public
    
    public var onDidConfirmText: ((_ text: String) -> Void)?
    
    public let textView = FSTextView()
    
    // MARK: Properties/Private
    
    private let keyboardObserver = _KeyboardObserver()
    private let textViewDelegator = _InternalTextViewDelegator()
    
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
        
        do {
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
                return true
            }
        }
    }
    
    /// Invoked in the `viewDidLoad` method.
    func p_setupViews() {
        do {
            view.backgroundColor = .clear
            toolBar.translatesAutoresizingMaskIntoConstraints = false
            textView.translatesAutoresizingMaskIntoConstraints = false
            confirmButton.translatesAutoresizingMaskIntoConstraints = false
        }
        do {
            textView.font = .systemFont(ofSize: 16.0)
            textView.delegate = textViewDelegator
            textView.placeholder = "请输入..."
            textView.returnKeyType = .done
            textView.clipsToBounds = true
            textView.layer.borderWidth = UIScreen.fs.pixelOne
            textView.layer.borderColor = UIColor.fs.color(hexed: "B5B5B5")?.cgColor
            textView.layer.cornerRadius = 6.0
            textView.enablesReturnKeyAutomatically = true
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
                confirmButton.heightAnchor.constraint(equalToConstant: 35.0)
            ])
        }
        do {
            view.addSubview(toolBar)
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|",
                                                               metrics: nil,
                                                               views: ["view": toolBar]))
            view.addConstraint(NSLayoutConstraint(item: toolBar,
                                                  attribute: .height,
                                                  relatedBy: .equal,
                                                  toItem: nil,
                                                  attribute: .notAnAttribute,
                                                  multiplier: 1,
                                                  constant: 100.0))
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
            toolBar.addSubview(textView)
            toolBar.addSubview(confirmButton)
            do {
                toolBar.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[view]-12-|",
                                                                      metrics: nil,
                                                                      views: ["view": confirmButton]))
                toolBar.addConstraint(NSLayoutConstraint(item: confirmButton,
                                                         attribute: .bottom,
                                                         relatedBy: .equal,
                                                         toItem: toolBar,
                                                         attribute: .bottom,
                                                         multiplier: 1,
                                                         constant: -8.0))
            }
            do {
                toolBar.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-12-[view]-8-[button]",
                                                                      metrics: nil,
                                                                      views: ["view": textView, "button": confirmButton]))
                toolBar.addConstraint(NSLayoutConstraint(item: textView,
                                                         attribute: .top,
                                                         relatedBy: .equal,
                                                         toItem: toolBar,
                                                         attribute: .top,
                                                         multiplier: 1,
                                                         constant: 8.0))
                toolBar.addConstraint(NSLayoutConstraint(item: textView,
                                                         attribute: .bottom,
                                                         relatedBy: .equal,
                                                         toItem: toolBar,
                                                         attribute: .bottom,
                                                         multiplier: 1,
                                                         constant: -8.0))
            }
        }
    }
    
    func p_textDidChange() {
        if let range = textView.markedTextRange, let _ = textView.position(from: range.start, offset: 0) {
            // 正处于输入中文拼音还未点确定的中间状态，直接返回。
            return
        }
        if let text = textView.text {
            confirmButton.isEnabled = !text.isEmpty
        } else {
            confirmButton.isEnabled = false
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
