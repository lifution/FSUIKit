//
//  UIStackView+FSUIKit.swift
//  FSUIKit
//
//  Created by Sheng on 2024/1/31.
//

import UIKit

public extension FSUIKitWrapper where Base: UIStackView {
    
    /// Remove all arranged subviews from UIStackView at once.
    @discardableResult
    func removeAllArrangedSubviews() -> [UIView] {
        return base.arrangedSubviews.reduce([UIView]()) { $0 + [removeArrangedSubViewProperly($1)] }
    }
    
    @discardableResult
    func removeArrangedSubViewProperly(_ view: UIView) -> UIView {
        base.removeArrangedSubview(view)
        NSLayoutConstraint.deactivate(view.constraints)
        view.removeFromSuperview()
        return view
    }
}
