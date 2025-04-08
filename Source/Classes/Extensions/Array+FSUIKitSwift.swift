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
    
    ///
    /// 移除集合中的元素，并返回被移除的元素集合。
    ///
    @discardableResult
    mutating func fs_remove(where shouldBeRemoved: (Element) -> Bool) -> [Element] {
        var removedElements = [Element]()
        self = filter {
            if shouldBeRemoved($0) {
                removedElements.append($0)
                return false
            } else {
                return true
            }
        }
        return removedElements
    }
}

public extension Sequence {
    func fs_removingDuplicates<T: Hashable>(withSame keyPath: KeyPath<Element, T>) -> [Element] {
        var seen = Set<T>()
        return filter { element in
            guard seen.insert(element[keyPath: keyPath]).inserted else { return false }
            return true
        }
    }
}
