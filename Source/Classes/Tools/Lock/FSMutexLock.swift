//
//  FSMutexLock.swift
//  FSUIKitSwift
//
//  Created by VincentLee on 2025/5/24.
//  Copyright © 2025 VincentLee. All rights reserved.
//

import Foundation

///
/// 基于 ``pthread_mutex_t`` 封装的线程锁
/// 支持递归(需在初始化时设定，否则默认为互斥锁)
///
public final class FSMutexLock {
    
    private var mutex = pthread_mutex_t()
    
    public init(recursive: Bool = false) {
        var attr = pthread_mutexattr_t()
        pthread_mutexattr_init(&attr)
        
        let type = recursive ? PTHREAD_MUTEX_RECURSIVE : PTHREAD_MUTEX_DEFAULT
        pthread_mutexattr_settype(&attr, type)
        
        pthread_mutex_init(&mutex, &attr)
        pthread_mutexattr_destroy(&attr)
    }
    
    deinit {
        pthread_mutex_destroy(&mutex)
    }
    
    @inline(__always)
    public func lock() {
        pthread_mutex_lock(&mutex)
    }
    
    @inline(__always)
    public func unlock() {
        pthread_mutex_unlock(&mutex)
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
/// 基于 ``FSMutexLock`` 封装的属性包装器
///
@propertyWrapper
public final class FSMutexSynchronized<Value> {
    
    private var value: Value
    private let lock: FSMutexLock
    
    public init(wrappedValue: Value, recursive: Bool = false) {
        self.value = wrappedValue
        self.lock = FSMutexLock(recursive: recursive)
    }
    
    public var wrappedValue: Value {
        get { lock.withLock { value } }
        set { lock.withLock { value = newValue } }
    }
    
    public func withLock<T>(_ block: (inout Value) throws -> T) rethrows -> T {
        try lock.withLock { try block(&value) }
    }
}
