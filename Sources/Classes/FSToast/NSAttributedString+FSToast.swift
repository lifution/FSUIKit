//
//  NSAttributedString+FSToast.swift
//  FSUIKit
//
//  Created by Sheng on 2024/2/6.
//  Copyright © 2024 Sheng. All rights reserved.
//

import UIKit
import Foundation

extension FSUIKitWrapper where Base: NSAttributedString {
    
    /// FSToast 默认的 text 富文本。
    public static func toast_richText(string str: String) -> NSAttributedString {
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        
        let color: UIColor = {
            if #available(iOS 13, *) {
                return UIColor(dynamicProvider: { trait in
                    if trait.userInterfaceStyle == .dark {
                        return .black
                    }
                    return .white
                })
            }
            return .black
        }()
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14.0),
            .paragraphStyle: style,
            .foregroundColor: color
        ]
        return NSAttributedString(string: str, attributes: attributes)
    }
    
    /// FSToast 默认的 detail 富文本。
    public static func toast_richDetail(string str: String) -> NSAttributedString {
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        
        let color: UIColor = {
            if #available(iOS 13, *) {
                return UIColor(dynamicProvider: { trait in
                    if trait.userInterfaceStyle == .dark {
                        return .black
                    }
                    return .white
                })
            }
            return .black
        }()
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12.0),
            .paragraphStyle: style,
            .foregroundColor: color
        ]
        return NSAttributedString(string: str, attributes: attributes)
    }
}
