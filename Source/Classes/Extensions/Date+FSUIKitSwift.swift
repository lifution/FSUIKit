//
//  Date+FSUIKitSwift.swift
//  FSUIKitSwift
//
//  Created by Sheng on 2023/12/24.
//  Copyright © 2023 Sheng. All rights reserved.
//

import Foundation

public extension FSUIKitWrapper where Base == Date {
    
    /// Convert date to local date.
    var localDate: Base? {
        let string = base.fs.string(of: .yyyyMMddHHmmss)
        return Date.fs.localDate(from: string, of: .yyyyMMddHHmmss)
    }
    
    static var localDate: Base? {
        return Date().fs.localDate
    }
    
    var year: Int {
        return (Int(string(of: .year)) ?? 0)
    }
    
    var month: Int {
        return (Int(string(of: .month)) ?? 0)
    }
    
    var day: Int {
        return (Int(string(of: .day)) ?? 0)
    }
    
    var hour: Int {
        return (Int(string(of: .hour)) ?? 0)
    }
    
    var minute: Int {
        return (Int(string(of: .minute)) ?? 0)
    }
    
    var second: Int {
        return (Int(string(of: .second)) ?? 0)
    }
    
    func string(of format: FSDateFormat) -> String {
        let formatter = DateFormatter.fs.localDateFormatter(of: format)
        let string = formatter.string(from: base)
        return string
    }
    
    func string(with format: String) -> String {
        let formatter = DateFormatter.fs.localDateFormatterOfFormat(format)
        let string = formatter.string(from: base)
        return string
    }
    
    static func localDate(from string: String, of format: FSDateFormat = .yyyyMMddHHmmss) -> Date? {
        let formatter = DateFormatter.fs.localDateFormatter(of: format)
        return formatter.date(from: string)
    }
    
    static func localDate(from string: String, with format: String) -> Date? {
        let formatter = DateFormatter.fs.localDateFormatterOfFormat(format)
        return formatter.date(from: string)
    }
}
