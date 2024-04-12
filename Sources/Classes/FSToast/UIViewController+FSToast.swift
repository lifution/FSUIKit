//
//  UIViewController+FSToast.swift
//  FSUIKitSwift
//
//  Created by Sheng on 2024/2/6.
//  Copyright © 2024 Sheng. All rights reserved.
//

import UIKit

extension FSUIKitWrapper where Base: UIViewController {
    
    /// 注释参考 `UIView+FSToast` 中的同名方法。
    public func show(hint: String?, isUserInteractionEnabled: Bool = true) {
        base.view.fs.show(hint: hint, isUserInteractionEnabled: isUserInteractionEnabled)
    }
    
    /// 注释参考 `UIView+FSToast` 中的同名方法。
    public func showLoading(_ text: String? = nil, isUserInteractionEnabled: Bool = false) {
        base.view.fs.showLoading(text, isUserInteractionEnabled: isUserInteractionEnabled)
    }
    
    /// 注释参考 `UIView+FSToast` 中的同名方法。
    public func showSuccess(_ text: String?, isUserInteractionEnabled: Bool = true) {
        base.view.fs.showSuccess(text, isUserInteractionEnabled: isUserInteractionEnabled)
    }
    
    /// 注释参考 `UIView+FSToast` 中的同名方法。
    public func showError(_ text: String?, isUserInteractionEnabled: Bool = true) {
        base.view.fs.showError(text, isUserInteractionEnabled: isUserInteractionEnabled)
    }
    
    /// 注释参考 `UIView+FSToast` 中的同名方法。
    public func showWarning(_ text: String?, isUserInteractionEnabled: Bool = true) {
        base.view.fs.showWarning(text, isUserInteractionEnabled: isUserInteractionEnabled)
    }
    
    /// 注释参考 `UIView+FSToast` 中的同名方法。
    public func show(content: FSToastContentConvertable?, isUserInteractionEnabled: Bool = true) {
        base.view.fs.show(content: content, isUserInteractionEnabled: isUserInteractionEnabled)
    }
    
    /// 注释参考 `UIView+FSToast` 中的同名方法。
    public func dismissToast() {
        base.view.fs.dismissToast()
    }
}
