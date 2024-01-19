//
//  UIApplication+FSUIKit.swift
//  FSUIKit
//
//  Created by Sheng on 2024/1/19.
//  Copyright © 2024 Sheng. All rights reserved.
//

import UIKit

extension FSUIKitWrapper where Base: UIApplication {
    
    /// Returns true in App Extension.
    public static var isAppExtension: Bool {
        return _UIApplicationConsts.isAppExtension
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
