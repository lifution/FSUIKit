//
//  Collection+FSUIKitSwift.swift
//  FSUIKitSwift
//
//  Created by Sheng on 2024/1/29.
//

import Foundation

public extension FSUIKitWrapper where Base: Collection {
    
    /// Converts current collection to json string.
    func toJSONString(prettyPrint: Bool = false) -> String? {
        let object = base
        if JSONSerialization.isValidJSONObject(object) {
            do {
                let jsonData: Data
                if prettyPrint {
                    jsonData = try JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted])
                } else {
                    jsonData = try JSONSerialization.data(withJSONObject: object, options: [])
                }
                return String(data: jsonData, encoding: .utf8)
            } catch {
                return nil
            }
        } else {
            return nil
        }
    }
    
    /// Returns the object at the specified index if it exists, otherwise returns nil.
    ///
    /// - Parameter index: The index of the element to retrieve.
    ///
    func object(at index: Base.Index) -> Base.Element? {
        base.indices.contains(index) ? base[index] : nil
    }
}
