//
//  FSReachability.swift
//  FSUIKitSwift
//
//  Created by VincentLee on 2024/12/2.
//
//  Source from: [Reachability.swift](https://github.com/ashleymills/Reachability.swift)
//

import Foundation
import CoreTelephony
import SystemConfiguration

public extension Notification.Name {
    static let fs_reachabilityDidChange = Notification.Name("com.fsuikitswift.reachability.didchange")
}

public enum FSReachabilityError: Error {
    case failedToCreateWithAddress(sockaddr, Int32)
    case failedToCreateWithHostname(String, Int32)
    case unableToSetCallback(Int32)
    case unableToSetDispatchQueue(Int32)
    case unableToGetFlags(Int32)
}

/// 网络连接监听工具。
///
/// - Note:
///   默认是在 `主线程` 中回调 closure 和 post 通知，外部可在初始化时指定一个回调的线程。
///
public class FSReachability {
    
    public enum Connection: CustomStringConvertible {
        
        case wifi
        case cellular
        case unavailable
        
        public var description: String {
            switch self {
            case .wifi:
                return "WiFi"
            case .cellular:
                do {
                    if let carrierType = CTTelephonyNetworkInfo().serviceCurrentRadioAccessTechnology?.values.first {
                        let types_2g = [
                            CTRadioAccessTechnologyGPRS,
                            CTRadioAccessTechnologyEdge,
                            CTRadioAccessTechnologyCDMA1x
                        ]
                        let types_3g = [
                            CTRadioAccessTechnologyWCDMA,
                            CTRadioAccessTechnologyHSDPA,
                            CTRadioAccessTechnologyHSUPA,
                            CTRadioAccessTechnologyCDMAEVDORev0,
                            CTRadioAccessTechnologyCDMAEVDORevA,
                            CTRadioAccessTechnologyCDMAEVDORevB,
                            CTRadioAccessTechnologyeHRPD
                        ]
                        let types_4g = [
                            CTRadioAccessTechnologyLTE
                        ]
                        if #available(iOS 14.1, *) {
                            let types_5g = [
                                CTRadioAccessTechnologyNRNSA,
                                CTRadioAccessTechnologyNR
                            ]
                            if types_5g.contains(carrierType) {
                                return "5G"
                            }
                        }
                        if types_2g.contains(carrierType) {
                            return "EDGE"
                        }
                        if types_3g.contains(carrierType) {
                            return "3G"
                        }
                        if types_4g.contains(carrierType) {
                            return "4G"
                        }
                    }
                    return "Cellular"
                }
            case .unavailable:
                return "No Connection"
            }
        }
    }
    
    /// 网络连接状态更新后的回调 closure。
    public var onReachabilityDidChange: ((FSReachability) -> Void)?
    
    /// 当该属性为 false 时，当没有蜂窝数据时会强制设置 `FSReachability.connection` 为 `unavailable`。
    /// 默认为 true。
    public var allowsCellularConnection: Bool = true
    
    /// "reachability did change" 通知的发起者。
    public let notificationCenter: NotificationCenter = NotificationCenter.default
    
    /// 连接类型。
    public var connection: Connection {
        if flags == nil {
            try? p_setReachabilityFlags()
        }
        
        switch flags?.connection {
        case .wifi?:
            return .wifi
        case .cellular?:
            return allowsCellularConnection ? .cellular : .unavailable
        case .unavailable?, nil:
            return .unavailable
        }
    }
    
    public private(set) var isNotifierRunning = false
    
    public private(set) var flags: SCNetworkReachabilityFlags? {
        didSet {
            guard flags != oldValue else { return }
            p_notifyReachabilityDidChange()
        }
    }
    
    private let reachabilityRef: SCNetworkReachability
    private let reachabilitySerialQueue: DispatchQueue
    private let notificationQueue: DispatchQueue?
    
    deinit {
        stopNotifier()
    }
    
    required public init(reachabilityRef: SCNetworkReachability,
                         queueQoS: DispatchQoS = .default,
                         targetQueue: DispatchQueue? = nil,
                         notificationQueue: DispatchQueue? = .main) {
        self.reachabilityRef = reachabilityRef
        self.notificationQueue = notificationQueue
        self.reachabilitySerialQueue = DispatchQueue(label: "com.jinzhuan.reachability", qos: queueQoS, target: targetQueue)
    }
    
    public convenience init(hostname: String,
                            queueQoS: DispatchQoS = .default,
                            targetQueue: DispatchQueue? = nil,
                            notificationQueue: DispatchQueue? = .main) throws {
        
        guard let ref = SCNetworkReachabilityCreateWithName(nil, hostname) else {
            throw FSReachabilityError.failedToCreateWithHostname(hostname, SCError())
        }
        self.init(reachabilityRef: ref, queueQoS: queueQoS, targetQueue: targetQueue, notificationQueue: notificationQueue)
    }
    
    public convenience init(queueQoS: DispatchQoS = .default,
                            targetQueue: DispatchQueue? = nil,
                            notificationQueue: DispatchQueue? = .main) throws {
        
        var zeroAddress = sockaddr()
        zeroAddress.sa_len = UInt8(MemoryLayout<sockaddr>.size)
        zeroAddress.sa_family = sa_family_t(AF_INET)
        
        guard let ref = SCNetworkReachabilityCreateWithAddress(nil, &zeroAddress) else {
            throw FSReachabilityError.failedToCreateWithAddress(zeroAddress, SCError())
        }
        
        self.init(reachabilityRef: ref, queueQoS: queueQoS, targetQueue: targetQueue, notificationQueue: notificationQueue)
    }
}

public extension FSReachability {
    
    var description: String {
        return flags?.description ?? "unavailable flags"
    }
    
    func startNotifier() throws {
        guard !isNotifierRunning else { return }
        
        let callback: SCNetworkReachabilityCallBack = { (reachability, flags, info) in
            guard let info = info else {
                return
            }
            let weakifiedReachability = Unmanaged<FSReachabilityWeakifier>.fromOpaque(info).takeUnretainedValue()
            weakifiedReachability.reachability?.flags = flags
        }
        
        let weakifiedReachability = FSReachabilityWeakifier(reachability: self)
        let opaqueWeakifiedReachability = Unmanaged<FSReachabilityWeakifier>.passUnretained(weakifiedReachability).toOpaque()
        
        var context = SCNetworkReachabilityContext(
            version: 0,
            info: UnsafeMutableRawPointer(opaqueWeakifiedReachability),
            retain: { (info: UnsafeRawPointer) -> UnsafeRawPointer in
                let unmanagedWeakifiedReachability = Unmanaged<FSReachabilityWeakifier>.fromOpaque(info)
                _ = unmanagedWeakifiedReachability.retain()
                return UnsafeRawPointer(unmanagedWeakifiedReachability.toOpaque())
            },
            release: { (info: UnsafeRawPointer) -> Void in
                let unmanagedWeakifiedReachability = Unmanaged<FSReachabilityWeakifier>.fromOpaque(info)
                unmanagedWeakifiedReachability.release()
            },
            copyDescription: { (info: UnsafeRawPointer) -> Unmanaged<CFString> in
                let unmanagedWeakifiedReachability = Unmanaged<FSReachabilityWeakifier>.fromOpaque(info)
                let weakifiedReachability = unmanagedWeakifiedReachability.takeUnretainedValue()
                let description = weakifiedReachability.reachability?.description ?? "nil"
                return Unmanaged.passRetained(description as CFString)
            }
        )
        
        if !SCNetworkReachabilitySetCallback(reachabilityRef, callback, &context) {
            stopNotifier()
            throw FSReachabilityError.unableToSetCallback(SCError())
        }
        
        if !SCNetworkReachabilitySetDispatchQueue(reachabilityRef, reachabilitySerialQueue) {
            stopNotifier()
            throw FSReachabilityError.unableToSetDispatchQueue(SCError())
        }
        
        try p_setReachabilityFlags()
        
        isNotifierRunning = true
    }

    func stopNotifier() {
        defer {
            isNotifierRunning = false
        }
        SCNetworkReachabilitySetCallback(reachabilityRef, nil, nil)
        SCNetworkReachabilitySetDispatchQueue(reachabilityRef, nil)
    }
}

private extension FSReachability {

    func p_setReachabilityFlags() throws {
        try reachabilitySerialQueue.sync { [unowned self] in
            var flags = SCNetworkReachabilityFlags()
            if !SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags) {
                self.stopNotifier()
                throw FSReachabilityError.unableToGetFlags(SCError())
            }
            self.flags = flags
        }
    }
    
    func p_notifyReachabilityDidChange() {
        let notify = { [weak self] in
            guard let self = self else { return }
            self.onReachabilityDidChange?(self)
            self.notificationCenter.post(name: .fs_reachabilityDidChange, object: self)
        }
        notificationQueue?.async(execute: notify) ?? notify()
    }
}

private extension SCNetworkReachabilityFlags {
    
    typealias Connection = FSReachability.Connection
    
    var connection: Connection {
        guard isReachableFlagSet else { return .unavailable }
        
        #if targetEnvironment(simulator)
        return .wifi
        #else
        var connection = Connection.unavailable
        
        if !isConnectionRequiredFlagSet {
            connection = .wifi
        }
        
        if isConnectionOnTrafficOrDemandFlagSet {
            if !isInterventionRequiredFlagSet {
                connection = .wifi
            }
        }
        
        if isOnWWANFlagSet {
            connection = .cellular
        }
        
        return connection
        #endif
    }

    var isOnWWANFlagSet: Bool {
        #if os(iOS)
        return contains(.isWWAN)
        #else
        return false
        #endif
    }
    
    var isReachableFlagSet: Bool {
        return contains(.reachable)
    }
    
    var isConnectionRequiredFlagSet: Bool {
        return contains(.connectionRequired)
    }
    
    var isInterventionRequiredFlagSet: Bool {
        return contains(.interventionRequired)
    }
    
    var isConnectionOnTrafficFlagSet: Bool {
        return contains(.connectionOnTraffic)
    }
    
    var isConnectionOnDemandFlagSet: Bool {
        return contains(.connectionOnDemand)
    }
    
    var isConnectionOnTrafficOrDemandFlagSet: Bool {
        return !intersection([.connectionOnTraffic, .connectionOnDemand]).isEmpty
    }
    
    var isTransientConnectionFlagSet: Bool {
        return contains(.transientConnection)
    }
    
    var isLocalAddressFlagSet: Bool {
        return contains(.isLocalAddress)
    }
    
    var isDirectFlagSet: Bool {
        return contains(.isDirect)
    }
    
    var isConnectionRequiredAndTransientFlagSet: Bool {
        return intersection([.connectionRequired, .transientConnection]) == [.connectionRequired, .transientConnection]
    }
    
    var description: String {
        let W = isOnWWANFlagSet ? "W" : "-"
        let R = isReachableFlagSet ? "R" : "-"
        let c = isConnectionRequiredFlagSet ? "c" : "-"
        let t = isTransientConnectionFlagSet ? "t" : "-"
        let i = isInterventionRequiredFlagSet ? "i" : "-"
        let C = isConnectionOnTrafficFlagSet ? "C" : "-"
        let D = isConnectionOnDemandFlagSet ? "D" : "-"
        let l = isLocalAddressFlagSet ? "l" : "-"
        let d = isDirectFlagSet ? "d" : "-"
        return "\(W)\(R) \(c)\(t)\(i)\(C)\(D)\(l)\(d)"
    }
}

/**
 `FSReachabilityWeakifier` weakly wraps the `FSReachability` class
 in order to break retain cycles when interacting with CoreFoundation.
 
 CoreFoundation callbacks expect a pair of retain/release whenever an
 opaque `info` parameter is provided. These callbacks exist to guard
 against memory management race conditions when invoking the callbacks.
 
 #### Race Condition
 
 If we passed `SCNetworkReachabilitySetCallback` a direct reference to our
 `Reachability` class without also providing corresponding retain/release
 callbacks, then a race condition can lead to crashes when:
 - `Reachability` is deallocated on thread X
 - A `SCNetworkReachability` callback(s) is already in flight on thread Y
 
 #### Retain Cycle
 
 If we pass `FSReachability` to CoreFoundtion while also providing retain/
 release callbacks, we would create a retain cycle once CoreFoundation
 retains our `Reachability` class. This fixes the crashes and his how
 CoreFoundation expects the API to be used, but doesn't play nicely with
 Swift/ARC. This cycle would only be broken after manually calling
 `stopNotifier()` — `deinit` would never be called.
 
 #### FSReachabilityWeakifier
 
 By providing both retain/release callbacks and wrapping `Reachability` in
 a weak wrapper, we:
 - interact correctly with CoreFoundation, thereby avoiding a crash.
   See "Memory Management Programming Guide for Core Foundation".
 - don't alter the public API of `Reachability.swift` in any way
 - still allow for automatic stopping of the notifier on `deinit`.
 */
private class FSReachabilityWeakifier {
    weak var reachability: FSReachability?
    init(reachability: FSReachability) {
        self.reachability = reachability
    }
}
