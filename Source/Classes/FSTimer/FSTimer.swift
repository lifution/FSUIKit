//
//  FSTimer.swift
//  FSUIKitSwift
//
//  Created by Sheng on 2024/2/6.
//  Copyright © 2024 Sheng. All rights reserved.
//

import Foundation

/// 基于 DispatchSourceTimer 封装的定时器。
/// 可自定义定时器的回调 queue。
/// 该定时器支持后台模式自动挂起，进入前台后又会自动恢复。
///
/// - Note:
/// 1. 该定时器不支持在后台持续运行。
/// 2. 该定时器没有 `invalidate()` 方法，如果需要停止定时器，直接调用 `suspend()` 即可。
/// 3. 需注意 `eventHandler` 不要造成循环引用。
/// 4. 如果第 3 点没出错的话，那么该定时器是不会造成循环引用的，定时器销毁时会自动清除内部的定时器。
///
public final class FSTimer {
    
    // MARK: State
    private enum State {
        case resumed
        case suspended
    }
    
    // MARK: Properties/Public
    ///
    /// 定时器回调 closure。
    ///
    public var eventHandler: (() -> Void)?
    ///
    /// 定时器间隔。
    ///
    public let timeInterval: TimeInterval
    ///
    /// 定时器回调所在线程，默认为 `DispathQueue.main`。
    ///
    public let queue: DispatchQueue
    ///
    /// 当 app 进入后台时是否自动暂停
    /// 如果 app 进入后台时，timer 处于 ``.suspended`` 状态，则在
    /// app 重新进入前台时，timer 是不会自动重启的。
    /// 默认为 true
    ///
    @objc var autoSuspendInBackground = true
    
    // MARK: Properties/Private
    
    private let timer: DispatchSourceTimer
    private var state: State = .suspended
    ///
    /// 是否正处于自动后台暂停中
    /// 用于 app 进入前台时判断是否需要自动调用 ``resume()``
    ///
    private var isSuspendingForBackground = false
    
    // MARK: Deinitialization
    
    deinit {
        timer.setEventHandler {}
        timer.cancel()
        /// 如果 timer 处于挂起状态时，只是调用 `cancel()` 而没有调用 `resume()` 方法的话，会引起一个 crash 问题。
        /// 详见 https://forums.developer.apple.com/thread/15902
        resume()
        eventHandler = nil
    }
    
    // MARK: Initialization
    
    public init(timeInterval: TimeInterval, queue: DispatchQueue = DispatchQueue.main) {
        self.queue = queue
        self.timeInterval = timeInterval
        timer = DispatchSource.makeTimerSource(queue: queue)
        timer.setEventHandler(handler: { [weak self] in
            self?.eventHandler?()
        })
        NotificationCenter.default.fs
            .addObserver(self,
                         selector: #selector(didReceive(notification:)),
                         name: UIApplication.willResignActiveNotification)
            .addObserver(self,
                         selector: #selector(didReceive(notification:)),
                         name: UIApplication.didBecomeActiveNotification)
    }
    
    // MARK: Private
    
    @objc
    private func didReceive(notification: Notification) {
        if notification.name == UIApplication.willResignActiveNotification {
            guard state == .resumed else { return }
            isSuspendingForBackground = true
            suspend()
        }
        if notification.name == UIApplication.didBecomeActiveNotification {
            guard isSuspendingForBackground else { return }
            isSuspendingForBackground = false
            resume()
        }
    }
    
    // MARK: Public
    
    /// 开始/恢复 定时器。
    public func resume() {
        guard state != .resumed else {
            return
        }
        state = .resumed
        /// fix: 当 timer 从 suspend 恢复到 resume 时，有时候会连续回调两次 event handler。
        timer.schedule(deadline: .now() + timeInterval, repeating: timeInterval)
        timer.resume()
    }
    
    /// 暂停定时器。
    public func suspend() {
        guard state != .suspended else {
            return
        }
        state = .suspended
        timer.suspend()
    }
}
