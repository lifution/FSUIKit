//
//  DateFormatter+FSUIKitSwift.swift
//  FSUIKitSwift
//
//  Created by Sheng on 2023/12/24.
//

import Foundation

public enum FSDateFormat {
    /// `2023-01-01 10:10:10`
    case yyyyMMddHHmmss
    /// `2023-01-01`
    case yyyyMMdd
    /// `01-01`
    case MMDD
    /// `10:10:10`
    case HHmmss
    /// `10:10`
    case HHmm
    /// `星期一`
    case EEEE
    /// `2023`(year)
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
    ///10/09/2010
    case ddMMyyyy
}

extension FSUIKitWrapper where Base: DateFormatter {
    
    public static func localDateFormatter(of format: FSDateFormat) -> DateFormatter {
        
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        
        switch format {
        case .yyyyMMddHHmmss:
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        case .yyyyMMdd:
            formatter.dateFormat = "yyyy-MM-dd"
        case .MMDD:
            formatter.dateFormat = "MM-dd"
        case .HHmmss:
            formatter.dateFormat = "HH:mm:ss"
        case .HHmm:
            formatter.dateFormat = "HH:mm"
        case .EEEE:
            formatter.dateFormat = "EEEE"
        case .year:
            formatter.dateFormat = "yyyy"
        case .month:
            formatter.dateFormat = "MM"
        case .day:
            formatter.dateFormat = "dd"
        case .hour:
            formatter.dateFormat = "HH"
        case .minute:
            formatter.dateFormat = "mm"
        case .second:
            formatter.dateFormat = "ss"
        case .ddMMyyyy:
            formatter.dateFormat = "dd/MM/yyyy"
        }
        
        return formatter
    }
}
