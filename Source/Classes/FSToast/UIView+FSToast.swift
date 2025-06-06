//
//  UIView+FSToast.swift
//  FSUIKitSwift
//
//  Created by Sheng on 2024/2/6.
//  Copyright © 2024 Sheng. All rights reserved.
//

import UIKit
import ObjectiveC

private struct _AssociatedKey {
    static var Helper = 0
}

extension FSUIKitWrapper where Base: UIView {
    
    // MARK: AssociatedProperties
    
    private var helper: _ToastHelper {
        if let helper = p_getHelper() {
            return helper
        }
        let helper = _ToastHelper(view: base)
        fp_setHelper(helper)
        return helper
    }
    
    // MARK: Private
    
    private func p_getHelper() -> _ToastHelper? {
        return objc_getAssociatedObject(base, &_AssociatedKey.Helper) as? _ToastHelper
    }
    
    private func p_show(content: FSToastContentConvertable?, isUserInteractionEnabled: Bool = true) {
        helper.fp_show(content: content, isUserInteractionEnabled: isUserInteractionEnabled)
    }
    
    private func p_dismiss() {
        helper.fp_dismiss()
    }
    
    // MARK: Fileprivate
    
    fileprivate func fp_setHelper(_ newHelper: _ToastHelper?) {
        objc_setAssociatedObject(base, &_AssociatedKey.Helper, newHelper, .OBJC_ASSOCIATION_RETAIN)
    }
    
    // MARK: Public
    
    /// 显示普通 hint 提示（自动隐藏）。
    ///
    /// - Parameters:
    ///   - hint: 提示语
    ///   - isUserInteractionEnabled: 是否允许用户触摸 toast 所在的 view。
    ///
    public func show(hint: String?, isUserInteractionEnabled: Bool = true) {
        guard let hint = hint, !hint.isEmpty else {
            return
        }
        let content = FSToastContent(style: .hint)
        content.text = hint
        p_show(content: content, isUserInteractionEnabled: isUserInteractionEnabled)
    }
    
    /// 显示 loading toast（不会自动隐藏）。
    ///
    /// - Parameters:
    ///   - text: 提示语
    ///   - isUserInteractionEnabled: 是否允许用户触摸 toast 所在的 view，loading 默认为 false。
    ///
    public func showLoading(_ text: String? = nil, isUserInteractionEnabled: Bool = false) {
        let content = FSToastContent(style: .loading)
        content.text = text
        p_show(content: content, isUserInteractionEnabled: isUserInteractionEnabled)
    }
    
    /// 显示成功 toast（带成功图标，自动隐藏）。
    ///
    /// - Parameters:
    ///   - text: 提示语
    ///   - isUserInteractionEnabled: 是否允许用户触摸 toast 所在的 view。
    ///
    public func showSuccess(_ text: String?, isUserInteractionEnabled: Bool = true) {
        let content = FSToastContent(style: .success)
        content.text = text
        p_show(content: content, isUserInteractionEnabled: isUserInteractionEnabled)
    }
    
    /// 显示失败 toast（带失败图标，自动隐藏）。
    ///
    /// - Parameters:
    ///   - text: 提示语
    ///   - isUserInteractionEnabled: 是否允许用户触摸 toast 所在的 view。
    ///
    public func showError(_ text: String?, isUserInteractionEnabled: Bool = true) {
        let content = FSToastContent(style: .error)
        content.text = text
        p_show(content: content, isUserInteractionEnabled: isUserInteractionEnabled)
    }
    
    /// 显示警告 toast（带警告图标，自动隐藏）。
    ///
    /// - Parameters:
    ///   - text: 提示语
    ///   - isUserInteractionEnabled: 是否允许用户触摸 toast 所在的 view。
    ///
    public func showWarning(_ text: String?, isUserInteractionEnabled: Bool = true) {
        let content = FSToastContent(style: .warning)
        content.text = text
        p_show(content: content, isUserInteractionEnabled: isUserInteractionEnabled)
    }
    
    /// 显示自定义 toast。
    ///
    ///   - 该方法是提供给外部显示自定义的 toast
    ///   - 是否自动隐藏，由外部自定义
    ///   - 除了 FSToastContent 的一些已提供类型，其它的 content 需要使用者自己适配主题变化
    ///
    /// - Parameters:
    ///   - text: 提示语
    ///   - isUserInteractionEnabled: 是否允许用户触摸 toast 所在的 view。
    ///
    public func show(content: FSToastContentConvertable?, isUserInteractionEnabled: Bool = true) {
        p_show(content: content, isUserInteractionEnabled: isUserInteractionEnabled)
    }
    
    /// 外部手动隐藏 toast。
    ///
    /// - Note:
    ///   - 调用该方法不会回调 `toastView.content.onDidDismiss`。
    ///
    public func dismissToast() {
        p_dismiss()
    }
}


// MARK: - _ToastHelper

private class _ToastHelper: FSKeyboardListener {
    
    // MARK: Properties/Fileprivate
    
    fileprivate var isUserInteractionEnabled: Bool {
        get { return !backgroundView.isUserInteractionEnabled }
        set { backgroundView.isUserInteractionEnabled = !newValue }
    }
    
    // MARK: Properties/Private
    
    /// toast view 显示所在的 view。
    private weak var view: UIView?
    
    /// toast 自动隐藏定时器。
    private var timer: FSTimer?
    
    /// helper 自毁定时器。
    private var destroyTimer: FSTimer?
    
    private var isViewController: Bool {
        if view?.next is UIViewController {
            return true
        }
        return false
    }
    
    private var toastView: FSToastView?
    
    private weak var centerYConstraint: NSLayoutConstraint?
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.addGestureRecognizer(UITapGestureRecognizer())
        view.addGestureRecognizer(UIPanGestureRecognizer())
        view.addGestureRecognizer(UISwipeGestureRecognizer())
        view.addGestureRecognizer(UIRotationGestureRecognizer())
        view.addGestureRecognizer(UILongPressGestureRecognizer())
        view.addGestureRecognizer(UIScreenEdgePanGestureRecognizer())
        view.addGestureRecognizer(UIPinchGestureRecognizer())
        if #available(iOS 13.0, *) {
            view.addGestureRecognizer(UIHoverGestureRecognizer())
        }
        return view
    }()
    
    // MARK: Deinitialization
    
    deinit {
        containerView.removeFromSuperview()
        backgroundView.removeFromSuperview()
    }
    
    // MARK: Initialization
    
    init(view: UIView) {
        self.view = view
        FSKeyboardManager.shared.add(self)
    }
    
    // MARK: Private
    
    private func p_startTimer(with duration: TimeInterval) {
        
        p_stopTimer()
        
        guard duration > 0.0 else {
            return
        }
        
        let timer = FSTimer(timeInterval: duration)
        timer.eventHandler = { [weak self] in
            guard let self = self else {
                return
            }
            self.p_stopTimer()
            let toastView = self.toastView
            self.p_dismiss {
                toastView?.content?.onDidDismiss?()
            }
        }
        timer.resume()
        self.timer = timer
    }
    
    private func p_stopTimer() {
        timer?.suspend()
        timer?.eventHandler = nil
        timer = nil
    }
    
    private func p_startDestroyTimer() {
        p_stopDestroyTimer()
        // 5min 内如无新的 toast 生成，则进入自毁程序。
        let timer = FSTimer(timeInterval: 5 * 60)
        timer.eventHandler = { [weak self] in
            self?.p_stopDestroyTimer()
            self?.p_destroy()
        }
        timer.resume()
        self.destroyTimer = timer
    }
    
    private func p_stopDestroyTimer() {
        destroyTimer?.suspend()
        destroyTimer?.eventHandler = nil
        destroyTimer = nil
    }
    
    private func p_destroy() {
        p_stopTimer()
        p_stopDestroyTimer()
        toastView?.removeFromSuperview()
        containerView.removeFromSuperview()
        backgroundView.removeFromSuperview()
        toastView = nil
        view?.fs.fp_setHelper(nil)
    }
    
    private func p_adjustPosition() {
        
        guard
            let toastView = toastView,
            // 只有 UIViewController.view / UIWindow 才自动避让键盘。
            (isViewController || (view is UIWindow))
        else {
            return
        }
        
        /// 是否是初次显示
        /// 初次显示不需要动画
        let isAppearing = toastView.bounds.size == .zero
        
        let manager = FSKeyboardManager.shared
        
        // 键盘隐藏，toast 复位。
        if !manager.isKeyboardVisible {
            centerYConstraint?.constant = 0
            if !isAppearing {
                UIView.animate(withDuration: 0.25) {
                    toastView.superview?.layoutIfNeeded()
                }
            }
            return
        }
        
        guard let window = manager.keyboardWindow else {
            return
        }
        
        if isAppearing {
            toastView.superview?.layoutIfNeeded()
        }
        
        let keyboardFrame = manager.keyboardFrame
        let toastFrameInWindow = toastView.superview?.convert(toastView.frame, to: window) ?? .zero
        let toastOriginalMaxY = toastFrameInWindow.maxY - (centerYConstraint?.constant ?? 0.0)
        let spacing = RemoveNaN(toastOriginalMaxY - keyboardFrame.minY)
        if spacing <= -20.0 {
            return
        }
        let translateY = spacing < 0 ? 20.0 : (20.0 + spacing)
        centerYConstraint?.constant = -translateY
        if !isAppearing {
            UIView.animate(withDuration: 0.25) {
                toastView.superview?.layoutIfNeeded()
            }
        }
    }
    
    private func p_show(content: FSToastContentConvertable?, isUserInteractionEnabled: Bool = true) {
        
        guard
            let view = self.view,
            let content = content
        else {
            return
        }
        
        p_stopTimer()
        p_stopDestroyTimer()
        
        self.isUserInteractionEnabled = isUserInteractionEnabled
        
        centerYConstraint = nil
        
        // remove previous
        if let view = toastView {
            view.removeFromSuperview()
            view.content?.onDidDismiss?()
            toastView = nil
        }
        
        containerView.removeFromSuperview()
        backgroundView.removeFromSuperview()
        
        let toastView = FSToastView()
        self.toastView = toastView
        toastView.content = content
        
        view.addSubview(backgroundView)
        view.addSubview(containerView)
        view.addSubview(toastView)
        
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        toastView.translatesAutoresizingMaskIntoConstraints = false
        
        do {
            view.addConstraint(.init(item: backgroundView,
                                     attribute: .top,
                                     relatedBy: .equal,
                                     toItem: view,
                                     attribute: .top,
                                     multiplier: 1.0,
                                     constant: 0.0))
            view.addConstraint(.init(item: backgroundView,
                                     attribute: .left,
                                     relatedBy: .equal,
                                     toItem: view,
                                     attribute: .left,
                                     multiplier: 1.0,
                                     constant: 0.0))
            view.addConstraint(.init(item: backgroundView,
                                     attribute: .width,
                                     relatedBy: .equal,
                                     toItem: view,
                                     attribute: .width,
                                     multiplier: 1.0,
                                     constant: 0.0))
            view.addConstraint(.init(item: backgroundView,
                                     attribute: .height,
                                     relatedBy: .equal,
                                     toItem: view,
                                     attribute: .height,
                                     multiplier: 1.0,
                                     constant: 0.0))
        }
        do {
            if isViewController {
                view.addConstraint(.init(item: containerView,
                                         attribute: .top,
                                         relatedBy: .equal,
                                         toItem: view.safeAreaLayoutGuide,
                                         attribute: .top,
                                         multiplier: 1.0,
                                         constant: 0.0))
                view.addConstraint(.init(item: containerView,
                                         attribute: .left,
                                         relatedBy: .equal,
                                         toItem: view,
                                         attribute: .left,
                                         multiplier: 1.0,
                                         constant: 0.0))
                view.addConstraint(.init(item: containerView,
                                         attribute: .width,
                                         relatedBy: .equal,
                                         toItem: view,
                                         attribute: .width,
                                         multiplier: 1.0,
                                         constant: 0.0))
                view.addConstraint(.init(item: containerView,
                                         attribute: .bottom,
                                         relatedBy: .equal,
                                         toItem: view.safeAreaLayoutGuide,
                                         attribute: .bottom,
                                         multiplier: 1.0,
                                         constant: 0.0))
            } else {
                view.addConstraint(.init(item: containerView,
                                         attribute: .top,
                                         relatedBy: .equal,
                                         toItem: view,
                                         attribute: .top,
                                         multiplier: 1.0,
                                         constant: 0.0))
                view.addConstraint(.init(item: containerView,
                                         attribute: .left,
                                         relatedBy: .equal,
                                         toItem: view,
                                         attribute: .left,
                                         multiplier: 1.0,
                                         constant: 0.0))
                view.addConstraint(.init(item: containerView,
                                         attribute: .width,
                                         relatedBy: .equal,
                                         toItem: view,
                                         attribute: .width,
                                         multiplier: 1.0,
                                         constant: 0.0))
                view.addConstraint(.init(item: containerView,
                                         attribute: .height,
                                         relatedBy: .equal,
                                         toItem: view,
                                         attribute: .height,
                                         multiplier: 1.0,
                                         constant: 0.0))
            }
        }
        do {
            view.addConstraint(.init(item: toastView,
                                     attribute: .centerX,
                                     relatedBy: .equal,
                                     toItem: containerView,
                                     attribute: .centerX,
                                     multiplier: 1.0,
                                     constant: 0.0))
            let centerY = NSLayoutConstraint(item: toastView,
                                             attribute: .centerY,
                                             relatedBy: .equal,
                                             toItem: containerView,
                                             attribute: .centerY,
                                             multiplier: 1.0,
                                             constant: 0.0)
            view.addConstraint(centerY)
            centerYConstraint = centerY
        }
        
        p_adjustPosition()
        
        content.tapticEffect.feedback()
        
        if let animation = toastView.content?.animation {
            toastView.isUserInteractionEnabled = false
            animation.presentingAnimationBehavior(for: toastView, in: view) { [weak self] in
                guard let self = self else {
                    return
                }
                toastView.isUserInteractionEnabled = true
                // Fix: 动画结束时，toast 已更新，进而导致 toast 显示时间紊乱。
                if let view = self.toastView, view === toastView {
                    self.p_startTimer(with: content.duration)
                }
            }
        } else {
            p_startTimer(with: content.duration)
        }
    }
    
    private func p_dismiss(_ completion: (() -> Void)? = nil) {
        
        // 无论是如何来到这一步的，都不需要定时器了。
        p_stopTimer()
        
        guard let toastView = toastView else {
            completion?()
            p_startDestroyTimer()
            return
        }
        
        /// 开始隐藏 toastView，从此刻开始，toastView 的交互已无意义。
        toastView.isUserInteractionEnabled = false
        
        let destroy: (() -> Void) = { [weak self] in
            guard let self = self else {
                return
            }
            toastView.removeFromSuperview()
            // Fix: 上一个 toast 动画期间又显示了新的 toast，做这些操作会导致无法把持新的 toast。
            if let view = self.toastView, view === toastView {
                self.containerView.removeFromSuperview()
                self.backgroundView.removeFromSuperview()
                self.toastView = nil
                self.isUserInteractionEnabled = true
                // 隐藏后开始自毁倒计时。
                self.p_startDestroyTimer()
            }
        }
        
        if let view = self.view, let animation = toastView.content?.animation {
            animation.dismissingAnimationBehavior(for: toastView, in: view) {
                completion?()
                destroy()
            }
        } else {
            completion?()
            destroy()
        }
    }
    
    // MARK: Fileprivate
    
    fileprivate func fp_show(content: FSToastContentConvertable?, isUserInteractionEnabled: Bool = true) {
        p_show(content: content, isUserInteractionEnabled: isUserInteractionEnabled)
    }
    
    fileprivate func fp_dismiss(_ completion: (() -> Void)? = nil) {
        p_dismiss(completion)
    }
    
    // MARK: FSKeyboardListener
    
    func keyboardChanged(_ transition: FSKeyboardTransition) {
        p_adjustPosition()
    }
}
