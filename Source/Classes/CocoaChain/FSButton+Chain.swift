//
//  FSButton+Chain.swift
//  FSUIKitSwift
//
//  Created by VincentLee on 2024/12/11.
//

import Foundation

public extension FSUIKitWrapper where Base: FSButton {
    
    @discardableResult
    func adjustsTitleTintColorAutomatically(_ adjustsTitleTintColorAutomatically: Bool) -> FSUIKitWrapper {
        base.adjustsTitleTintColorAutomatically = adjustsTitleTintColorAutomatically
        return self
    }
    
    @discardableResult
    func adjustsImageTintColorAutomatically(_ adjustsImageTintColorAutomatically: Bool) -> FSUIKitWrapper {
        base.adjustsImageTintColorAutomatically = adjustsImageTintColorAutomatically
        return self
    }
    
    @discardableResult
    func tintColorAdjustsTitleAndImage(_ tintColorAdjustsTitleAndImage: UIColor?) -> FSUIKitWrapper {
        base.tintColorAdjustsTitleAndImage = tintColorAdjustsTitleAndImage
        return self
    }
    
    @discardableResult
    func adjustsButtonWhenHighlighted(_ adjustsButtonWhenHighlighted: Bool) -> FSUIKitWrapper {
        base.adjustsButtonWhenHighlighted = adjustsButtonWhenHighlighted
        return self
    }
    
    @discardableResult
    func adjustsButtonWhenDisabled(_ adjustsButtonWhenDisabled: Bool) -> FSUIKitWrapper {
        base.adjustsButtonWhenDisabled = adjustsButtonWhenDisabled
        return self
    }
    
    @discardableResult
    func highlightedBackgroundColor(_ highlightedBackgroundColor: UIColor?) -> FSUIKitWrapper {
        base.highlightedBackgroundColor = highlightedBackgroundColor
        return self
    }
    
    @discardableResult
    func highlightedBorderColor(_ highlightedBorderColor: UIColor?) -> FSUIKitWrapper {
        base.highlightedBorderColor = highlightedBorderColor
        return self
    }
    
    @discardableResult
    func imagePosition(_ imagePosition: FSButton.ImagePosition) -> FSUIKitWrapper {
        base.imagePosition = imagePosition
        return self
    }
    
    @discardableResult
    func spacingBetweenImageAndTitle(_ spacingBetweenImageAndTitle: CGFloat) -> FSUIKitWrapper {
        base.spacingBetweenImageAndTitle = spacingBetweenImageAndTitle
        return self
    }
    
    @discardableResult
    func hitTestEdgeInsets(_ hitTestEdgeInsets: UIEdgeInsets) -> FSUIKitWrapper {
        base.hitTestEdgeInsets = hitTestEdgeInsets
        return self
    }
    
    @discardableResult
    func clickInterval(_ clickInterval: TimeInterval) -> FSUIKitWrapper {
        base.clickInterval = clickInterval
        return self
    }
}
