//
//  Collection+FSUIKit.swift
//  FSUIKit
//
//  Created by Sheng on 2024/1/29.
//

import Foundation

public extension FSUIKitWrapper where Base: Collection {
    
    /// Returns: the pretty printed JSON string or nil if any error occur.
    var json: String? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: base, options: .prettyPrinted)
            return String(data: jsonData, encoding: .utf8)
        } catch {
            #if DEBUG
            print("JSON serialization error: \(error)")
            #endif
            return nil
        }
    }
}
