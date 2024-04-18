//
//  FSGradientLabel.swift
//  FSUIKitSwift
//
//  Created by Sheng on 2023/11/4.
//  Copyright (c) 2023 Sheng. All rights reserved.
//

import UIKit

open class FSGradientLabel: UIView {
    
    // MARK: Properties/Open
    
    open var text: String? {
        get { return textLabel.text }
        set {
            textLabel.text = newValue
            textLabel.sizeToFit()
            invalidateIntrinsicContentSize()
            setNeedsUpdateConstraints()
        }
    }
    
    open var font: UIFont? {
        get { return textLabel.font }
        set {
            textLabel.font = newValue ?? .systemFont(ofSize: 17.0)
            textLabel.sizeToFit()
            invalidateIntrinsicContentSize()
            setNeedsUpdateConstraints()
        }
    }
    
    /* The array of UIColor objects defining the color of each gradient
     * stop. Defaults to nil. Animatable. */
    open var colors: [UIColor]? {
        get { return gradientView.colors }
        set { gradientView.colors = newValue }
    }
    
    /* An optional array of NSNumber objects defining the location of each
     * gradient stop as a value in the range [0,1]. The values must be
     * monotonically increasing. If a nil array is given, the stops are
     * assumed to spread uniformly across the [0,1] range. When rendered,
     * the colors are mapped to the output colorspace before being
     * interpolated. Defaults to nil. Animatable. */
    open var locations: [NSNumber]? {
        get { return gradientView.locations }
        set { gradientView.locations = newValue }
    }
    
    /* The start and end points of the gradient when drawn into the layer's
     * coordinate space. The start point corresponds to the first gradient
     * stop, the end point to the last gradient stop. Both points are
     * defined in a unit coordinate space that is then mapped to the
     * layer's bounds rectangle when drawn. (I.e. [0,0] is the bottom-left
     * corner of the layer, [1,1] is the top-right corner.) The default values
     * are [.5,0] and [.5,1] respectively. Both are animatable. */
    
    open var startPoint: CGPoint {
        get { return gradientView.startPoint }
        set { gradientView.startPoint = newValue }
    }
    
    open var endPoint: CGPoint {
        get { return gradientView.endPoint }
        set { gradientView.endPoint = newValue }
    }
    
    /* The kind of gradient that will be drawn. Currently, the only allowed
     * values are `axial' (the default value), `radial', and `conic'. */
    open var gradientType: CAGradientLayerType  {
        get { return gradientView.gradientType }
        set { gradientView.gradientType = newValue }
    }
    
    // MARK: Properties/Private
    
    private let textLabel = UILabel()
    
    private let gradientView = FSGradientView()
    
    // MARK: Initialization
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        p_didInitialize()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        p_didInitialize()
    }
    
    // MARK: Override
    
    open override func sizeToFit() {
        var frame = self.frame
        frame.size = sizeThatFits(.init(width: CGFloat.greatestFiniteMagnitude,
                                        height: CGFloat.greatestFiniteMagnitude))
        self.frame = frame
    }
    
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        return textLabel.sizeThatFits(size)
    }
    
    open override var intrinsicContentSize: CGSize {
        return textLabel.intrinsicContentSize
    }
}

// MARK: - Private

private extension FSGradientLabel {
    
    /// Invoked after initialization.
    func p_didInitialize() {
        gradientView.mask = textLabel
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(gradientView)
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[gradientView]|",
                                                      metrics: nil,
                                                      views: ["gradientView": gradientView]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[gradientView]|",
                                                      metrics: nil,
                                                      views: ["gradientView": gradientView]))
    }
}
