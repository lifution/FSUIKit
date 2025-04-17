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
        let format = UIGraphicsImageRendererFormat()
        format.scale = UIScreen.main.scale
        format.opaque = false
        let size = config.size
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { context in
            let ctx = context.cgContext
            ctx.setAllowsAntialiasing(true)
            ctx.setShouldAntialias(true)
            
            // 使用手动构造的 capsule 路径
            let path: UIBezierPath
            if config.cornerRadius >= size.height/2 {
                path = capsulePath(size: size)
            } else {
                path = UIBezierPath(roundedRect: CGRect(origin: .zero, size: size),
                                    cornerRadius: config.cornerRadius)
            }
            
            ctx.saveGState()
            path.addClip()
            
            // 构造渐变
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let cgColors = config.colors.map { $0.cgColor } as CFArray
            var locations = config.locations
            if locations == nil {
                let step = 1.0 / CGFloat(config.colors.count - 1)
                locations = (0..<config.colors.count).map { CGFloat($0) * step }
            }
            
            guard let gradient = CGGradient(colorsSpace: colorSpace, colors: cgColors, locations: locations) else {
                return
            }
            
            let (start, end) = config.direction.points
            let from = CGPoint(x: start.x * size.width, y: start.y * size.height)
            let to = CGPoint(x: end.x * size.width, y: end.y * size.height)
            
            ctx.drawLinearGradient(gradient, start: from, end: to, options: [])
            ctx.restoreGState()
        }
    }
    
    public static func renderAsync(_ config: Configuration, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let image = render(config)
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
    
    private static func capsulePath(size: CGSize) -> UIBezierPath {
        let width = size.width
        let height = size.height
        let radius = height/2
        
        let centerLeft = CGPoint(x: radius, y: radius)
        let centerRight = CGPoint(x: width - radius, y: radius)
        
        let path = UIBezierPath()
        path.move(to: .init(x: radius, y: height))
        path.addArc(withCenter: centerLeft, radius: radius, startAngle: .pi/2, endAngle: .pi * 1.5, clockwise: true)
        path.addLine(to: CGPoint(x: width - radius, y: 0.0))
        path.addArc(withCenter: centerRight, radius: radius, startAngle: .pi * 1.5, endAngle: .pi/2, clockwise: true)
        path.close()
        
        return path
    }
}
