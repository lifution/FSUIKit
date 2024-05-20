//
//  CGSize+FSUIKitSwift.swift
//  FSUIKitSwift
//
//  Created by Sheng on 2024/3/25.
//  Copyright © 2024 Sheng. All rights reserved.
//

import UIKit

public extension FSUIKitWrapper where Base == CGSize {
    
    /// Returns a size that is smaller or larger than the source size.
    func insetBy(horizontal: CGFloat, vertical: CGFloat) -> CGSize {
        let width = base.width - horizontal
        let height = base.height - vertical
        return .init(width: max(0, width), height: max(0, height))
    }
}
