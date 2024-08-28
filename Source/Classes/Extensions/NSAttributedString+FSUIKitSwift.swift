//
//  NSAttributedString+FSUIKitSwift.swift
//  FSUIKitSwift
//
//  Created by Sheng on 2024/1/4.
//  Copyright © 2024 Sheng. All rights reserved.
//

import UIKit
import CoreText
import Foundation

extension FSUIKitWrapper where Base: NSAttributedString {
    
    // MARK: Properties
    
    /// 当前 NSAttributedString 的 size，不限制 size 和行数。
    public var size: CGSize {
        let size = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        return self.size(limitedSize: size)
    }
    
    // MARK: Initializations
    
    public static func attributedString(string: String?,
                                        font: UIFont? = nil,
                                        color: UIColor? = nil,
                                        lineSpacing: CGFloat = 0.0,
                                        kernSpacing: CGFloat = 0.0,
                                        textAlignment: NSTextAlignment = .left) -> Base {
        let text = string ?? ""
        let font = font ?? .systemFont(ofSize: 16.0)
        let color = color ?? .black
        
        let style = NSMutableParagraphStyle()
        style.alignment = textAlignment
        style.lineSpacing = lineSpacing
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font : font,
            .kern : kernSpacing,
            .paragraphStyle : style,
            .foregroundColor : color
        ]
        
        return Base(string: text, attributes: attributes)
    }
    
    // MARK: Functions
    
    /// 计算当前 NSAttributedString 的 size。
    ///
    /// - Parameters:
    ///   - limitedWidth:         限制的宽度（高度不限制）。
    ///   - limitedNumberOfLines: 限制的行数，0 表示为不限制。
    ///
    public func size(limitedWidth: CGFloat, limitedNumberOfLines: Int = 0) -> CGSize {
        let constraint = CGSize(width: limitedWidth, height: CGFloat.greatestFiniteMagnitude)
        return size(limitedSize: constraint, limitedNumberOfLines: limitedNumberOfLines)
    }
    
    /// 计算当前 NSAttributedString 的 size。
    ///
    /// - Parameters:
    ///   - limitedSize:          限制的 size，如果传入 .zero 则默认为不限制.
    ///   - limitedNumberOfLines: 限制的行数，0 表示为不限制。
    ///
    public func size(limitedSize: CGSize, limitedNumberOfLines: Int = 0) -> CGSize {
        return NSAttributedString.fs.size(of: base, limitedSize: limitedSize, limitedNumberOfLines: limitedNumberOfLines)
    }
    
    /// 计算指定 NSAttributedString 实例的 size。
    ///
    /// - Parameters:
    ///   - attributedString:     需要计算 size 的 NSAttributedString 实例。
    ///   - limitedSize:          限制最大的 size。
    ///   - limitedNumberOfLines: 限制最大的行数，0 表示为不限制。
    ///   
    public static func size(of attributedString: NSAttributedString?, limitedSize: CGSize? = .zero, limitedNumberOfLines: Int = 0) -> CGSize {
        guard let att_string = attributedString, !att_string.string.isEmpty else {
            return .zero
        }
        
//        let constraints: CGSize = {
//            if let size = limitedSize, size != .zero {
//                return size
//            }
//            return CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
//        }()
//        let size = att_string.boundingRect(with: constraints, options: .usesLineFragmentOrigin, context: nil)
//        return .init(width: ceil(size.width), height: ceil(size.height))
        
        /** 以下方法计算多行时没问题，但是计算单行时出错了，单行返回的高度太高。
        let constraints: CGSize = {
            if let size = limitedSize, size != .zero {
                return size
            }
            return CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        }()
        let framesetter = CTFramesetterCreateWithAttributedString(att_string)
        let frame = CTFramesetterCreateFrame(framesetter, .init(location: 0, length: 0), .init(rect: .init(origin: .zero, size: constraints), transform: nil), nil)
        let lines = CTFrameGetLines(frame)
        let numberOfLines = CFArrayGetCount(lines)
        var maxWidth: Double = 0
        for index in 0..<numberOfLines {
            let line: CTLine = unsafeBitCast(CFArrayGetValueAtIndex(lines, index), to: CTLine.self)
            var ascent: CGFloat = 0
            var descent: CGFloat = 0
            var leading: CGFloat = 0
            let width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading)
            if(width > maxWidth) {
                maxWidth = width
            }
        }
        
        var ascent: CGFloat = 0
        var descent: CGFloat = 0
        var leading: CGFloat = 0
        
        CTLineGetTypographicBounds(unsafeBitCast(CFArrayGetValueAtIndex(lines, 0), to: CTLine.self), &ascent, &descent, &leading)
        let firstLineHeight = ascent + descent + leading
        
        CTLineGetTypographicBounds(unsafeBitCast(CFArrayGetValueAtIndex(lines, numberOfLines - 1), to: CTLine.self), &ascent, &descent, &leading)
        let lastLineHeight = ascent + descent + leading
        
        var firstLineOrigin: CGPoint = CGPoint(x: 0, y: 0)
        CTFrameGetLineOrigins(frame, CFRangeMake(0, 1), &firstLineOrigin);
        
        var lastLineOrigin: CGPoint = CGPoint(x: 0, y: 0)
        CTFrameGetLineOrigins(frame, CFRangeMake(numberOfLines - 1, 1), &lastLineOrigin);
        
        let textHeight = abs(firstLineOrigin.y - lastLineOrigin.y) + firstLineHeight + lastLineHeight
        
        return .init(width: ceil(maxWidth), height: ceil(textHeight))
         */
        
        /// 以下方法计算多行时返回的高度偶尔会小一些导致内容显示不全
        var range = CFRangeMake(0, att_string.length)
        let numberOfLines = max(limitedNumberOfLines, 0)
        let constraints: CGSize = {
            if let size = limitedSize, size != .zero {
                return size
            }
            return CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        }()
        
        let framesetter: CTFramesetter = {
            /// lineBreakMode 设置成 NSLineBreakByTruncatingTail | NSLineBreakByTruncatingHead | NSLineBreakByTruncatingMiddle
            /// 在计算高度的时候会被系统默认成单行，所以此处将 lineBreakMode 设置为 NSLineBreakByWordWrapping 才能正确计算实际高度。
            let m_att_string = att_string.mutableCopy() as! NSMutableAttributedString
            do {
                var range = NSRange(location: 0, length: m_att_string.length)
                let paragraphStyle: NSMutableParagraphStyle? = {
                    let attributes = m_att_string.attributes(at: 0, effectiveRange: &range)
                    if let style = attributes[NSAttributedString.Key.paragraphStyle] as? NSParagraphStyle {
                        return (style.mutableCopy() as! NSMutableParagraphStyle)
                    }
                    return nil
                }()
                if let style = paragraphStyle {
                    if limitedNumberOfLines == 1 {
                        /// 单行的情况下，如果刚好到限制的宽度时是一段很长的字母，
                        /// 其它的 lineBreakMode 会另起一行计算的，这就导致单行宽度不准确了，所以需要改为 byCharWrapping。
                        style.lineBreakMode = .byCharWrapping
                    } else {
                        style.lineBreakMode = .byWordWrapping
                    }
                    m_att_string.removeAttribute(NSAttributedString.Key.paragraphStyle, range: range)
                    m_att_string.addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: range)
                }
            }
            return CTFramesetterCreateWithAttributedString(m_att_string as CFAttributedString)
        }()
        
        let path: CGMutablePath = {
            let p = CGMutablePath()
            p.addRect(.init(x: 0.0, y: 0.0, width: constraints.width, height: CGFloat.greatestFiniteMagnitude))
            return p
        }()
        let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, nil)
        let lines = CTFrameGetLines(frame)
        if CFArrayGetCount(lines) > 0 {
            let lastVisibleLineIndex: CFIndex = {
                let linesCount = CFArrayGetCount(lines)
                if numberOfLines == 0 { // 不限制行数。
                    return (linesCount - 1)
                }
                return (min(CFIndex(numberOfLines), linesCount) - 1)
            }()
            let lastVisibleLine = CFArrayGetValueAtIndex(lines, lastVisibleLineIndex)
            let line: CTLine = unsafeBitCast(lastVisibleLine, to: CTLine.self)
            let rangeToLayout = CTLineGetStringRange(line)
            range = CFRangeMake(0, rangeToLayout.location + rangeToLayout.length)
        }
        
        var result = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, range, nil, constraints, nil)
        result.width = ceil(result.width)
        result.height = ceil(result.height)
        
        return result
    }
}

extension FSUIKitWrapper where Base: NSMutableAttributedString {
    
    /// 插入图片到指定的位置。
    ///
    /// - Parameters:
    ///   - image:          需要插入的图片
    ///   - index:          插入的位置
    ///   - size:           指定插入图片的 size，如果为 .zero 则默认使用图片的 size。
    ///   - spaces:         图片的左右间距。
    ///   - baselineOffset: 图片的 baseline 偏移量，可参考下面的计算方法。
    ///   - font:           用于辅助计算 baselineOffset 的字体，如果外部不想麻烦计算 baselineOffset 则可以传入一个参考字体让方法内部自动计算。
    ///
    /// - Note:
    ///   - 如果外部不想麻烦计算 baselineOffset 则可以传入一个 font 让方法内部自动计算。
    ///   - **只有当 baselineOffset 无效的时候(== 0.0) font 才会生效。**
    ///   - baselineOffset 计算方法: `font.descender * 0.9 - image.size.height / 2.0 + (font.descender + font.capHeight) + 2.0`。
    ///
    public func insert(image: UIImage?,
                       at index: Int,
                       size: CGSize = .zero,
                       spaces: FSAttachmentSpaces = .zero,
                       baselineOffset: CGFloat? = nil,
                       alignToFont font: UIFont? = nil) {
        
        guard let image = image, index >= 0, index < base.length else { return }
        
        func spaceAttr(width: CGFloat) -> NSAttributedString {
            let text: String = NSString(characters: [0xFFFC], length: 1) as String
            return NSAttributedString(string: text, attributes: [NSAttributedString.Key.kern: width])
        }
        
        var contentSize = size
        if contentSize == .zero {
            contentSize = image.size
        }
        
        let full_attr = NSMutableAttributedString()
        do {
            if spaces.left > 0.0 {
                full_attr.append(spaceAttr(width: spaces.left))
            }
        }
        do {
            var _baselineOffset: CGFloat = 0.0
            do {
                if let value = baselineOffset {
                    _baselineOffset = value
                } else if let font = font {
                    _baselineOffset = font.descender * 0.9 - image.size.height / 2.0 + (font.descender + font.capHeight) + 2.0
                }
            }
            
            let attachment = NSTextAttachment()
            attachment.image = image
            attachment.bounds = .init(origin: .init(x: 0.0, y: _baselineOffset), size: contentSize)
            
            let attr = NSMutableAttributedString(attachment: attachment)
            full_attr.append(attr)
        }
        do {
            if spaces.right > 0.0 {
                full_attr.append(spaceAttr(width: spaces.right))
            }
        }
        
        base.insert(full_attr, at: index)
    }
    
    func setLineSpacing(_ spacing: CGFloat, range: NSRange) {
        base.enumerateAttribute(.paragraphStyle, in: .init(location: 0, length: base.length), options: []) { (value, subRange, stop) in
            var style: NSMutableParagraphStyle?
            if let value = value as? NSParagraphStyle {
                if value is NSMutableParagraphStyle {
                    style = value as? NSMutableParagraphStyle
                } else {
                    style = value.mutableCopy() as? NSMutableParagraphStyle
                }
            } else {
                style = NSParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle
            }
            style?.lineSpacing = spacing
            if let style = style {
                base.addAttribute(.paragraphStyle, value: style, range: subRange)
            }
        }
    }
}

// MARK: - FSAttachmentSpaces

public struct FSAttachmentSpaces: Equatable {
    
    public static var zero: FSAttachmentSpaces {
        return .init()
    }
    
    public var left: CGFloat
    
    public var right: CGFloat
    
    // MARK: Initialization
    
    public init(left: CGFloat = 0.0, right: CGFloat = 0.0) {
        self.left = left
        self.right = right
    }
    
    // MARK: Equatable
    
    public static func == (lhs: FSAttachmentSpaces, rhs: FSAttachmentSpaces) -> Bool {
        return (lhs.left == rhs.left && lhs.right == rhs.right)
    }
}
