//
//  UIApplication+FSUIKitSwift.swift
//  FSUIKitSwift
//
//  Created by Sheng on 2024/1/19.
//  Copyright © 2024 Sheng. All rights reserved.
//

import UIKit

public extension FSUIKitWrapper where Base: UIApplication {
    
    /// Returns true in App Extension.
    static var isAppExtension: Bool {
        return _UIApplicationConsts.isAppExtension
    }
    
    var keyWindow: UIWindow? {
        var window: UIWindow?
        if #available(iOS 15.0, *) {
            window = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .filter { $0.activationState == .foregroundActive }
                .first?.keyWindow
        } else if #available(iOS 13, *) {
            window = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .filter { $0.activationState == .foregroundActive }
                .first?.windows
                .first(where: \.isKeyWindow)
        }
        return window
    }
    
    var keyWindowScene: UIWindowScene? {
        return keyWindow?.windowScene
    }
}

private struct _UIApplicationConsts {
    
    static let isAppExtension: Bool = {
        var isAppExtension = false
        if let cls = NSClassFromString("UIApplication") {
            if !cls.responds(to: #selector(getter: UIApplication.shared)) {
                isAppExtension = true
            }
        } else {
            isAppExtension = true
        }
        if Bundle.main.bundlePath.hasSuffix(".appex") {
            isAppExtension = true
        }
        return isAppExtension
    }()
}
