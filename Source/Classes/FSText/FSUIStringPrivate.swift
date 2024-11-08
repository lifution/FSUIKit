//
//  FSUIStringPrivate.swift
//  FSUIKitSwift
//
//  Created by VincentLee on 2024/11/8.
//  Copyright © 2024 VincentLee. All rights reserved.
//

import UIKit
import Foundation

struct FSUIStringPrivate {
    
    private init() {}
    
    static func substring(
        _ string: String,
        avoidBreakingUpCharacterSequencesTo index: Int,
        lessValue: Bool,
        countingNonASCIICharacterAsTwo asTwo: Bool
    ) -> String {
        guard !string.isEmpty else {
            return ""
        }
        let count = asTwo ? string.fs.countOfNonASCIICharacterAsTwo : string.count
        guard index > 0, index <= count else {
            #if DEBUG
            fatalError("\(String(describing: #function)), index \(index) out of bounds, string = \(string)")
            #else
            return ""
            #endif
        }
        /// 根据系统 ``NSString.substring(to:)`` 的注释，在 index 等于 count 时会返回 self 的 copy。
        if index == count {
            return string
        }
        // 实际计算都按照系统默认的 count 规则来
        var index = asTwo ? transformIndexToDefaultMode(index, in: string) : index
        let range = (string as NSString).rangeOfComposedCharacterSequence(at: index)
        if range.length != 1 {
            index = lessValue ? range.location : NSMaxRange(range)
        }
        return (string as NSString).substring(to: index)
    }
    
    static func substring(
        _ string: String,
        avoidBreakingUpCharacterSequencesWith range: NSRange,
        lessValue: Bool,
        countingNonASCIICharacterAsTwo asTwo: Bool
    ) -> String {
        guard !string.isEmpty else {
            return ""
        }
        let count = asTwo ? string.fs.countOfNonASCIICharacterAsTwo : string.count
        guard NSMaxRange(range) <= count else {
            #if DEBUG
            fatalError("\(String(describing: #function)), range \(range) out of bounds, string = \(string)")
            #else
            return ""
            #endif
        }
        // 实际计算都按照系统默认的 count 规则来
        let range = asTwo ? transformRangeToDefaultMode(range, lessValue: lessValue, in: string) : range
        let characterSequencesRange = lessValue ? downRoundRangeOfComposedCharacterSequences(range, in: string) : (string as NSString).rangeOfComposedCharacterSequences(for: range)
        return (string as NSString).substring(with: characterSequencesRange)
    }
    
    static func transformRangeToDefaultMode(_ range: NSRange, lessValue: Bool, in string: String) -> NSRange {
        var resultRange = NSMakeRange(NSNotFound, 0)
        var length = 0
        for (i, c) in string.enumerated() {
            if c.isASCII {
                length += 1
            } else {
                length += 2
            }
            if (lessValue && c.isASCII && length >= range.location + 1)
                || (lessValue && !c.isASCII && length > range.location + 1)
                || (!lessValue && length >= range.location + 1) {
                if resultRange.location == NSNotFound {
                    resultRange.location = i
                }
                if range.length > 0, length >= NSMaxRange(range) {
                    resultRange.length = i - resultRange.location
                    if lessValue, length == NSMaxRange(range) {
                        resultRange.length += 1 // 尽量不包含字符的，只有在精准等于时才 +1，否则就不算这最后一个字符
                    } else if !lessValue {
                        resultRange.length += 1 // 只要是最大能力包含字符的，一进来就 +1
                    }
                    return resultRange
                }
            }
        }
        return resultRange
    }
    
    static func transformIndexToDefaultMode(_ index: Int, in string: String) -> Int {
        var length = 0
        for (i, c) in string.enumerated() {
            if c.isASCII {
                length += 1
            } else {
                length += 2
            }
            if length >= index + 1 {
                return i
            }
        }
        return 0
    }
    
    static func downRoundRangeOfComposedCharacterSequences(_ range: NSRange, in string: String) -> NSRange {
        if range.length == 0 {
            return range
        }
        let systemRange = (string as NSString).rangeOfComposedCharacterSequences(for: range) // 系统总是往大取值
        if NSEqualRanges(range, systemRange) {
            return range
        }
        var result = systemRange
        if range.location > systemRange.location {
            // 意味着传进来的 range 起点刚好在某个 Character Sequence 中间，
            // 所以要把这个 Character Sequence 遗弃掉，从它后面的字符开始算。
            let beginRange = (string as NSString).rangeOfComposedCharacterSequence(at: range.location)
            result.location = NSMaxRange(beginRange)
            result.length -= beginRange.length
        }
        if NSMaxRange(range) < NSMaxRange(systemRange) {
            // 意味着传进来的 range 终点刚好在某个 Character Sequence 中间，
            // 所以要把这个 Character Sequence 遗弃掉，只取到它前面的字符。
            let endRange = (string as NSString).rangeOfComposedCharacterSequence(at: NSMaxRange(range) - 1)
            // 如果参数传进来的 range 刚好落在一个 emoji 的中间，就会导致前面减完 beginRange 这里又减掉一个 endRange，
            // 出现负数（注意这里 length 是 NSUInteger），所以做个保护，可以用 👨‍👩‍👧‍👦 测试，这个 emoji 长度是 11。
            if result.length >= endRange.length {
                result.length = result.length - endRange.length
            } else {
                result.length = 0
            }
        }
        return result
    }
}
