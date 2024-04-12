//
//  FSUIApplicationLoader.swift
//  FSUIKitSwift
//
//  Created by Sheng on 2024/1/19.
//  Copyright © 2024 Sheng. All rights reserved.
//

import UIKit

/// - Warning: 🛑 This object is only used internally in FSUIKit.
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
