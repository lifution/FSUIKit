//
//  FSUIApplicationLoader.swift
//  FSUIKit
//
//  Created by Sheng on 2024/1/19.
//  Copyright © 2024 Sheng. All rights reserved.
//

import UIKit

/// - Warning: ⚠️ 外部禁止使用该类，该类仅用于 FSUIKit 内部 hook 操作使用。
public final class FSUIApplicationLoader: NSObject {
    
    private static var isLoaded = false
    
    @objc
    public class func activate() {
        guard !isLoaded else { return }
        isLoaded = true
        do {
            // activate keyboard manager
            let _ = FSKeyboardManager.shared
        }
    }
}
