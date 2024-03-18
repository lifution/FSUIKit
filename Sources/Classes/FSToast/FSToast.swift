//
//  FSToast.swift
//  FSUIKit
//
//  Created by Sheng on 2024/2/6.
//  Copyright © 2024 Sheng. All rights reserved.
//

import UIKit

public struct FSToast {
    
    // MARK: Properties/Private
    
    private static var window: UIWindow? {
        if #available(iOS 13.0, *), let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            return scene.windows.first
        }
        if let delegate = UIApplication.shared.delegate {
            return delegate.window ?? nil
        }
        return nil
    }
    
    private static weak var showingWindow: UIWindow?
    
    // MARK: Private
    
    /// 每次显示之前都调用该方法移除旧的 toast，
    /// 目的是为了防止上一个显示的 toast 和新的 window 不是同一个 window。
    private static func p_removePrevious() {
        showingWindow?.fs.dismissToast()
    }
    
    // MARK: Public
    
    /// 注释参考 `UIView+FSToast` 中的同名方法。
    public static func show(hint: String?, isUserInteractionEnabled: Bool = true) {
        p_removePrevious()
        showingWindow = window
        showingWindow?.fs.show(hint: hint, isUserInteractionEnabled: isUserInteractionEnabled)
    }
    
    /// 注释参考 `UIView+FSToast` 中的同名方法。
    public static func showLoading(_ text: String? = nil, isUserInteractionEnabled: Bool = false) {
        p_removePrevious()
        showingWindow = window
        showingWindow?.fs.showLoading(text, isUserInteractionEnabled: isUserInteractionEnabled)
    }
    
    /// 注释参考 `UIView+FSToast` 中的同名方法。
    public static func showSuccess(_ text: String?, isUserInteractionEnabled: Bool = true) {
        p_removePrevious()
        showingWindow = window
        showingWindow?.fs.showSuccess(text, isUserInteractionEnabled: isUserInteractionEnabled)
    }
    
    /// 注释参考 `UIView+FSToast` 中的同名方法。
    public static func showError(_ text: String?, isUserInteractionEnabled: Bool = true) {
        p_removePrevious()
        showingWindow = window
        showingWindow?.fs.showError(text, isUserInteractionEnabled: isUserInteractionEnabled)
    }
    
    /// 注释参考 `UIView+FSToast` 中的同名方法。
    public static func showWarning(_ text: String?, isUserInteractionEnabled: Bool = true) {
        p_removePrevious()
        showingWindow = window
        showingWindow?.fs.showWarning(text, isUserInteractionEnabled: isUserInteractionEnabled)
    }
    
    /// 注释参考 `UIView+FSToast` 中的同名方法。
    public static func show(content: FSToastContentConvertable?, isUserInteractionEnabled: Bool = true) {
        p_removePrevious()
        showingWindow = window
        showingWindow?.fs.show(content: content, isUserInteractionEnabled: isUserInteractionEnabled)
    }
    
    /// 注释参考 `UIView+FSToast` 中的同名方法。
    public static func dismissToast() {
        showingWindow?.fs.dismissToast()
    }
}
