//
//  FSTimer.swift
//  FSUIKit
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
    
    /// 定时器回调 closure。
    public var eventHandler: (() -> Void)?
    
    /// 定时器间隔。
    public let timeInterval: TimeInterval
    
    /// 定时器回调所在线程，默认为 `DispathQueue.main`。
    public let queue: DispatchQueue
    
    // MARK: Properties/Private
    
    private var state: State = .suspended
    
    private lazy var timer: DispatchSourceTimer = {
        let timer = DispatchSource.makeTimerSource(queue: queue)
        timer.schedule(deadline: .now() + timeInterval, repeating: timeInterval)
        timer.setEventHandler(handler: { [weak self] in
            self?.eventHandler?()
        })
        return timer
    }()
    
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
    }
    
    // MARK: Public
    
    /// 开始/恢复 定时器。
    public func resume() {
        guard state != .resumed else {
            return
        }
        state = .resumed
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
