//
//  DateFormatter+FSUIKitSwift.swift
//  FSUIKitSwift
//
//  Created by Sheng on 2023/12/24.
//

import Foundation

public enum FSDateFormat {
    
    /// `2024-01-01 10:10:10`
    case yyyyMMddHHmmss
    /// `2024-01-01`
    case yyyyMMdd
    /// `01-01`
    case MMDD
    /// `10:10:10`
    case HHmmss
    /// `10:10`
    case HHmm
    /// `星期一`
    case EEEE
    /// `2024`(year)
    case year
    /// `01`(month)
    case month
    /// `01`(day)
    case day
    /// `10`(hour)
    case hour
    /// `10`(minute)
    case minute
    /// `10`(second)
    case second
    /// 10/09/2024
    case ddMMyyyy
    
    var value: String {
        let value: String
        switch self {
        case .yyyyMMddHHmmss:
            value = "yyyy-MM-dd HH:mm:ss"
        case .yyyyMMdd:
            value = "yyyy-MM-dd"
        case .MMDD:
            value = "MM-dd"
        case .HHmmss:
            value = "HH:mm:ss"
        case .HHmm:
            value = "HH:mm"
        case .EEEE:
            value = "EEEE"
        case .year:
            value = "yyyy"
        case .month:
            value = "MM"
        case .day:
            value = "dd"
        case .hour:
            value = "HH"
        case .minute:
            value = "mm"
        case .second:
            value = "ss"
        case .ddMMyyyy:
            value = "dd/MM/yyyy"
        }
        return value
    }
}

public extension FSUIKitWrapper where Base: DateFormatter {
    
    static func localDateFormatterOfFormat(_ format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.dateFormat = format
        return formatter
    }
    
    static func localDateFormatter(of format: FSDateFormat) -> DateFormatter {
        return localDateFormatterOfFormat(format.value)
    }
}
