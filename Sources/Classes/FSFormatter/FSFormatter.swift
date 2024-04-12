//
//  FSFormatter.swift
//  FSUIKitSwift
//
//  Created by Sheng on 2023/12/24.
//  Copyright © 2023 Sheng. All rights reserved.
//

import Foundation

public final class FSFormatter: Formatter {
    
    fileprivate enum Unit: String {
        case none = ""
        case K
        case M
        case B
    }
    
    // MARK: Properties/Private
    
    private let numberFormatter = NumberFormatter()
    private let unitSize: [Unit: Double] = [
        .none: 1,
        .K: 1000,
        .M: pow(1000, 2),
        .B: pow(1000, 3)
    ]
    
    // MARK: Override
    
    public override func string(for obj: Any?) -> String? {
        if let value = obj as? Double {
            return string(fromNumber: Int64(value))
        }
        return nil
    }
    
    // MARK: Public
    
    /// e.g. 1100 -> 1.1K, 1100000 -> 1.1M
    public func string(fromNumber number: Int64) -> String {
        numberFormatter.numberStyle = .decimal
        numberFormatter.roundingMode = .down
        return p_convertValue(fromNumber: number)
    }
    
    /// e.g. 2023.11.13 10:12:13 -> Yesterday 10:12
    public func string(fromMessageDate date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return date.fs.string(of: .HHmm)
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday" + " " + date.fs.string(of: .HHmm)
        } else if calendar.isDate(date, equalTo: Date(), toGranularity: .year) {
            return date.fs.string(of: .MMDD) + " " + date.fs.string(of: .HHmm)
        } else {
            return date.fs.string(of: .yyyyMMdd)
        }
    }
    
    /// Converts unread count to string.
    public func string(fromUnreadMessageCount count: Int) -> String {
        return count > 999 ? "999+" : "\(count)"
    }
}

// MARK: - Private

private extension FSFormatter {
    
    func p_convertValue(fromNumber number: Int64) -> String {
        let number = Double(number)
        if number == 0 {
            return p_partsToIncludeFor(value: "Zero", unit: .none)
        } else {
            if number == 1 || number == -1 {
                return p_formatNumberFor(number: number, unit: .none)
            }else if number < unitSize[.K]! && number > -unitSize[.K]! {
                return p_divide(number, by: unitSize, for: .none)
            } else if number < unitSize[.M]! && number > -unitSize[.M]! {
                return p_divide(number, by: unitSize, for: .K)
            } else if number < unitSize[.B]! && number > -unitSize[.B]! {
                return p_divide(number, by: unitSize, for: .M)
            } else {
                return p_divide(number, by: unitSize, for: .B)
            }
        }
    }
    
    func p_divide(_ number: Double, by unitSize: [Unit: Double], for unit: Unit) -> String {
        guard let numberSizeUnit = unitSize[unit] else {
            fatalError("Cannot find value \(unit)")
        }
        let result = number/numberSizeUnit
        return p_formatNumberFor(number: result, unit: unit)
    }
    
    func p_formatNumberFor(number: Double, unit: Unit) -> String {
        switch unit {
        case .none, .K:
            numberFormatter.minimumFractionDigits = 0
            numberFormatter.maximumFractionDigits = 1
            let result = numberFormatter.string(from: NSNumber(value: number))
            return p_partsToIncludeFor(value: result!, unit: unit)
        case .M:
            numberFormatter.minimumFractionDigits = 0
            numberFormatter.maximumFractionDigits = 2
            let result = numberFormatter.string(from: NSNumber(value: number))
            return p_partsToIncludeFor(value: result!, unit: unit)
        default:
            let result: String
            numberFormatter.minimumFractionDigits = 0
            numberFormatter.maximumFractionDigits = 3
            if number < 0 && false{
                let negNumber = round(number * 100) / 100
                result = numberFormatter.string(from: NSNumber(value: negNumber))!
            } else {
                result = numberFormatter.string(from: NSNumber(value: number))!
            }
            return p_partsToIncludeFor(value: result, unit: unit)
        }
    }
    
    func p_partsToIncludeFor(value: String, unit: Unit) -> String {
        if value == "Zero" {
            return "0\(unit.rawValue)"
        } else {
            return "\(value)\(unit.rawValue)"
        }
    }
    
    func p_lengthOfInt(number: Int) -> Int {
        guard number != 0 else {
            return 1
        }
        var num = abs(number)
        var length = 0
        while num > 0 {
            length += 1
            num /= 10
        }
        return length
    }
}
