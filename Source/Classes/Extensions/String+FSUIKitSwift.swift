//
//  String+FSUIKitSwift.swift
//  FSUIKitSwift
//
//  Created by Sheng on 2024/1/13.
//  Copyright © 2024 Sheng. All rights reserved.
//

import Foundation
import CryptoKit
import CommonCrypto

public extension FSUIKitWrapper where Base == String {
    
    /// Checks whether the current string is containing Arabic characters.
    var containsArabic: Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", "(?s).*\\p{Arabic}.*")
        return predicate.evaluate(with: base)
    }
    
    /// Checks whether the current string is a chinese mainland mobile phone number.
    var isCNPhoneNumber: Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", "^1[0-9]{10}$")
        return predicate.evaluate(with: base)
    }
    
    var firstUppercased: String { 
        return base.prefix(1).uppercased() + base.dropFirst()
    }
    
    var firstCapitalized: String { 
        return base.prefix(1).capitalized + base.dropFirst()
    }
    
    /// 按照「中文 2 个字符、英文 1 个字符」的方式来计算文本长度
    var countOfNonASCIICharacterAsTwo: Int {
        guard !base.isEmpty else {
            return 0
        }
        var length: Int = 0
        for c in base {
            if c.isASCII {
                length += 1
            } else {
                length += 2
            }
        }
        return length
    }
    
    var isSingleEmoji: Bool {
        base.count == 1 && containsEmoji
    }
    
    var containsEmoji: Bool {
        base.contains { $0.fs.isEmoji }
    }
    
    var containsOnlyEmoji: Bool {
        !base.isEmpty && !base.contains { !$0.fs.isEmoji }
    }
    
    var nonEmojiString: String {
        base.filter { !$0.fs.isEmoji }
    }
    
    var emojiString: String {
        emojis.map { String($0) }.reduce("", +)
    }
    
    var emojis: [Character] {
        base.filter { $0.fs.isEmoji }
    }
    
    var emojiScalars: [UnicodeScalar] {
        base.filter { $0.fs.isEmoji }.flatMap { $0.unicodeScalars }
    }
    
    /// 把当前字符串使用 base64 编码并返回编码结果。
    func toBase64() -> String {
        return Data(base.utf8).base64EncodedString()
    }
    
    /// 对当前字符串计算 md5。
    func toMD5() -> String? {
        if #available(iOS 13.0, *) {
            guard let messageData = base.data(using: .utf8) else {
                #if DEBUG
                fatalError()
                #else
                return nil
                #endif
            }
            let digestData = Insecure.MD5.hash (data: messageData)
            let digestHex = String(digestData.map { String(format: "%02hhx", $0) }.joined().prefix(32))
            return digestHex
        } else {
            let md5Data: Data = {
                let length = Int(CC_MD5_DIGEST_LENGTH)
                let messageData = base.data(using:.utf8)!
                var digestData = Data(count: length)
                _ = digestData.withUnsafeMutableBytes { digestBytes -> UInt8 in
                    messageData.withUnsafeBytes { messageBytes -> UInt8 in
                        if let messageBytesBaseAddress = messageBytes.baseAddress, let digestBytesBlindMemory = digestBytes.bindMemory(to: UInt8.self).baseAddress {
                            let messageLength = CC_LONG(messageData.count)
                            CC_MD5(messageBytesBaseAddress, messageLength, digestBytesBlindMemory)
                        }
                        return 0
                    }
                }
                return digestData
            }()
            let md5Hex = md5Data.map { String(format: "%02hhx", $0) }.joined()
            return md5Hex
        }
    }
    
    /// Convert current string to object.
    func toJSON<T>() -> T? {
        guard
            let data = base.data(using: .utf8),
            let result = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? T
        else {
            return nil
        }
        return result
    }
    
    /// Remove all non-numeric characters.
    func removeNonnumeric() -> String {
        return base.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
    }
}

public extension FSUIKitWrapper where Base == String {
    
    /// 对一段经过 base64 编码的字符串解码并返回解码结果。
    /// 如果解码失败则返回 nil。
    static func decodeBase64(from string: String) -> String? {
        guard let data = Data(base64Encoded: string) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
    
    /// 简化 `#if DEBUG` 的操作，传入两个环境下的字符串，该方法内部会
    /// 根据当前应用的环境返回对应的那个字符串。
    /// 该方法只判断 debug 和 release 两种模式。
    static func string(debug: String, release: String) -> String {
        #if DEBUG
        return debug
        #else
        return release
        #endif
    }
}

public extension FSUIKitWrapper where Base == String {
    
    func substring(at index: Int) -> Character? {
        guard index >= 0, index < base.count else {
            return nil
        }
        let index = base.index(base.startIndex, offsetBy: index)
        return base[index]
    }
    
    func substring(forRange range: Range<Int>) -> String? {
        guard range.lowerBound >= 0, range.lowerBound < base.count else {
            return nil
        }
        let from = range.lowerBound
        let to = (range.upperBound < base.count) ? range.upperBound : base.count
        let start = base.index(base.startIndex, offsetBy: from)
        let end = base.index(base.startIndex, offsetBy: to)
        return String(base[start..<end])
    }
    
    func substring(withClosedRange range: ClosedRange<Int>) -> String? {
        return substring(forRange: range.lowerBound..<(range.upperBound + 1))
    }
    
    func substring(with range: NSRange) -> String? {
        guard range.location != NSNotFound, range.length != NSNotFound else {
            return nil
        }
        guard range.location < base.count, range.location + range.length <= base.count else {
            return nil
        }
        return substring(forRange: range.location..<(range.location + range.length))
    }
    
    /// 将字符串里指定 range 的子字符串裁剪出来，会避免将 emoji 等 "character sequences" 拆散（一个 emoji 表情占用 1-4 个长度的字符）。
    /// 例如对于字符串 "😊😞"，它的长度为 4，在 lessValue 模式下，裁剪 (0, 1) 得到的是空字符串，裁剪 (0, 2) 得到的是 "😊"。
    /// 在非 lessValue 模式下，裁剪 (0, 1) 或 (0, 2)，得到的都是 "😊"。
    ///
    /// - Parameters:
    ///   - range:     要裁剪的文字位置。
    ///   - lessValue: 裁剪时若遇到 "character sequences"，是向下取整还是向上取整。
    ///   - countingNonASCIICharacterAsTwo: 是否按照「英文 1 个字符长度、中文 2 个字符长度」的方式来裁剪。
    ///
    /// - Returns: 裁剪完的字符。
    ///
    func substringAvoidBreakingUpCharacterSequences(
        range: NSRange,
        lessValue: Bool,
        countingNonASCIICharacterAsTwo: Bool
    ) -> String {
        
        func downRoundRangeOfComposedCharacterSequences(for _range: NSRange) -> NSRange {
            if _range.length == 0 {
                return _range
            }
            let resultRange: NSRange = {
                let from = String.Index(utf16Offset: _range.location, in: base)
                let to = String.Index(utf16Offset: (_range.location + _range.length), in: base)
                let range = base.rangeOfComposedCharacterSequences(for: from..<to)
                return NSRange(range, in: base)
            }()
            if NSMaxRange(resultRange) > NSMaxRange(_range) {
                return downRoundRangeOfComposedCharacterSequences(for: NSRange(location: _range.location, length: _range.length - 1))
            }
            return resultRange
        }
        
        let range: NSRange = {
            if !countingNonASCIICharacterAsTwo {
                return range
            }
            var strlength: Int = 0
            var resultRange = NSRange(location: NSNotFound, length: 0)
            for (i, c) in base.enumerated() {
                if c.isASCII {
                    strlength += 1
                } else {
                    strlength += 2
                }
                if strlength >= range.location + 1 {
                    if resultRange.location == NSNotFound {
                        resultRange.location = i
                    }
                    if range.length > 0, strlength >= NSMaxRange(range) {
                        resultRange.length = i - resultRange.location + (strlength == NSMaxRange(range) ? 1 : 0)
                        return resultRange
                    }
                }
            }
            return resultRange
        }()
        let characterSequencesRange: NSRange = {
            if lessValue {
                return downRoundRangeOfComposedCharacterSequences(for: range)
            }
            let from = String.Index(utf16Offset: range.location, in: base)
            let to = String.Index(utf16Offset: (range.location + range.length), in: base)
            let range = base.rangeOfComposedCharacterSequences(for: from..<to)
            return NSRange(range, in: base)
        }()
        if let r = Range(characterSequencesRange, in: base) {
            let resultString = base[r]
            return String(resultString)
        }
        return base
    }
    
    /// 将字符串从开头裁剪到指定的 index，裁剪时会避免将 emoji 等 "character sequences" 拆散（一个 emoji 表情占用1-4个长度的字符）。
    /// 例如对于字符串 "😊😞"，它的长度为 4，若调用
    /// ``string.fs.substringAvoidBreakingUpCharacterSequences(to: 1, lessValue: false, countingNonASCIICharacterAsTwo: false)``，
    /// 将返回 "😊"。若调用系统的 ``NSString.substring(to:1)``，将返回 "?"。（? 表示乱码，因为第一个 emoji 表情被从中间裁开了）。
    ///
    /// - Parameters:
    ///   - index: 要裁剪到哪个 index 为止（不包含该 index，策略与系统的 ``NSString.substring(to:)`` 一致），如果
    ///            countingNonASCIICharacterAsTwo 为 true，则 index 也要按 true 的方式来算。
    ///   - lessValue: 裁剪时若遇到 "character sequences"，是向下取整还是向上取整。
    ///   - asTwo: 是否按照 英文 1 个字符长度、中文 2 个字符长度的方式来裁剪
    ///
    /// - Returns: 裁剪完的字符
    ///
    func substringAvoidBreakingUpCharacterSequences(
        to index: Int,
        lessValue: Bool,
        countingNonASCIICharacterAsTwo asTwo: Bool
    ) -> String? {
        return FSUIStringPrivate.substring(base,
                                           avoidBreakingUpCharacterSequencesTo: index,
                                           lessValue: lessValue,
                                           countingNonASCIICharacterAsTwo: asTwo)
    }
    
    /// 将字符串里指定 range 的子字符串裁剪出来，会避免将 emoji 等 "character sequences" 拆散（一个 emoji 表情占用1-4个长度的字符）。
    /// 例如对于字符串 "😊😞"，它的长度为4，在 lessValue 模式下，裁剪 (0, 1) 得到的是空字符串，裁剪 (0, 2) 得到的是 "😊"。
    /// 在非 lessValue 模式下，裁剪 (0, 1) 或 (0, 2)，得到的都是 "😊"。
    ///
    /// - Parameters:
    ///   - range: 要裁剪的文字位置
    ///   - lessValue: 裁剪时若遇到 "character sequences"，是向下取整还是向上取整（系统的 ``NSString.rangeOfComposedCharacterSequences(for:)``
    ///                会尽量把给定 range 里包含的所有 character sequences 都包含在内，也即 lessValue = false）。
    ///   - asTwo: 是否按照 英文 1 个字符长度、中文 2 个字符长度的方式来裁剪
    ///
    /// - Returns: 裁剪完的字符
    ///
    func substringAvoidBreakingUpCharacterSequences(
        with range: NSRange,
        lessValue: Bool,
        countingNonASCIICharacterAsTwo asTwo: Bool
    ) -> String? {
        return FSUIStringPrivate.substring(base,
                                           avoidBreakingUpCharacterSequencesWith: range,
                                           lessValue: lessValue,
                                           countingNonASCIICharacterAsTwo: asTwo)
    }
}
