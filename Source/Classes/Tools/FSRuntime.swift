//
//  FSRuntime.swift
//  FSUIKitSwift
//
//  Created by VincentLee on 2024/11/25.
//

import UIKit
import Foundation

/// 判断两个字符串在「忽略 empty 的情况下」是否还相等
///
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

/// 判断两个字符串的内容是否相等，只判断字符串的内容，如果内容无效则表示不相等，
/// Swift.String 的 ``==`` 方法，如果两个比较的 String 都为 nil 也会返回 true，
/// 在一些特定场景下，只有内容有效才表示相等，该方法就是为了这些场景而设计的。
///
/// 1. 如果两个都是 nil 则返回 false
/// 2. 如果两个都是 empty 则返回 false
/// 3. 如果一个为 nil，另一个为 empty 则同样返回 false
///
public func fs_isStringValueEqual(_ lhs: String?, _ rhs: String?) -> Bool {
    // 只有当 userId 非空时才比较
    let lhsValid = lhs?.isEmpty == false  // 确保 lhs 非空
    let rhsValid = rhs?.isEmpty == false  // 确保 rhs 非空
    if lhsValid && rhsValid {
        return lhs == rhs
    }
    return false // 如果有任何一个是 nil 或 ""，返回 false
}
