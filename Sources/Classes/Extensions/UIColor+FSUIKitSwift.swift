//
//  UIColor+FSUIKitSwift.swift
//  FSUIKitSwift
//
//  Created by Sheng on 2023/12/23.
//  Copyright © 2023 Sheng. All rights reserved.
//

import UIKit

extension FSUIKitWrapper where Base: UIColor {
    
    /// Create a random color.
    public static func random() -> UIColor {
        return UIColor(red: .random(in: 0...1),
                       green: .random(in: 0...1),
                       blue: .random(in: 0...1),
                       alpha: 1.0)
    }
    
    /// Create color from hex string.
    ///
    /// #RGB      #f0f == #ffff00ff，RGBA(255, 0, 255, 1)
    /// #ARGB     #0f0f == #00ff00ff，RGBA(255, 0, 255, 0)
    /// #RRGGBB   #ff00ff == #ffff00ff，RGBA(255, 0, 255, 1)
    /// #AARRGGBB #00ff00ff == RGBA(255, 0, 255, 0)
    ///
    public static func color(hexed hex: String) -> UIColor? {
        
        guard hex.count > 0 else {
            return nil
        }
        
        var colorString = hex.uppercased()
        do {
            // Remove prefix `#` / `0x`.
            if colorString.hasPrefix("#") {
                colorString.removeFirst()
            } else if colorString.hasPrefix("0x") {
                colorString.removeFirst(2)
            } else if colorString.hasPrefix("0X") {
                colorString.removeFirst(2)
            }
        }
        
        if colorString.isEmpty {
            return nil
        }
        
        func _colorComponent(from string: String, location: Int, length: Int) -> CGFloat {
            let startIndex = string.index(string.startIndex, offsetBy: location)
            let endIndex = string.index(startIndex, offsetBy: length)
            let substring = String(string[startIndex..<endIndex])
            guard !substring.isEmpty else {
                return 0.0
            }
            let fullHex = (length == 2) ? substring : (substring + substring)
            var hexValue: UInt32 = 0
            if Scanner(string: fullHex).scanHexInt32(&hexValue) {
                return CGFloat(hexValue) / 255.0
            }
            return 0.0
        }
        
        var red: CGFloat   = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat  = 0.0
        var alpha: CGFloat = 0.0
        
        switch colorString.count {
        case 3: // #RGB
            alpha = 1.0
            red   = _colorComponent(from: colorString, location: 0, length: 1)
            green = _colorComponent(from: colorString, location: 1, length: 1)
            blue  = _colorComponent(from: colorString, location: 2, length: 1)
        case 4: // #ARGB
            alpha = _colorComponent(from: colorString, location: 0, length: 1)
            red   = _colorComponent(from: colorString, location: 1, length: 1)
            green = _colorComponent(from: colorString, location: 2, length: 1)
            blue  = _colorComponent(from: colorString, location: 3, length: 1)
        case 6: // #RRGGBB
            alpha = 1.0
            red   = _colorComponent(from: colorString, location: 0, length: 2)
            green = _colorComponent(from: colorString, location: 2, length: 2)
            blue  = _colorComponent(from: colorString, location: 4, length: 2)
        case 8: // #AARRGGBB
            alpha = _colorComponent(from: colorString, location: 0, length: 2)
            red   = _colorComponent(from: colorString, location: 2, length: 2)
            green = _colorComponent(from: colorString, location: 4, length: 2)
            blue  = _colorComponent(from: colorString, location: 6, length: 2)
        default:
            #if DEBUG
            fatalError("Color value [\(hex)] is invalid. It should be a hex value of the form #RBG, #ARGB, #RRGGBB, or #AARRGGBB")
            #endif
            return nil
        }
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}

// MARK: - Common Const Colors

public extension FSUIKitWrapper where Base: UIColor {
    
    /// Color for text title.
    static var title: UIColor {
        return _FSUIColorConsts.title
    }
    
    /// Color for text subtitle.
    static var subtitle: UIColor {
        return _FSUIColorConsts.subtitle
    }
    
    /// Color for placeholder.
    static var placeholder: UIColor {
        return _FSUIColorConsts.placeholder
    }
    
    /// Color for one pixel line.
    static var separator: UIColor {
        return _FSUIColorConsts.separator
    }
    
    /// Color for section separation in table view or collection view.
    static var sectionSeparator: UIColor {
        return _FSUIColorConsts.sectionSeparator
    }
    
    /// Color for warnings.
    static var warning: UIColor {
        return _FSUIColorConsts.warning
    }
}

private struct _FSUIColorConsts {
    static let title: UIColor = .black
    static let subtitle: UIColor = .gray
    static let placeholder: UIColor = .fs.color(hexed: "#C4C8D0") ?? .white
    static let separator: UIColor = .fs.color(hexed: "#CFCFCF") ?? .white
    static let sectionSeparator: UIColor = .fs.color(hexed: "#F7F7F7") ?? .white
    static let warning: UIColor = .fs.color(hexed: "#d9001b") ?? .red
}
