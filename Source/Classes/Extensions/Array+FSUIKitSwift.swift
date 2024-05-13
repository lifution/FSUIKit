//
//  Array+FSUIKitSwift.swift
//  FSUIKitSwift
//
//  Created by Sheng on 2024/3/2.
//

import Foundation

public extension Array {
    
    /// 把一个数组分成指定大小的几个子数组。
    ///
    /// example:
    ///
    ///     let numbers = [1, 2, 3, 4, 5, 6, 7, 8]
    ///     let result = numbers.fs_chunked(into: 3)
    ///     // result: [[1, 2, 3], [4, 5, 6], [7, 8]]
    ///
    func fs_chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
