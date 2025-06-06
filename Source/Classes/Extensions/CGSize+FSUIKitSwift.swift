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
    ///
    func insetBy(horizontal: CGFloat, vertical: CGFloat) -> CGSize {
        let width = base.width - horizontal
        let height = base.height - vertical
        return .init(width: max(0, width), height: max(0, height))
    }
    
    func ceiled() -> CGSize {
        return .init(width: ceil(base.width), height: ceil(base.height))
    }
    
    func flatted() -> CGSize {
        return .init(width: FSFlat(base.width), height: FSFlat(base.height))
    }
    
    func floorFlatted() -> CGSize {
        return .init(width: FSFloorFlat(base.width), height: FSFloorFlat(base.height))
    }
    
    func removedNaN() -> CGSize {
        return .init(width: RemoveNaN(base.width), height: RemoveNaN(base.height))
    }
}
