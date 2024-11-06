//
//  UILabel+Chain.swift
//  FSUIKitSwift
//
//  Created by VincentLee on 2024/11/6.
//

import UIKit

public extension FSUIKitWrapper where Base: UILabel {
    
    @discardableResult
    func shadowColor(_ shadowColor: UIColor?) -> FSUIKitWrapper {
        base.shadowColor = shadowColor
        return self
    }
    
    @discardableResult
    func shadowOffset(_ shadowOffset: CGSize) -> FSUIKitWrapper {
        base.shadowOffset = shadowOffset
        return self
    }
    
    @discardableResult
    func shadowOffset(width: CGFloat, height: CGFloat) -> FSUIKitWrapper {
        base.shadowOffset = CGSize(width: width, height: height)
        return self
    }
    
    @discardableResult
    func numberOfLines(_ numberOfLines: Int) -> FSUIKitWrapper {
        base.numberOfLines = numberOfLines
        return self
    }
    
    @discardableResult
    func adjustsFontSizeToFitWidth(_ adjustsFontSizeToFitWidth: Bool) -> FSUIKitWrapper {
        base.adjustsFontSizeToFitWidth = adjustsFontSizeToFitWidth
        return self
    }
}
