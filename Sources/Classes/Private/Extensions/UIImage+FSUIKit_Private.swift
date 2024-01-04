//
//  UIImage+FSUIKit_Private.swift
//  FSUIKit
//
//  Created by Sheng on 2024/1/4.
//  Copyright © 2024 Sheng. All rights reserved.
//

import UIKit

extension FSUIKitInternalWrapper where Base: UIImage {
    
    /// 读取 `.../FSUIKit.bundle` / `.../FSUIKit.bundle/Assets.car` 下的图片资源。
    static func image(named name: String?) -> UIImage? {
        guard let name = name, !name.isEmpty else {
            return nil
        }
        if let path = Bundle(for: FSUIKitInternalBundle.self).path(forResource: "FSUIKit", ofType: "bundle") {
            if let bundle = Bundle(path: path) {
                return UIImage(named: name, in: bundle, compatibleWith: nil)
            }
        }
        return nil
    }
}

private class FSUIKitInternalBundle {}
