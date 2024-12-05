//
//  UIImage+FSUIKitSwift.swift
//  FSUIKitSwift
//
//  Created by Sheng on 2024/1/4.
//  Copyright © 2024 Sheng. All rights reserved.
//

import UIKit
import Foundation

// MARK: - FSUIImageTextDrawingStyle
public struct FSUIImageTextDrawingStyle {
    
    public enum VerticalAlignment {
        case top
        case center
        case bottom
    }
    
    public enum HorizontalAlignment {
        case left
        case center
        case right
    }
    
    public var text: String?
    public var font: UIFont?
    public var textColor: UIColor?
    public var lineSpacing: CGFloat = 0.0
    public var kernSpacing: CGFloat = 0.0
    public var numberOfLines: Int = 1
    public var size: CGSize = .zero
    /// 自动适配 text 的 size。
    /// 当该属性为 ture 时会忽略 size 属性。
    public var adjustsSize = false
    /// 该属性仅当 adjustsSize 为 ture 时才有效。
    /// 该属性表示的是 text 的最大 size，并非表示最后生成的 image 的 size。
    public var maximumSize: CGSize = .init(width: CGFloat(Int16.max), height: CGFloat(Int16.max))
    public var borderWidth: CGFloat = 0.0
    public var borderColor: UIColor?
    public var cornerRadius: CGFloat = 0.0
    public var roundingCorners: UIRectCorner = .allCorners
    public var backgroundColor: UIColor?
    /// 该属性仅当 adjustsSize 为 ture 时才有效。
    /// 该属性表示的是文本四边的内切间距。
    public var contentInset: UIEdgeInsets = .zero
    public var textAlignment: NSTextAlignment = .left
    public var verticalAlignment: FSUIImageTextDrawingStyle.VerticalAlignment = .top
    public var horizontalAlignment: FSUIImageTextDrawingStyle.HorizontalAlignment = .left
    
    public init() {}
}

// MARK: -
public extension FSUIKitWrapper where Base: UIImage {
    
    /// 生成二维码图片
    static func generateQRCode(_ urlStr: String, size: CGSize) -> UIImage? {
        let targetSize = size
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setDefaults()
        if let QRCodeFilter = filter, let data = urlStr.data(using: .utf8) {
            QRCodeFilter.setValue(data, forKey: "inputMessage")
            if let ciImage = QRCodeFilter.outputImage {
                let extent = ciImage.extent
                if let ciImageRef = CIContext.init().createCGImage(ciImage, from: extent) {
                    let sideScale = fmin(targetSize.width / extent.size.width, targetSize.width / extent.size.height) * UIScreen.main.scale
                    let width : size_t = size_t(ceilf(Float(sideScale) * Float(extent.width)))
                    let height : size_t = size_t(ceilf(Float(sideScale) * Float(extent.height)))
                    
                    //  CGColorSpaceCreateDeviceGray 灰度、CGImageAlphaInfo.none 不透明
                    if let contextRef = CGContext.init(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceGray(), bitmapInfo: CGImageAlphaInfo.none.rawValue) {
                        // 设置上下文无插值
                        contextRef.interpolationQuality = .none
                        // 上下文缩放 （ctm）
                        contextRef.scaleBy(x: sideScale, y: sideScale)
                        contextRef.draw(ciImageRef, in: extent)
                        if let resultCGImage = contextRef.makeImage() {
                            return UIImage.init(cgImage: resultCGImage, scale: UIScreen.main.scale, orientation: .up)
                        }
                    }
                }
            }
        }
        return nil
    }
    
    /// 从顶部裁剪图片
    func croppingFromTop() -> UIImage? {
        let width = min(self.base.size.width, self.base.size.height)
        if let imgRef = self.base.cgImage?.cropping(to: CGRect.init(origin: .zero, size: .init(width: width, height: width))) {
            return .init(cgImage: imgRef, scale: self.base.scale, orientation: self.base.imageOrientation)
        }
        return nil
    }
    
    /// 在 **MainBundle** 中以 `contentsOfFile` 的方式读取图片资源。
    static func contentsOfFile(named name: String) -> UIImage? {
        return self.image(named: name, in: Bundle.main)
    }
    
    /// 在指定的 bundle 下以 `contentsOfFile` 的方式读取图片资源。
    ///
    /// - Note: 该方法内部会自动根据当前设备的 scale 来获取对应分辨率的图片资源。
    ///
    static func image(named name: String, in bundle: Bundle) -> UIImage? {
        var imageName = name
        guard !imageName.isEmpty else {
            return nil
        }
        if imageName.hasSuffix("@2x") || imageName.hasSuffix("@3x") {
            let end   = imageName.index(imageName.startIndex, offsetBy: -3)
            imageName = String(imageName[..<end])
        }
        if imageName.isEmpty {
            return nil
        }
        
        let HDPngPath = bundle.path(forResource: "\(imageName)@3x", ofType: "png")
        let RPngPath  = bundle.path(forResource: "\(imageName)@2x", ofType: "png")
        let PngPath   = bundle.path(forResource: imageName, ofType: "png")
        let HDJpgPath = bundle.path(forResource: "\(imageName)@3x", ofType: "jpg")
        let RJpgPath  = bundle.path(forResource: "\(imageName)@2x", ofType: "jpg")
        let JpgPath   = bundle.path(forResource: imageName, ofType: "jpg")
        
        if UIScreen.main.scale > 2.0 {
            if let path = HDPngPath {
                return UIImage(contentsOfFile: path)
            }
            if let path = HDJpgPath {
                return UIImage(contentsOfFile: path)
            }
        } else if UIScreen.main.scale > 1.0 {
            if let path = RPngPath {
                return UIImage(contentsOfFile: path)
            }
            if let path = RJpgPath {
                return UIImage(contentsOfFile: path)
            }
        } else {
            if let path = PngPath {
                return UIImage(contentsOfFile: path)
            }
            if let path = JpgPath {
                return UIImage(contentsOfFile: path)
            }
        }
        
        // 不根据 `scale` 来获取图片资源，单纯为拿图片资源，找到有效路径初始化后直接返回。
        let paths: [String?] = [HDPngPath, RPngPath, PngPath, HDJpgPath, RJpgPath, JpgPath]
        for path in paths {
            if let path_ = path {
                return UIImage(contentsOfFile: path_)
            }
        }
        
        return nil
    }
    
    /// 绘制图片，主要的绘制工作在 actions 中。
    static func image(with size: CGSize, opaque: Bool, scale: CGFloat, actions: (_ context: CGContext) -> Void) -> UIImage? {
        guard size != .zero else {
            return nil
        }
        UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
        if let context = UIGraphicsGetCurrentContext() {
            actions(context)
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    /// 根据给定的颜色和生成一张图片，size 为 3x3，默认为四角拉伸。
    static func image(with color: UIColor) -> UIImage? {
        guard let image = image(with: color, size: .init(width: 3.0, height: 3.0)) else {
            return nil
        }
        let capInsets = UIEdgeInsets(top: 1.0, left: 1.0, bottom: 1.0, right: 1.0)
        return image.resizableImage(withCapInsets: capInsets, resizingMode: .stretch)
    }
    
    static func image(with color: UIColor,
                      size: CGSize,
                      alpha: Float = 1.0,
                      cornerRadius: CGFloat = 0,
                      borderWidth: CGFloat = 0,
                      borderColor: UIColor? = nil) -> UIImage? {
        guard size != .zero else {
            return nil
        }
        let format = UIGraphicsImageRendererFormat()
        format.opaque = false
        format.scale = UIScreen.fs.scale
        return UIGraphicsImageRenderer(size: size, format: format).image { context in
            let layer = CAShapeLayer()
            layer.frame = .init(origin: .zero, size: size)
            layer.opacity = max(0.0, min(1.0, alpha))
            layer.borderWidth = borderWidth
            layer.borderColor = borderColor?.cgColor
            layer.cornerRadius = cornerRadius
            layer.backgroundColor = color.cgColor
            layer.render(in: context.cgContext)
        }
    }
    
    /// 以当前 UIImage 为蓝本，创建一个带透明度的新 UIImage。
    func with(alpha: CGFloat) -> UIImage? {
        return UIImage.fs.image(with: base.size, opaque: false, scale: base.scale) { _ in
            let rect = CGRect(origin: .zero, size: base.size)
            base.draw(in: rect, blendMode: .normal, alpha: max(0.0, min(1.0, alpha)))
        }
    }
    
    /// 将当前图片改变颜色并返回一张新的图片。
    func redraw(with color: UIColor) -> UIImage? {
        let bounds = CGRect(origin: .zero, size: base.size)
        UIGraphicsBeginImageContextWithOptions(base.size, false, base.scale)
        guard let context = UIGraphicsGetCurrentContext(), let cg_image = base.cgImage else {
            return nil
        }
        context.translateBy(x: 0.0, y: base.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.setBlendMode(.normal)
        context.clip(to: bounds, mask: cg_image)
        context.setFillColor(color.cgColor)
        context.fill(bounds)
        let imageOut = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return imageOut
    }
    
    /// Flips the current image horizontally.
    func flippingHorizontally() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(base.size, false, base.scale)
        let context = UIGraphicsGetCurrentContext()!
        context.translateBy(x: base.size.width/2, y: base.size.height/2)
        context.scaleBy(x: -1.0, y: 1.0)
        context.translateBy(x: -base.size.width/2, y: -base.size.height/2)
        
        base.draw(in: CGRect(x: 0, y: 0, width: base.size.width, height: base.size.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    /// 画文本。
    static func drawText(with style: FSUIImageTextDrawingStyle) -> UIImage {
        
        var size = style.size
        
        if size == .zero, !style.adjustsSize {
            return UIImage()
        }
        
        let attributes: [NSAttributedString.Key: Any] = {
            let font = style.font ?? .systemFont(ofSize: 16.0)
            let textColor = style.textColor ?? .black
            let paragraphStyle = NSMutableParagraphStyle()
            do {
                paragraphStyle.alignment = style.textAlignment
                paragraphStyle.lineSpacing = style.lineSpacing
            }
            return [
                .font: font,
                .kern: style.kernSpacing,
                .paragraphStyle: paragraphStyle,
                .foregroundColor: textColor
            ]
        }()
        let textSize: CGSize = {
            let limitedSize: CGSize = {
                if style.adjustsSize {
                    return style.maximumSize
                }
                let x = style.borderWidth + style.contentInset.left
                let y = style.borderWidth + style.contentInset.top
                let w = size.width - style.contentInset.right - x
                let h = size.height - style.contentInset.bottom - y
                return .init(width: w, height: h)
            }()
            let attr_text = NSAttributedString(string: style.text ?? "", attributes: attributes)
            let size = attr_text.fs.size(limitedSize: limitedSize, limitedNumberOfLines: style.numberOfLines)
            return size
        }()
        
        if style.adjustsSize {
            size.width = textSize.width + style.borderWidth * 2 + style.contentInset.fs.horizontalValue()
            size.height = textSize.height + style.borderWidth * 2 + style.contentInset.fs.verticalValue()
        }
        
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            do {
                let borderWidth = style.borderWidth
                let cornerRadii = CGSize(width: style.cornerRadius, height: style.cornerRadius)
                let rect: CGRect = {
                    let x = borderWidth
                    let y = borderWidth
                    let w = size.width - x * 2.0
                    let h = size.height - y * 2.0
                    return CGRect(x: x, y: y, width: w, height: h)
                }()
                
                let ctx = ctx.cgContext
                do {
                    ctx.saveGState()
                    ctx.setLineWidth(borderWidth)
                }
                if let color = style.backgroundColor {
                    let clipPath: CGPath = UIBezierPath(roundedRect: rect,
                                                        byRoundingCorners: style.roundingCorners,
                                                        cornerRadii: cornerRadii).cgPath
                    ctx.addPath(clipPath)
                    ctx.setFillColor(color.cgColor)
                    ctx.closePath()
                    ctx.fillPath()
                }
                if borderWidth > 0.0 {
                    let linePath: CGPath = UIBezierPath(roundedRect: rect,
                                                        byRoundingCorners: style.roundingCorners,
                                                        cornerRadii: cornerRadii).cgPath
                    ctx.addPath(linePath)
                    ctx.setStrokeColor((style.borderColor ?? .clear).cgColor)
                    ctx.strokePath()
                }
                ctx.restoreGState()
            }
            if let text = style.text {
                let textRect: CGRect = {
                    let x: CGFloat, y: CGFloat
                    do {
                        switch style.verticalAlignment {
                        case .top:
                            y = style.borderWidth + style.contentInset.top
                        case .center:
                            y = (size.height - textSize.height) / 2.0
                        case .bottom:
                            y = size.height - style.contentInset.bottom - textSize.height
                        }
                    }
                    do {
                        switch style.horizontalAlignment {
                        case .left:
                            x = style.borderWidth + style.contentInset.left
                        case .center:
                            x = (size.width - textSize.width) / 2.0
                        case .right:
                            x = size.width - style.contentInset.right - textSize.width
                        }
                    }
                    return .init(origin: .init(x: x, y: y), size: textSize)
                }()
                text.draw(with: textRect, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
            }
        }
        return image
    }
}
