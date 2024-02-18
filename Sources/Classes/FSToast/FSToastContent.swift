//
//  FSToastContent.swift
//  FSUIKit
//
//  Created by Sheng on 2024/2/6.
//  Copyright © 2024 Sheng. All rights reserved.
//

import UIKit

/// FSUIKit 提供的默认 FSToast 内容。
open class FSToastContent: FSToastContentConvertable {
    
    public enum Style {
        case custom
        case hint
        case loading
        case warning
        case success
        case error
    }
    
    // MARK: Properties/<FSToastContentConvertable>
    
    open var duration: TimeInterval = 0.0
    
    open var tapticEffect: FSToastTapticEffect = .none
    
    open var cornerRadius: CGFloat = 8.0
    
    open var borderColor: UIColor?
    
    open var borderWidth: CGFloat = 0.0
    
    open var backgroundColor: UIColor? = .black
    
    open var backgroundEffect: FSToastBackgroundEffect?
    
    open var contentInset: UIEdgeInsets = .init(top: 8.0, left: 12.0, bottom: 8.0, right: 12.0)
    
    open var topViewBottomSpacing: CGFloat = 10.0
    
    open var textBottomSpacing: CGFloat = 10.0
    
    open var detailBottomSpacing: CGFloat = 10.0
    
    open var topView: UIView?
    
    open var topViewSize: CGSize?
    
    open var text: String?
    
    open var richText: NSAttributedString?
    
    open var detail: String?
    
    open var richDetail: NSAttributedString?
    
    open var bottomView: UIView?
    
    open var bottomViewSize: CGSize?
    
    open var animation: FSToastAnimatedTransitioning? = FSToastAnimation()
    
    open var onDidDismiss: (() -> Void)?
    
    // MARK: Properties/Private
    
    private let style: FSToastContent.Style
    
    // MARK: Initialization
    
    public init(style: FSToastContent.Style = .custom) {
        self.style = style
        p_update()
    }
    
    // MARK: Private
    
    private func p_update() {
        
        switch style {
        case .hint:
            do {
                duration = 1.5
                animation = FSToastAnimation(kind: .slideUp)
                contentInset = .init(top: 8.0, left: 12.0, bottom: 8.0, right: 12.0)
            }
        case .loading:
            do {
                topView = {
                    let view = UIActivityIndicatorView(style: {
                        if #available(iOS 13, *) {
                            return .large
                        }
                        return .whiteLarge
                    }())
                    view.color = {
                        if #available(iOS 13, *) {
                            return UITraitCollection.current.userInterfaceStyle == .dark ? .black : .white
                        }
                        return .white
                    }()
                    view.startAnimating()
                    return view
                }()
                duration = 0.0
                animation = FSToastAnimation(kind: .scale)
                contentInset = .init(top: 16.0, left: 16.0, bottom: 16.0, right: 16.0)
                topViewBottomSpacing = 10.0
            }
        case .warning, .success, .error:
            do {
                topView = {
                    var name: String = {
                        if style == .warning {
                            return "icon_toast_warning"
                        } else if style == .success {
                            return "icon_toast_success"
                        } else {
                            return "icon_toast_error"
                        }
                    }()
                    name += {
                        if #available(iOS 13, *) {
                            return UITraitCollection.current.userInterfaceStyle == .dark ? "_dark" : "_light"
                        }
                        return "_light"
                    }()
                    return UIImageView(image: .inner.image(named: name))
                }()
                duration = 1.5
                animation = FSToastAnimation(kind: .fade)
                contentInset = .init(top: 12.0, left: 15.0, bottom: 12.0, right: 15.0)
                do {
                    if style == .success {
                        tapticEffect = .notification(.success)
                    } else if style == .warning {
                        tapticEffect = .notification(.warning)
                    } else {
                        tapticEffect = .notification(.error)
                    }
                }
            }
        case .custom:
            break
        }
        
        if style != .custom {
            // background blur effect
            backgroundEffect = {
                var effect = FSToastBackgroundEffect()
                effect.scale = 1.0
                effect.color = {
                    if #available(iOS 13, *) {
                        return UITraitCollection.current.userInterfaceStyle == .dark ? .white : .black
                    }
                    return .black
                }()
                effect.colorAlpha = 0.7
                effect.blurRadius = 3.0
                return effect
            }()
        }
    }
    
    // MARK: <FSToastContentConvertable>
    
    open func userInterfaceStyleDidChange() {
        p_update()
    }
}
