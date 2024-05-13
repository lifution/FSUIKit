//
//  FSUIApplicationLoader.swift
//  FSUIKitSwift
//
//  Created by Sheng on 2024/1/19.
//  Copyright © 2024 Sheng. All rights reserved.
//

import UIKit
import Foundation

/// - Warning: 🛑 This object is only used internally in FSUIKitSwift.
public final class FSUIApplicationLoader: NSObject {
    
    private static var isLoaded = false
    
    @objc
    public class func activate() {
        guard !isLoaded else { return }
        isLoaded = true
        do {
            // activate keyboard manager
            let _ = FSKeyboardManager.shared
            // method swizzling
            UIViewController.fullscreenPop_swizzling()
            UINavigationController.nc_fullscreenPop_swizzling()
        }
    }
}
