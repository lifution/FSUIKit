//
//  UIControl+FSUIKit.swift
//  FSUIKit
//
//  Created by Sheng on 2024/2/7.
//  Copyright © 2024 Sheng. All rights reserved.
//

import UIKit

public extension FSUIKitWrapper where Base: UIControl {
    
    /// 添加 events 事件的响应回调 closure。
    ///
    /// - Note:
    ///     该方法是**添加**，使用者可以对同一个 events 无限次调用该方法，每次的 closure 都互不影响。
    ///
    /// - Important:
    ///     该 closure 会被强引用，因此外部需注意循环引用问题，
    ///     在 closure 内部调用 self 或当前的 UIControl 本身都切记需要使用 weak 转换。
    ///
    mutating func addHandler(for events: UIControl.Event, handler: ((_ sender: Any) -> Void)?) {
        guard !events.isEmpty else {
            return
        }
        let target = UIControlHandlerTarget(handler: handler, events: events)
        base.addTarget(target, action: #selector(target.invoke(_:)), for: events)
        do {
            var targets = handlerTargets
            targets.append(target)
            handlerTargets = targets
        }
    }
    
    /// 设置 events 事件的响应回调 closure。
    ///
    /// - Note:
    ///     该方法是**设置**，相同的 events，只有最后一次的设置才会生效，其它的都会被移除。
    ///
    /// - Important:
    ///     该 closure 会被强引用，因此外部需注意循环引用问题，
    ///     在 closure 内部调用 self 或当前的 UIControl 本身都切记需要使用 weak 转换。
    ///
    mutating func setHandler(for events: UIControl.Event, handler: ((_ sender: Any) -> Void)?) {
        guard !events.isEmpty else {
            return
        }
        removeAllHandlers(for: events)
        addHandler(for: events, handler: handler)
    }
    
    /// 移除相应 events 的 closure 回调。
    mutating func removeAllHandlers(for events: UIControl.Event) {
        guard !events.isEmpty else {
            return
        }
        let targets = handlerTargets
        if !targets.isEmpty {
            var removes = [UIControlHandlerTarget]()
            for target in targets {
                if target.events.contains(events) {
                    base.removeTarget(target, action: #selector(target.invoke(_:)), for: target.events)
                    var newEvents = target.events
                    newEvents.remove(events)
                    if newEvents.isEmpty {
                        removes.append(target)
                    } else {
                        target.events = newEvents
                        base.addTarget(target, action: #selector(target.invoke(_:)), for: newEvents)
                    }
                } else if events.contains(target.events) { // allxxxEvents
                    base.removeTarget(target, action: #selector(target.invoke(_:)), for: target.events)
                    removes.append(target)
                }
            }
            let leftTargets = targets.filter { !removes.contains($0) }
            handlerTargets = leftTargets
        }
    }
}

private extension FSUIKitWrapper where Base: UIControl {
    
    var handlerTargets: [UIControlHandlerTarget] {
        get {
            if let targets = objc_getAssociatedObject(base, &_AssociatedKey.handlersKey) as? [UIControlHandlerTarget] {
                return targets
            }
            return []
        }
        set {
            objc_setAssociatedObject(base, &_AssociatedKey.handlersKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
}

private struct _AssociatedKey {
    static var handlersKey = 0
}

private class UIControlHandlerTarget: Equatable {
    
    var handler: ((_ sender: Any) -> Void)?
    var events: UIControl.Event
    
    init(handler: ((_ sender: Any) -> Void)?, events: UIControl.Event) {
        self.handler = handler
        self.events = events
    }
    
    @objc func invoke(_ sender: Any) {
        handler?(sender)
    }
    
    static func == (lhs: UIControlHandlerTarget, rhs: UIControlHandlerTarget) -> Bool {
        return lhs === rhs
    }
}
