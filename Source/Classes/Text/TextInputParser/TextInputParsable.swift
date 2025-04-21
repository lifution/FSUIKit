//
//  TextInputParsable.swift
//  FSUIKit
//
//  Created by VincentLee on 2024/11/18.
//

import UIKit
import Foundation

protocol TextInputParsable {
    associatedtype ValueType
    /// 判断是否应该插入新字符
    func text(_ text: String, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    /// 格式化字符串
    func formatting(_ text: String) -> String
    /// 将字符串转化为对应的类型
    func value(for text: String) -> ValueType
}
