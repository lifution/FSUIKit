//
//  UIImageView+Chain.swift
//  FSUIKitSwift
//
//  Created by VincentLee on 2024/11/6.
//

import UIKit

public extension FSUIKitWrapper where Base: UIImageView {
    
    @discardableResult
    func image(_ image: UIImage?) -> FSUIKitWrapper {
        base.image = image
        return self
    }
    
    @discardableResult
    func isHighlighted(_ isHighlighted: Bool) -> FSUIKitWrapper {
        base.isHighlighted = isHighlighted
        return self
    }
}
