//
//  FSRuntime.swift
//  FSUIKitSwift
//
//  Created by VincentLee on 2024/11/25.
//

import UIKit
import Foundation

/// 判断两个字符串在「忽略 empty 的情况下」是否还相等
/// 1. 如果两个都是 nil 则返回 true
/// 2. 如果两个都是 empty 则返回 true
/// 3. 如果一个为 nil，另一个为 empty 则同样返回 true
///
/// 该方法一般用于特定的场景，字符串为 empty 或 nil 都是表达一样的意思。
///
public func fs_isStringEqualIgnoringEmpty(_ lhs: String?, _ rhs: String?) -> Bool {
    if let l = lhs, l.isEmpty, rhs == nil {
        return true
    }
    if let r = rhs, r.isEmpty, lhs == nil {
        return true
    }
    return lhs == rhs
}
