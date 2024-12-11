//
//  NotificationCenter+Chain.swift
//  FSUIKitSwift
//
//  Created by VincentLee on 2024/12/11.
//

import Foundation

public extension FSUIKitWrapper where Base: NotificationCenter {
    
    @discardableResult
    func addObserver(_ observer: Any,
                     selector aSelector: Selector,
                     name aName: NSNotification.Name?,
                     object anObject: Any? = nil) -> FSUIKitWrapper {
        base.addObserver(observer, selector: aSelector, name: aName, object: anObject)
        return self
    }
    
    @discardableResult
    func post(_ notification: Notification) -> FSUIKitWrapper {
        base.post(notification)
        return self
    }
    
    @discardableResult
    func post(name aName: NSNotification.Name,
              object anObject: Any? = nil,
              userInfo aUserInfo: [AnyHashable : Any]? = nil) -> FSUIKitWrapper {
        base.post(name: aName, object: anObject, userInfo: aUserInfo)
        return self
    }
    
    @discardableResult
    func removeObserver(_ observer: Any,
                        name aName: NSNotification.Name?,
                        object anObject: Any?) -> FSUIKitWrapper {
        base.removeObserver(observer, name: aName, object: anObject)
        return self
    }
}
