//
//  UIView+Chain.swift
//  FSUIKitSwift
//
//  Created by VincentLee on 2024/11/6.
//

import UIKit

public extension FSUIKitWrapper where Base: UIView {
    
    @discardableResult
    func tag(_ tag: Int) -> FSUIKitWrapper {
        base.tag = tag
        return self
    }
    
    @discardableResult
    func frame(_ frame: CGRect) -> FSUIKitWrapper {
        base.frame = frame
        return self
    }
    
    @discardableResult
    func frame(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) -> FSUIKitWrapper {
        base.frame = CGRect(x: x, y: y, width: width, height: height)
        return self
    }
    
    @discardableResult
    func bounds(_ bounds: CGRect) -> FSUIKitWrapper {
        base.bounds = bounds
        return self
    }
    
    @discardableResult
    func center(_ center: CGPoint) -> FSUIKitWrapper {
        base.center = center
        return self
    }
    
    @discardableResult
    func center(x: CGFloat, y: CGFloat) -> FSUIKitWrapper {
        base.center = CGPoint(x: x, y: y)
        return self
    }
    
    @discardableResult
    func backgroundColor(_ backgroundColor: UIColor) -> FSUIKitWrapper {
        base.backgroundColor = backgroundColor
        return self
    }
    
    @discardableResult
    func contentMode(_ contentMode: UIView.ContentMode) -> FSUIKitWrapper {
        base.contentMode = contentMode
        return self
    }
    
    @discardableResult
    func clipsToBounds(_ clipsToBounds: Bool) -> FSUIKitWrapper {
        base.clipsToBounds = clipsToBounds
        return self
    }
    
    @discardableResult
    func alpha(_ alpha: CGFloat) -> FSUIKitWrapper {
        base.alpha = alpha
        return self
    }
    
    @discardableResult
    func isHidden(_ isHidden: Bool) -> FSUIKitWrapper {
        base.isHidden = isHidden
        return self
    }
    
    @discardableResult
    func isOpaque(_ isOpaque: Bool) -> FSUIKitWrapper {
        base.isOpaque = isOpaque
        return self
    }
    
    @discardableResult
    func isUserInteractionEnabled(_ isUserInteractionEnabled: Bool) -> FSUIKitWrapper {
        base.isUserInteractionEnabled = isUserInteractionEnabled
        return self
    }
    
    @discardableResult
    func tintColor(_ tintColor: UIColor) -> FSUIKitWrapper {
        base.tintColor = tintColor
        return self
    }
    
    @discardableResult
    func cornerRadius(_ cornerRadius: CGFloat) -> FSUIKitWrapper {
        base.layer.cornerRadius = cornerRadius
        return self
    }
    
    @discardableResult
    func masksToBounds(_ masksToBounds: Bool) -> FSUIKitWrapper {
        base.layer.masksToBounds = masksToBounds
        return self
    }
    
    @discardableResult
    func borderWidth(_ borderWidth: CGFloat) -> FSUIKitWrapper {
        base.layer.borderWidth = borderWidth
        return self
    }
    
    @discardableResult
    func borderColor(_ borderColor: UIColor) -> FSUIKitWrapper {
        base.layer.borderColor = borderColor.cgColor
        return self
    }
    
    @discardableResult
    func shadowColor(_ shadowColor: UIColor?) -> FSUIKitWrapper {
        base.layer.shadowColor = shadowColor?.cgColor
        return self
    }
    
    @discardableResult
    func shadowOpacity(_ shadowOpacity: Float) -> FSUIKitWrapper {
        base.layer.shadowOpacity = shadowOpacity
        return self
    }
    
    @discardableResult
    func shadowOffset(_ shadowOffset: CGSize) -> FSUIKitWrapper {
        base.layer.shadowOffset = shadowOffset
        return self
    }
    
    @discardableResult
    func shadowRadius(_ shadowRadius: CGFloat) -> FSUIKitWrapper {
        base.layer.shadowRadius = shadowRadius
        return self
    }
    
    @discardableResult
    func shadowPath(_ shadowPath: CGPath?) -> FSUIKitWrapper {
        base.layer.shadowPath = shadowPath
        return self
    }
    
    @discardableResult
    func addSubview(_ view: UIView) -> FSUIKitWrapper {
        base.addSubview(view)
        return self
    }
    
    @discardableResult
    func addGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) -> FSUIKitWrapper {
        base.addGestureRecognizer(gestureRecognizer)
        return self
    }
    
    @discardableResult
    func addConstraint(_ constraint: NSLayoutConstraint) -> FSUIKitWrapper {
        base.addConstraint(constraint)
        return self
    }
    
    @discardableResult
    func addConstraints(_ constraints: [NSLayoutConstraint]) -> FSUIKitWrapper {
        base.addConstraints(constraints)
        return self
    }
}
