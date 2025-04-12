//
//  GradientImageRenderer.swift
//  FSUIKitSwift
//
//  Created by VincentLee on 2025/4/12.
//  Copyright © 2025 VincentLee. All rights reserved.
//

import UIKit
import CoreGraphics

public final class GradientImageRenderer {
    
    public enum Direction {
        
        case topToBottom
        case leftToRight
        case topLeftToBottomRight
        case bottomLeftToTopRight
        case custom(start: CGPoint, end: CGPoint)
        
        fileprivate var points: (start: CGPoint, end: CGPoint) {
            switch self {
            case .topToBottom:
                return (CGPoint(x: 0.5, y: 0), CGPoint(x: 0.5, y: 1))
            case .leftToRight:
                return (CGPoint(x: 0, y: 0.5), CGPoint(x: 1, y: 0.5))
            case .topLeftToBottomRight:
                return (CGPoint(x: 0, y: 0), CGPoint(x: 1, y: 1))
            case .bottomLeftToTopRight:
                return (CGPoint(x: 0, y: 1), CGPoint(x: 1, y: 0))
            case .custom(let start, let end):
                return (start, end)
            }
        }
    }
    
    public struct Configuration {
        public var size: CGSize = .zero
        public var colors: [UIColor] = []
        public var locations: [CGFloat]?
        public var direction: Direction = .leftToRight
        public var cornerRadius: CGFloat = 0
        public init() {}
        public init(
            size: CGSize,
            colors: [UIColor],
            locations: [CGFloat]?,
            direction: Direction = .leftToRight,
            cornerRadius: CGFloat
        ) {
            self.size = size
            self.colors = colors
            self.locations = locations
            self.direction = direction
            self.cornerRadius = cornerRadius
        }
    }
    
    public static func render(_ config: Configuration) -> UIImage? {
        
        let scale = UIScreen.main.scale
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
        
        guard let context = CGContext(
            data: nil,
            width: Int(config.size.width * scale),
            height: Int(config.size.height * scale),
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else {
            return nil
        }
        
        context.scaleBy(x: scale, y: scale)
        context.setAllowsAntialiasing(true)
        context.setShouldAntialias(true)
        
        if config.cornerRadius > 0 {
            let path = UIBezierPath(
                roundedRect: CGRect(origin: .zero, size: config.size),
                cornerRadius: config.cornerRadius
            ).cgPath
            context.addPath(path)
            context.clip()
        }
        
        let cgColors = config.colors.map { $0.cgColor } as CFArray
        var locations = config.locations
        if locations == nil {
            let step = 1.0 / CGFloat(config.colors.count - 1)
            locations = (0..<config.colors.count).map { CGFloat($0) * step }
        }
        
        guard let gradient = CGGradient(colorsSpace: colorSpace, colors: cgColors, locations: locations) else {
            return nil
        }
        
        let (start, end) = config.direction.points
        let from = CGPoint(x: start.x * config.size.width, y: start.y * config.size.height)
        let to = CGPoint(x: end.x * config.size.width, y: end.y * config.size.height)
        
        context.drawLinearGradient(gradient, start: from, end: to, options: [])
        
        guard let cgImage = context.makeImage() else {
            return nil
        }
        return UIImage(cgImage: cgImage, scale: scale, orientation: .up)
    }
    
    public static func renderAsync(_ config: Configuration, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let image = render(config)
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
}
