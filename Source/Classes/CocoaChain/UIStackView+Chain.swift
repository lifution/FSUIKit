//
//  UIStackView+Chain.swift
//  FSUIKitSwift
//
//  Created by VincentLee on 2025/4/1.
//

import UIKit

public extension FSUIKitWrapper where Base: UIStackView {
    
    @discardableResult
    func addArrangedSubview(_ view: UIView) -> FSUIKitWrapper {
        base.addArrangedSubview(view)
        return self
    }
    
    @discardableResult
    func removeArrangedSubview(_ view: UIView) -> FSUIKitWrapper {
        base.removeArrangedSubview(view)
        return self
    }
    
    @discardableResult
    func insertArrangedSubview(_ view: UIView, at stackIndex: Int) -> FSUIKitWrapper {
        base.insertArrangedSubview(view, at: stackIndex)
        return self
    }
    
    @discardableResult
    func axis(_ axis: NSLayoutConstraint.Axis) -> FSUIKitWrapper {
        base.axis = axis
        return self
    }
    
    @discardableResult
    func distribution(_ distribution: UIStackView.Distribution) -> FSUIKitWrapper {
        base.distribution = distribution
        return self
    }
    
    @discardableResult
    func alignment(_ alignment: UIStackView.Alignment) -> FSUIKitWrapper {
        base.alignment = alignment
        return self
    }
    
    @discardableResult
    func spacing(_ spacing: CGFloat) -> FSUIKitWrapper {
        base.spacing = spacing
        return self
    }
    
    @discardableResult
    func setCustomSpacing(_ spacing: CGFloat, after arrangedSubview: UIView) -> FSUIKitWrapper {
        base.setCustomSpacing(spacing, after: arrangedSubview)
        return self
    }
    
    @discardableResult
    func customSpacing(after arrangedSubview: UIView) -> FSUIKitWrapper {
        base.customSpacing(after: arrangedSubview)
        return self
    }
    
    @discardableResult
    func isBaselineRelativeArrangement(_ isBaselineRelativeArrangement: Bool) -> FSUIKitWrapper {
        base.isBaselineRelativeArrangement = isBaselineRelativeArrangement
        return self
    }
    
    @discardableResult
    func isLayoutMarginsRelativeArrangement(_ isLayoutMarginsRelativeArrangement: Bool) -> FSUIKitWrapper {
        base.isLayoutMarginsRelativeArrangement = isLayoutMarginsRelativeArrangement
        return self
    }
}
