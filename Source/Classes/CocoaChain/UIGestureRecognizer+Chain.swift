//
//  UIGestureRecognizer+Chain.swift
//  FSUIKitSwift
//
//  Created by VincentLee on 2024/11/6.
//

import UIKit

public extension FSUIKitWrapper where Base: UIGestureRecognizer {
    
    @discardableResult
    func addTarget(_ target: Any, action: Selector) -> FSUIKitWrapper {
        base.addTarget(target, action: action)
        return self
    }
    
    @discardableResult
    func delegate(_ delegate: UIGestureRecognizerDelegate?) -> FSUIKitWrapper {
        base.delegate = delegate
        return self
    }
    
    @discardableResult
    func isEnabled(_ isEnabled: Bool) -> FSUIKitWrapper {
        base.isEnabled = isEnabled
        return self
    }
}

public extension FSUIKitWrapper where Base: UITapGestureRecognizer {
    
    @discardableResult
    func numberOfTapsRequired(_ numberOfTapsRequired: Int) -> FSUIKitWrapper {
        base.numberOfTapsRequired = numberOfTapsRequired
        return self
    }
    
    @discardableResult
    func numberOfTouchesRequired(_ numberOfTouchesRequired: Int) -> FSUIKitWrapper {
        base.numberOfTouchesRequired = numberOfTouchesRequired
        return self
    }
}

public extension FSUIKitWrapper where Base: UIPanGestureRecognizer {
    
    @discardableResult
    func minimumNumberOfTouches(_ minimumNumberOfTouches: Int) -> FSUIKitWrapper {
        base.minimumNumberOfTouches = minimumNumberOfTouches
        return self
    }
    
    @discardableResult
    func maximumNumberOfTouches(_ maximumNumberOfTouches: Int) -> FSUIKitWrapper {
        base.maximumNumberOfTouches = maximumNumberOfTouches
        return self
    }
}

public extension FSUIKitWrapper where Base: UISwipeGestureRecognizer {
    
    @discardableResult
    func numberOfTouchesRequired(_ numberOfTouchesRequired: Int) -> FSUIKitWrapper {
        base.numberOfTouchesRequired = numberOfTouchesRequired
        return self
    }
    
    @discardableResult
    func direction(_ direction: UISwipeGestureRecognizer.Direction) -> FSUIKitWrapper {
        base.direction = direction
        return self
    }
}

public extension FSUIKitWrapper where Base: UIPinchGestureRecognizer {
    
    @discardableResult
    func scale(_ scale: CGFloat) -> FSUIKitWrapper {
        base.scale = scale
        return self
    }
}

public extension FSUIKitWrapper where Base: UILongPressGestureRecognizer {
    
    @discardableResult
    func numberOfTapsRequired(_ numberOfTapsRequired: Int) -> FSUIKitWrapper {
        base.numberOfTapsRequired = numberOfTapsRequired
        return self
    }
    
    @discardableResult
    func numberOfTouchesRequired(_ numberOfTouchesRequired: Int) -> FSUIKitWrapper {
        base.numberOfTouchesRequired = numberOfTouchesRequired
        return self
    }
    
    @discardableResult
    func minimumPressDuration(_ minimumPressDuration: CFTimeInterval) -> FSUIKitWrapper {
        base.minimumPressDuration = minimumPressDuration
        return self
    }
    
    @discardableResult
    func allowableMovement(_ allowableMovement: CGFloat) -> FSUIKitWrapper {
        base.allowableMovement = allowableMovement
        return self
    }
}

public extension FSUIKitWrapper where Base: UIRotationGestureRecognizer {
    
    @discardableResult
    func rotation(_ rotation: CGFloat) -> FSUIKitWrapper {
        base.rotation = rotation
        return self
    }
}
