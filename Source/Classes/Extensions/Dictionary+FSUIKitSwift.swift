//
//  Dictionary+FSUIKitSwift.swift
//  FSUIKitSwift
//
//  Created by VincentLee on 2025/7/15.
//  Copyright © 2025 VincentLee. All rights reserved.
//

import Foundation

public extension FSUIKitWrapper where Base == [String: Any] {
    
    func bool(forKey key: String) -> Bool {
        guard let value = base[key] else {
            return false
        }
        switch value {
        case let boolValue as Bool:
            return boolValue
            
        case let intValue as Int:
            return intValue != 0
            
        case let numberValue as NSNumber:
            if CFGetTypeID(numberValue) == CFBooleanGetTypeID() {
                return numberValue.boolValue
            }
            return numberValue.intValue != 0
            
        case let stringValue as String:
            let lowercased = stringValue.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            switch lowercased {
            case "true", "yes":
                return true
            case "false", "no":
                return false
            default:
                if let intValue = Int(lowercased) {
                    return intValue != 0
                }
                return false
            }
            
        default:
            return false
        }
    }
    
    func int(forKey key: String) -> Int? {
        guard let value = base[key] else {
            return nil
        }
        switch value {
        case let intValue as Int:
            return intValue
            
        case let doubleValue as Double:
            return Int(doubleValue)
            
        case let floatValue as Float:
            return Int(floatValue)
            
        case let numberValue as NSNumber:
            return numberValue.intValue
            
        case let stringValue as String:
            let trimmed = stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            return Int(trimmed)
            
        default:
            return nil
        }
    }
    
    func double(forKey key: String) -> Double? {
        guard let value = base[key] else {
            return nil
        }
        switch value {
        case let intValue as Int:
            return Double(intValue)
            
        case let doubleValue as Double:
            return doubleValue
            
        case let floatValue as Float:
            return Double(floatValue)
            
        case let numberValue as NSNumber:
            return numberValue.doubleValue
            
        case let stringValue as String:
            let trimmed = stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            return Double(trimmed)
            
        default:
            return nil
        }
    }
    
    func float(forKey key: String) -> Float? {
        guard let value = base[key] else {
            return nil
        }
        switch value {
        case let intValue as Int:
            return Float(intValue)
            
        case let doubleValue as Double:
            return Float(doubleValue)
            
        case let floatValue as Float:
            return floatValue
            
        case let numberValue as NSNumber:
            return numberValue.floatValue
            
        case let stringValue as String:
            let trimmed = stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            return Float(trimmed)
            
        default:
            return nil
        }
    }
    
    func string(forKey key: String) -> String? {
        guard let value = base[key] else {
            return nil
        }
        switch value {
        case let string as String:
            return string
            
        case let intValue as Int:
            return String(intValue)
            
        case let doubleValue as Double:
            return String(doubleValue)
            
        case let floatValue as Float:
            return String(floatValue)
            
        case let boolValue as Bool:
            return boolValue ? "1" : "0"
            
        case let number as NSNumber:
            if CFGetTypeID(number) == CFBooleanGetTypeID() {
                return number.boolValue ? "1" : "0"
            }
            return number.stringValue
            
        default:
            return nil
        }
    }
    
    func decimal(forKey key: String) -> Decimal? {
        guard let value = base[key] else {
            return nil
        }
        switch value {
        case let decimal as Decimal:
            return decimal
        case let number as NSNumber:
            return number.decimalValue
        case let string as String:
            return Decimal(string: string)
        case let double as Double:
            return Decimal(double)
        case let float as Float:
            // Float 需要先转 Double，避免精度问题
            return Decimal(Double(float))
        case let int as Int:
            return Decimal(int)
        case let uint as UInt:
            return Decimal(uint)
        case let bool as Bool:
            return bool ? Decimal(1) : Decimal(0)
        case let nsDecimal as NSDecimalNumber:
            return nsDecimal as Decimal
        default:
            return nil // 不能转换的类型则返回 nil
        }
    }
}
