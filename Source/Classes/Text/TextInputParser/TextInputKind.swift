//
//  TextInputKind.swift
//  FSUIKit
//
//  Created by VincentLee on 2024/11/18.
//

import UIKit
import Foundation

public enum TextInputKind {
    
    /// 默认
    case `default`
    
    /// 用于过滤字符的正则，比如限制只能输入数字: "[0-9]+"
    /// 如果已提供的类型无法满足需求，可使用该类型自定义过滤规则。
    case regex(regex: String)
    
    /// 数字（不含小数点）
    /// isFirstNonzero: 首位数字是否是非零数字，默认为 true。
    case integer(isFirstNonzero: Bool = true)
    
    /// 小数
    /// maximumFractionDigits: 小数数位限制，默认为 2。
    case decimal(maximumFractionDigits: Int = 2)
    
    /// 百分比
    case percent
    
    /// 数字和字母
    case asciiCapable
    
    /// 密码，只能输入`0-9 a-z A-Z @ . & _`这些字符
    case password
    
    public var keyboardType: UIKeyboardType {
        switch self {
        case .integer:
            return .numberPad
        case .decimal: fallthrough
        case .percent:
            return .decimalPad
        case .asciiCapable: fallthrough
        case .password:
            return .asciiCapable
        default:
            return .default
        }
    }
    
    public var parser: any TextInputParsable {
        switch self {
        case .default:
            return DefaultTextInputParser()
        case .regex(let regex):
            return RegexTextInputParser(regex: regex)
        case .integer(let isFirstNonzero):
            return IntegerTextInputParser(isFirstNonzero: isFirstNonzero)
        case .decimal(let maximumFractionDigits):
            return DecimalTextInputParser(maximumFractionDigits: maximumFractionDigits)
        case .percent:
            return PercentTextInputParser()
        case .asciiCapable:
            return RegexTextInputParser(regex: "[0-9a-zA-Z]+")
        case .password:
            return RegexTextInputParser(regex: "[0-9a-zA-Z@.&_]+")
        }
    }
}
