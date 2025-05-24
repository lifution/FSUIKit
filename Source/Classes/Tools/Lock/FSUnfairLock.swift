//
//  FSUnfairLock.swift
//  FSUIKitSwift
//
//  Created by VincentLee on 2025/5/24.
//  Copyright © 2025 VincentLee. All rights reserved.
//

import Foundation
import os.lock

///
/// 基于 ``os_unfair_lock_s`` 封装的互斥锁
///
/// - Important:
///   - 不支持递归加锁，如果需要递归加锁，请使用 ``FSMutexLock``。
///
public final class FSUnfairLock {
    
    private var unfairLock = os_unfair_lock_s()
    
    public init() {}
    
    @inline(__always)
    public func lock() {
        os_unfair_lock_lock(&unfairLock)
    }
    
    @inline(__always)
    public func unlock() {
        os_unfair_lock_unlock(&unfairLock)
    }
    
    @discardableResult
    @inline(__always)
    public func withLock<T>(_ block: () throws -> T) rethrows -> T {
        lock()
        defer { unlock() }
        return try block()
    }
}


///
/// 基于 ``FSUnfairLock`` 封装的属性包装器
///
/// - Important:
///   - 不支持递归加锁
///
@propertyWrapper
public final class FSUnfairSynchronized<Value> {
    
    private var value: Value
    private let lock = FSUnfairLock()
    
    public init(wrappedValue: Value) {
        self.value = wrappedValue
    }
    
    public var wrappedValue: Value {
        get { lock.withLock { value } }
        set { lock.withLock { value = newValue } }
    }
    
    public func withLock<T>(_ block: (inout Value) throws -> T) rethrows -> T {
        try lock.withLock { try block(&value) }
    }
}
