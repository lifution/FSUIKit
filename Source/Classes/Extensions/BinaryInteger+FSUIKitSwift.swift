//
//  BinaryInteger+FSUIKitSwift.swift
//  FSUIKitSwift
//
//  Created by Sheng on 2024/1/30.
//

import Foundation

public extension FSUIKitWrapper where Base: BinaryInteger {
    
    /// 阿拉伯数字转中文
    var chinese: String? {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.numberStyle = .spellOut
        return formatter.string(from: NSDecimalNumber(string: "\(base)"))
    }
}
