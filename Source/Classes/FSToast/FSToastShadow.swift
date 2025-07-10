//
//  FSToastShadow.swift
//  FSUIKitSwift
//
//  Created by VincentLee on 2025/7/10.
//  Copyright © 2025 VincentLee. All rights reserved.
//

import Foundation

public struct FSToastShadow {
    
    public var color: UIColor?
    public var opacity: Float = 0.0
    public var offset: CGSize = .zero
    public var radius: CGFloat = 0.0
    public var path: UIBezierPath?
    
    public init() {}
}
