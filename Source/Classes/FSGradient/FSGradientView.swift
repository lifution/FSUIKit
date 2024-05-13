//
//  FSGradientView.swift
//  FSUIKitSwift
//
//  Created by Sheng on 2023/11/4.
//  Copyright (c) 2023 Sheng. All rights reserved.
//

import UIKit

open class FSGradientView: UIView {
    
    // MARK: Properties/Open
    
    /* The array of UIColor objects defining the color of each gradient
     * stop. Defaults to nil. Animatable. */
    open var colors: [UIColor]? {
        get {
            guard let cgColors = gradientLayer.colors as? [CGColor] else {
                return nil
            }
            return cgColors.compactMap { UIColor(cgColor: $0) }
        }
        set { gradientLayer.colors = newValue?.compactMap { $0.cgColor } }
    }
    
    /* An optional array of NSNumber objects defining the location of each
     * gradient stop as a value in the range [0,1]. The values must be
     * monotonically increasing. If a nil array is given, the stops are
     * assumed to spread uniformly across the [0,1] range. When rendered,
     * the colors are mapped to the output colorspace before being
     * interpolated. Defaults to nil. Animatable. */
    open var locations: [NSNumber]? {
        get { return gradientLayer.locations }
        set { gradientLayer.locations = newValue }
    }
    
    /* The start and end points of the gradient when drawn into the layer's
     * coordinate space. The start point corresponds to the first gradient
     * stop, the end point to the last gradient stop. Both points are
     * defined in a unit coordinate space that is then mapped to the
     * layer's bounds rectangle when drawn. (I.e. [0,0] is the bottom-left
     * corner of the layer, [1,1] is the top-right corner.) The default values
     * are [.5,0] and [.5,1] respectively. Both are animatable. */
    
    open var startPoint: CGPoint {
        get { return gradientLayer.startPoint }
        set { gradientLayer.startPoint = newValue }
    }
    
    open var endPoint: CGPoint {
        get { return gradientLayer.endPoint }
        set { gradientLayer.endPoint = newValue }
    }
    
    /* The kind of gradient that will be drawn. Currently, the only allowed
     * values are `axial' (the default value), `radial', and `conic'. */
    open var gradientType: CAGradientLayerType  {
        get { return gradientLayer.type }
        set { gradientLayer.type = newValue }
    }
    
    // MARK: Properties/Override
    
    open override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    // MARK: Properties/Private
    
    private var gradientLayer: CAGradientLayer {
        guard let layer = self.layer as? CAGradientLayer else {
            fatalError("The property `layerClass` must be CAGradientLayer.")
        }
        return layer
    }
    
    // MARK: Initialization
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
