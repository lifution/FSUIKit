//
//  Data+FSUIKitSwift.swift
//  FSUIKitSwift
//
//  Created by Vincent on 2025/8/28.
//

import Foundation
import CryptoKit

public extension FSUIKitWrapper where Base == Data {
    
    /// 返回 hex 字符串
    ///
    func hexString() -> String {
        base.map { String(format: "%02x", $0) }.joined()
    }
    
    /// SHA256 摘要（Data）
    ///
    func sha256() -> Data {
        let digest = SHA256.hash(data: base)
        return Data(digest)
    }
    
    /// SHA256 hex（字符串形式）
    ///
    func sha256Hex() -> String {
        sha256().fs.hexString()
    }
}
