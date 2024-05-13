//
//  FSKeyboardManager.swift
//  FSUIKitSwift
//
//  Created by Sheng on 2024/1/19.
//  Copyright © 2024 Sheng. All rights reserved.
//

import UIKit
import ObjectiveC

/// A FSKeyboardManager object lets you get the system keyboard information,
/// and track the keyboard visible/frame/transition.
///
/// - Not work in AppExtension.
/// - You should access this class in main thread.
/// - Compatible: iPhone & iPad.
/// - The observer will **not retain** by FSKeyboardManager, no need to worry about memory leaks.
///
public final class FSKeyboardManager: NSObject {
    
    // MARK: Properties/Public
    
    /// Get the keyboard window. nil if there's no keyboard window.
    public var keyboardWindow: UIWindow? {
        return p_keyboardWindow()
    }
    
    /// Get the keyboard view. nil if there's no keyboard view.
    public var keyboardView: UIView? {
        /// Not work in AppExtension.
        guard !UIApplication.fs.isAppExtension else {
            return nil
        }
        for window in UIApplication.shared.windows {
            if let view = p_getKeyboardView(from: window) {
                return view
            }
        }
        if let view = p_getKeyboardView(from: UIApplication.shared.keyWindow) {
            return view
        }
        return nil
    }
    
    /// Whether the keyboard is visible.
    public var isKeyboardVisible: Bool {
        guard let window = keyboardWindow, let view = keyboardView else {
            return false
        }
        let rect = window.bounds.intersection(view.frame)
        guard !rect.isNull, !rect.isInfinite else {
            return false
        }
        return rect.width > 0.0 && rect.height > 0.0
    }
    
    /// Get the keyboard frame. `CGRect.zero` if there's no keyboard view.
    /// Use `FSKeyboardManager.shared.convert(_:to:)` to convert frame to specified view.
    public var keyboardFrame: CGRect {
        guard let keyboard = keyboardView else {
            return .zero
        }
        var frame: CGRect = keyboard.frame
        if let window = keyboard.window {
            frame = window.convert(keyboard.frame, to: nil)
        }
        return frame
    }
    
    // MARK: Properties/Private
    
    private let observers = NSHashTable<AnyObject>(options: [.weakMemory, .objectPointerPersonality], capacity: 0)
    private var fromFrame: CGRect = .zero
    private var isFromVisible = false
    private var notificationFromFrame: CGRect = .zero
    private var notificationToFrame: CGRect = .zero
    private var notificationDuration: TimeInterval = 0.0
    private var notificationCurve: UIView.AnimationCurve = .easeInOut
    private var hasNotification = false
    private var hasObservedChange = false
    private var lastIsNotification = false
    private var observedToFrame: CGRect = .zero
    
    // MARK: Initialization
    
    public static let shared = FSKeyboardManager()
    
    private override init() {
        super.init()
        do {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(p_didReceive(notification:)),
                                                   name: UIResponder.keyboardWillChangeFrameNotification,
                                                   object: nil)
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(p_didReceive(notification:)),
                                                   name: UIResponder.keyboardDidChangeFrameNotification,
                                                   object: nil)
        }
    }
}

// MARK: - Private

private extension FSKeyboardManager {
    
    func p_initFrameObserver() {
        guard let keyboardView = keyboardView else {
            return
        }
        if let _ = _FSKeyboardViewFrameObserver.observer(for: keyboardView) {
            return
        }
        let observer = _FSKeyboardViewFrameObserver()
        observer.notify = { [weak self] (keyboard) in
            self?.p_keyboardFrameChanged(keyboard)
        }
        observer.add(to: keyboardView)
    }
    
    func p_removeFrameObserver() {
        guard
            let keyboardView = keyboardView,
            let observer = _FSKeyboardViewFrameObserver.observer(for: keyboardView)
        else {
            return
        }
        observer.add(to: nil)
    }
    
    func p_keyboardWindow() -> UIWindow? {
        
        /// Not work in AppExtension.
        guard !UIApplication.fs.isAppExtension else {
            return nil
        }
        
        for w in UIApplication.shared.windows {
            if let _ = p_getKeyboardView(from: w) {
                return w
            }
        }
        
        let window = UIApplication.shared.keyWindow
        if let _ = p_getKeyboardView(from: window) {
            return window
        }
        
        var kbWindows = [UIWindow]()
        for window in UIApplication.shared.windows {
            let windowName = NSStringFromClass(type(of: window).self)
            if #available(iOS 9.0, *) {
                // UIRemoteKeyboardWindow
                if windowName.count == 22,
                   windowName.hasPrefix("UI"),
                   windowName.hasSuffix("RemoteKeyboardWindow")
                {
                    kbWindows.append(window)
                }
            } else {
                // UITextEffectsWindow
                if windowName.count == 19,
                   windowName.hasPrefix("UI"),
                   windowName.hasSuffix("TextEffectsWindow")
                {
                    kbWindows.append(window)
                }
            }
        }
        
        if kbWindows.count == 1 {
            return kbWindows.first
        }
        
        return nil
    }
    
    func p_getKeyboardView(from window: UIWindow?) -> UIView? {
        /*
         iOS 6/7:
         UITextEffectsWindow
            UIPeripheralHostView << keyboard
         
         iOS 8:
         UITextEffectsWindow
            UIInputSetContainerView
                UIInputSetHostView << keyboard
         
         iOS 9:
         UIRemoteKeyboardWindow
            UIInputSetContainerView
                UIInputSetHostView << keyboard
         */
        guard let window = window else {
            return nil
        }
        
        /**
         从给定的 window 里寻找代表键盘当前布局位置的 view。
         iOS 15 及以前（包括用 Xcode 13 编译的 App 运行在 iOS 16 上的场景），键盘的 UI 层级是：
         |- UIApplication.windows
            |- UIRemoteKeyboardWindow
                |- UIInputSetContainerView
                    |- UIInputSetHostView - 键盘及 webView 里的输入工具栏（上下键、Done键）
                        |- _UIKBCompatInputView - 键盘主体按键
                        |- TUISystemInputAssistantView - 键盘顶部的候选词栏、emoji 键盘顶部的搜索框
                        |- _UIRemoteKeyboardPlaceholderView - webView 里的输入工具栏的占位（实际的 view 在 UITextEffectsWindow 里）
         
         iOS 16 及以后（仅限用 Xcode 14 及以上版本编译的 App），UIApplication.windows 里已经不存在 UIRemoteKeyboardWindow 了，所以退而求其次，我们通过 UITextEffectsWindow 里的 UIInputSetHostView 来获取键盘的位置——这两个 window 在布局层面可以理解为镜像关系。
         |- UIApplication.windows
            |- UITextEffectsWindow
                |- UIInputSetContainerView
                    |- UIInputSetHostView - 键盘及 webView 里的输入工具栏（上下键、Done键）
                        |- _UIRemoteKeyboardPlaceholderView - 整个键盘区域，包含顶部候选词栏、emoji 键盘顶部搜索栏（有时候不一定存在）
                        |- UIWebFormAccessory - webView 里的输入工具栏的占位
                        |- TUIInputAssistantHostView - 外接键盘时可能存在，此时不一定有 placeholder
                |- UIInputSetHostView - 可能存在多个，但只有一个里面有 _UIRemoteKeyboardPlaceholderView
         
         所以只要找到 UIInputSetHostView 即可，优先从 UIRemoteKeyboardWindow 找，不存在的话则从 UITextEffectsWindow 找。
         */
        if #available(iOS 16.0, *) {
            var kbView: UIView? = nil
            let windowName = "\(type(of: window))"
            if windowName == "UIRemoteKeyboardWindow" || windowName == "UITextEffectsWindow" {
                var container: UIView? = nil
                for subview in window.subviews {
                    if "\(type(of: subview))" == "UIInputSetContainerView" {
                        container = subview
                        break
                    }
                }
                if let view = container {
                    for subview in view.subviews {
                        if "\(type(of: subview))" == "UIInputSetHostView" {
                            kbView = subview
                            break
                        }
                    }
                }
            }
            return kbView
        }
        
        // Get the window
        let windowName = NSStringFromClass(type(of: window).self)
        if #available(iOS 9.0, *) {
            // UIRemoteKeyboardWindow
            guard
                windowName.count == 22,
                windowName.hasPrefix("UI"),
                windowName.hasSuffix("RemoteKeyboardWindow")
            else {
                return nil
            }
        } else {
            // UITextEffectsWindow
            guard
                windowName.count == 19,
                windowName.hasPrefix("UI"),
                windowName.hasSuffix("TextEffectsWindow")
            else {
                return nil
            }
        }
        
        // Get the view
        if #available(iOS 8.0, *) {
            // UIInputSetContainerView
            for view in window.subviews {
                let viewName = NSStringFromClass(type(of: view).self)
                if viewName.count != 23,
                   !viewName.hasPrefix("UI"),
                   !viewName.hasSuffix("InputSetContainerView")
                {
                    continue
                }
                // UIInputSetHostView
                for subView in view.subviews {
                    let subViewName = NSStringFromClass(type(of: subView).self)
                    if subViewName.count != 18,
                       !subViewName.hasPrefix("UI"),
                       !subViewName.hasSuffix("InputSetHostView")
                    {
                        continue
                    }
                    return subView
                }
            }
        } else {
            // UIPeripheralHostView
            for view in window.subviews {
                let viewName = NSStringFromClass(type(of: view).self)
                if viewName.count != 20,
                   !viewName.hasPrefix("UI"),
                   !viewName.hasSuffix("PeripheralHostView")
                {
                    continue
                }
                return view
            }
        }
        
        return nil
    }
    
    func p_keyboardFrameChanged(_ keyboard: UIView) {
        guard
            let keyboardView = keyboardView,
            keyboard === keyboardView
        else {
            return
        }
        
        if let window = keyboard.window {
            observedToFrame = window.convert(keyboard.frame, to: nil)
        } else {
            observedToFrame = keyboard.frame
        }
        
        hasObservedChange  = true
        lastIsNotification = false
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(p_notifyAllObservers), object: nil)
        perform(#selector(p_notifyAllObservers), with: nil, afterDelay: 0.0, inModes: [.common])
    }
    
    @objc
    func p_notifyAllObservers() {
        
        /// Not work in AppExtension.
        guard !UIApplication.fs.isAppExtension else {
            return
        }
        
        guard let keyboard = keyboardView else {
            return
        }
        
        var _window = keyboard.window
        if _window == nil {
            _window = UIApplication.shared.keyWindow
        }
        if _window == nil {
            _window = UIApplication.shared.windows.first
        }
        
        guard let window = _window else {
            return
        }
        
        var trans = FSKeyboardTransition()
        
        // from
        if fromFrame.width == 0.0, fromFrame.height == 0.0 { // first notify
            fromFrame.size.width  = window.bounds.size.width
            fromFrame.size.height = trans.toFrame.size.height
            fromFrame.origin.x = trans.toFrame.origin.x
            fromFrame.origin.y = window.bounds.height
        }
        trans.fromFrame = fromFrame
        trans.isFromVisible = isFromVisible
        
        // to
        if lastIsNotification || (hasObservedChange && observedToFrame == notificationToFrame) {
            trans.toFrame = notificationToFrame
            trans.animationDuration = notificationDuration
            trans.animationCurve    = notificationCurve
            trans.animationOption   = {
                switch notificationCurve {
                case .easeInOut:
                    return .curveEaseInOut
                case .easeIn:
                    return .curveEaseIn
                case .easeOut:
                    return .curveEaseOut
                case .linear:
                    return .curveLinear
                default:
                    return .curveLinear
                }
            }()
        } else {
            trans.toFrame = observedToFrame
        }
        
        if trans.toFrame.width > 0, trans.toFrame.height > 0 {
            let rect = window.bounds.intersection(trans.toFrame)
            if !rect.isNull, !rect.isEmpty {
                trans.isToVisible = true
            }
        }
        
        if trans.toFrame != fromFrame {
            observers.allObjects.forEach {
                if let observer = $0 as? FSKeyboardListener {
                    observer.keyboardChanged(trans)
                }
            }
        }
        
        hasNotification = false
        hasObservedChange = false
        fromFrame = trans.toFrame
        isFromVisible = trans.isToVisible
    }
}

// MARK: - Private/Actions

private extension FSKeyboardManager {
    
    @objc
    func p_didReceive(notification: Notification) {
        
        guard let info = notification.userInfo else {
            return
        }
        
        p_initFrameObserver()
        
        guard
            let after = info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            after.size.width > 0.0, // ignore zero end frame
            after.size.height > 0.0 // ignore zero end frame
        else {
            return
        }
        
        // will change frame
        if notification.name == UIResponder.keyboardWillChangeFrameNotification {
            
            guard let before = info[UIResponder.keyboardFrameBeginUserInfoKey] as? CGRect else {
                return
            }
            
            hasNotification       = true
            lastIsNotification    = true
            notificationFromFrame = before
            notificationToFrame   = after
            notificationCurve     = {
                if let curveInt = info[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int,
                   let curve = UIView.AnimationCurve(rawValue: curveInt)
                {
                    return curve
                }
                return .easeInOut
            }()
            notificationDuration  = {
                if let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval {
                    return duration
                }
                return 0.0
            }()
            
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(p_notifyAllObservers), object: nil)
            if notificationDuration == 0.0 {
                perform(#selector(p_notifyAllObservers), with: nil, afterDelay: 0.0, inModes: [.common])
            } else {
                p_notifyAllObservers()
            }
        }
        
        // did change frame
        if notification.name == UIResponder.keyboardDidChangeFrameNotification {
            
            notificationToFrame  = after
            notificationCurve    = .easeInOut
            notificationDuration = 0.0
            hasNotification      = true
            lastIsNotification   = true
            
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(p_notifyAllObservers), object: nil)
            perform(#selector(p_notifyAllObservers), with: nil, afterDelay: 0.0, inModes: [.common])
            
            do {
                /**
                 Fix:
                 
                 在 iOS11 以下系统版本中，键盘隐藏后，UIInputSetHostView(即 keyboardWindow) 在 dealloc 之前，
                 _FSKeyboardViewFrameObserver 并没有移除相关的 kvo 监听，因此导致 crash。
                 
                 crash 日志如下：
                     ```
                     Terminating app due to uncaught exception 'NSInternalInconsistencyException',
                     reason: 'An instance 0x159d68440 of class UIInputSetHostView was deallocated
                     while key value observers were still registered with it.'
                     ```
                 */
                if !isKeyboardVisible {
                    p_removeFrameObserver()
                }
            }
        }
    }
}

// MARK: - Public

public extension FSKeyboardManager {
    
    /// Add an observer to manager to get keyboard change information.
    /// This method makes a weak reference to the observer.
    ///
    /// - ⚠️ The observer will **not retain** by FSKeyboardManager, no need to worry about memory leaks.
    /// - This method will do nothing if the observer is nil, or already added.
    ///
    /// - Parameter observer: An observer.
    ///
    func add(_ observer: FSKeyboardListener?) {
        guard let observer = observer else {
            return
        }
        observers.add(observer)
    }
    
    /// Remove an observer from manager.
    ///
    /// - This method will do nothing if the observer is nil, or not in manager.
    ///
    /// - Parameter observer: An observer.
    ///
    func remove(_ observer: FSKeyboardListener?) {
        guard let observer = observer else {
            return
        }
        observers.remove(observer)
    }
    
    /// Convert rect to specified view or window.
    ///
    /// - Parameters:
    ///   - rect: The frame rect.
    ///   - view: A specified view or window (pass nil to convert for main window).
    ///
    /// - Returns: The converted rect in specifeid view.
    ///
    func convert(_ rect: CGRect, to view: UIView?) -> CGRect {
        
        /// Not work in AppExtension.
        guard !UIApplication.fs.isAppExtension else {
            return .zero
        }
        
        guard !rect.isNull, !rect.isInfinite else {
            return rect
        }
        
        var _mainWindow = UIApplication.shared.keyWindow
        if _mainWindow == nil {
            _mainWindow = UIApplication.shared.windows.first
        }
        
        guard let mainWindow = _mainWindow else {
            return rect
        }
        
        var newRect = mainWindow.convert(rect, from: nil)
        
        guard let view = view else {
            return mainWindow.convert(newRect, to: nil)
        }
        
        if view === mainWindow {
            return newRect
        }
        
        let _toWindow: UIWindow? = {
            if view is UIWindow {
                return view as? UIWindow
            }
            return view.window
        }()
        
        guard let toWindow = _toWindow else {
            return mainWindow.convert(newRect, to: view)
        }
        
        if toWindow === mainWindow {
            return mainWindow.convert(newRect, to: view)
        }
        
        // in different window
        newRect = mainWindow.convert(newRect, to: mainWindow)
        newRect = toWindow.convert(newRect, from: mainWindow)
        newRect = view.convert(newRect, from: toWindow)
        
        return newRect
    }
}

// MARK: - _FSKeyboardViewFrameObserver

/// Observer for view's frame/bounds/center/transform.
private class _FSKeyboardViewFrameObserver: NSObject {
    
    // MARK: Properties/Fileprivate
    
    var notify: ((_ keyboard: UIView) -> Void)?
    
    // MARK: Properties/Private
    
    static var AssociatedKey = 0
    
    private weak var keyboardView: UIView?
    
    // MARK: Deinitialization
    
    deinit {
        p_removeFrameObserver()
    }
    
    // MARK: Override
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard let change = change else {
            return
        }
        
        if let isPrior = change[.notificationIsPriorKey] as? Bool, isPrior {
            return
        }
        
        guard let changeKind = change[.kindKey] as? NSKeyValueChange, changeKind == .setting else {
            return
        }
        
        if let view = keyboardView {
            notify?(view)
        }
    }
    
    // MARK: Private
    
    private func p_addFrameObserver() {
        guard let view = keyboardView else {
            return
        }
        view.addObserver(self, forKeyPath: "frame", options: [], context: nil)
        view.addObserver(self, forKeyPath: "center", options: [], context: nil)
        view.addObserver(self, forKeyPath: "bounds", options: [], context: nil)
        view.addObserver(self, forKeyPath: "transform", options: [], context: nil)
    }
    
    private func p_removeFrameObserver() {
        guard let view = keyboardView else {
            return
        }
        view.removeObserver(self, forKeyPath: "frame")
        view.removeObserver(self, forKeyPath: "center")
        view.removeObserver(self, forKeyPath: "bounds")
        view.removeObserver(self, forKeyPath: "transform")
        keyboardView = nil
    }
    
    // MARK: Fileprivate
    
    static func observer(for view: UIView?) -> _FSKeyboardViewFrameObserver? {
        guard let view = view else {
            return nil
        }
        return objc_getAssociatedObject(view, &AssociatedKey) as? _FSKeyboardViewFrameObserver
    }
    
    func add(to keyboardView: UIView?) {
        guard keyboardView !== self.keyboardView else {
            return
        }
        if let view = self.keyboardView {
            p_removeFrameObserver()
            objc_setAssociatedObject(view, &_FSKeyboardViewFrameObserver.AssociatedKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        if let view = keyboardView {
            self.keyboardView = view
            p_addFrameObserver()
            objc_setAssociatedObject(view, &_FSKeyboardViewFrameObserver.AssociatedKey, self, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
