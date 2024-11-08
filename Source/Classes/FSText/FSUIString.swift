//
//  FSUIString.swift
//  FSUIKitSwift
//
//  Created by VincentLee on 2024/11/8.
//  Copyright © 2024 VincentLee. All rights reserved.
//

import UIKit
import Foundation

protocol FSUIString {
    
    /// 按照「中文 2 个字符、英文 1 个字符」的方式来计算文本长度
    var countOfNonASCIICharacterAsTwo: Int { get }
    
    /// 将字符串从开头裁剪到指定的 index，裁剪时会避免将 emoji 等 "character sequences" 拆散（一个 emoji 表情占用1-4个长度的字符）。
    /// 例如对于字符串 "😊😞"，它的长度为 4，若调用
    /// ``string.substringAvoidBreakingUpCharacterSequences(to: 1, lessValue: false, countingNonASCIICharacterAsTwo: false)``，
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
    func substringAvoidBreakingUpCharacterSequences(to index: Int, lessValue: Bool, countingNonASCIICharacterAsTwo asTwo: Bool) -> Self?
    
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
    func substringAvoidBreakingUpCharacterSequences(with range: NSRange, lessValue: Bool, countingNonASCIICharacterAsTwo asTwo: Bool) -> Self?
}
