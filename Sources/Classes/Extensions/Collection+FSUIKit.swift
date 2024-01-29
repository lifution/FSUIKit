//
//  Collection+FSUIKit.swift
//  FSUIKit
//
//  Created by Sheng on 2024/1/29.
//

import Foundation

public extension FSUIKitWrapper where Base: Collection {
    
    /// Returns: the pretty printed JSON string or an error string if any error occur.
    var json: String {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: [.prettyPrinted])
            return String(data: jsonData, encoding: .utf8) ?? ""
        } catch {
            return "json serialization error: \(error)"
        }
    }
}
