//
//  FSMaterialSpinnerView.swift
//  FSUIKitSwift
//
//  Created by Sheng on 2024/5/20.
//

import UIKit

/// 类似于 Google 设计的 loading 动画。
/// 该控件核心代码翻译自: [MMMaterialDesignSpinner](https://github.com/misterwell/MMMaterialDesignSpinner)
///
/// - Note: 动画圆圈的大小与视图的 size 相关，如果需要扩大动画圆圈的半径，只需要扩大视图的 size 即可。
///
open class FSMaterialSpinnerView: UIView {
    
    // MARK: Properties/Open
    
    /// 动画停止后自动隐藏，默认为 true。
    open var hidesWhenStopped: Bool = true {
        didSet {
            isHidden = !isAnimating && hidesWhenStopped
        }
    }
    
    /// 线条颜色。
    open var lineColor: UIColor = .lightGray {
        didSet {
            progressLayer.strokeColor = lineColor.cgColor
        }
    }
    
    /// 线条宽度。
    open var lineWidth: CGFloat = 2.0 {
        didSet {
            guard lineWidth != oldValue else {
                return
            }
            progressLayer.lineWidth = lineWidth
            p_updatePath()
        }
    }
    
    /// 线条断口封边类型，默认为 round。
    open var lineCap: CAShapeLayerLineCap = .round {
        didSet {
            guard lineCap != oldValue else {
                return
            }
            progressLayer.lineCap = lineCap
        }
    }
    
    /// 动画时间分布类型，默认为 easeInEaseOut。
    open var timingFunction: CAMediaTimingFunction = .init(name: .easeInEaseOut)
    
    /// 一圈动画的时长。
    ///
    /// - Note: 应该在 `startAnimating()` 方法之前设置该参数，否则无效。
    ///
    open var duration: TimeInterval = 1.5
    
    /// 是否自动开始动画，默认为 true。
    open var autostartsAnimating: Bool = true
    
    /// 当前是否正在执行动画。
    open private(set) var isAnimating: Bool = false
    
    // MARK: Properties/Private
    
    private lazy var progressLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.lineCap     = lineCap
        layer.lineWidth   = lineWidth
        layer.fillColor   = nil
        layer.strokeColor = lineColor.cgColor
        layer.strokeStart = 0.0
        layer.strokeEnd   = 1.0
        return layer
    }()
    
    // MARK: Initialization
    
    override public init(frame: CGRect) {
        var f = frame
        if f.size == .zero {
            f.size = Consts.size
        }
        super.init(frame: f)
        p_didInitialize()
    }
    
    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Open
    
    /// 开始动画。
    open func startAnimating() {
        p_startAnimating()
    }
    
    /// 停止动画。
    open func stopAnimating() {
        p_stopAnimating()
    }
}

// MARK: - Override

extension FSMaterialSpinnerView {
    
    public override var isHidden: Bool {
        didSet {
            if isHidden {
                stopAnimating()
            } else if !isAnimating, autostartsAnimating {
                startAnimating()
            }
        }
    }
    
    public override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        if let _ = newWindow {
            if autostartsAnimating {
                startAnimating()
            }
        }
    }
    
    public override func didMoveToWindow() {
        super.didMoveToWindow()
        if window == nil {
            stopAnimating()
        }
    }
    
    public override var intrinsicContentSize: CGSize {
        return bounds.size
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        progressLayer.frame = .init(origin: .zero, size: bounds.size)
        p_updatePath()
        invalidateIntrinsicContentSize()
    }
}

// MARK: - Private

private extension FSMaterialSpinnerView {
    
    /// Invoked after initialization.
    func p_didInitialize() {
        isHidden = true
        layer.addSublayer(progressLayer)
        invalidateIntrinsicContentSize()
    }
    
    func p_updatePath() {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width / 2, bounds.height / 2) - lineWidth / 2
        let startAngle: CGFloat = 0.0
        let endAngle: CGFloat = CGFloat.pi * 2
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        progressLayer.path = path.cgPath
    }
    
    func p_startAnimating() {
        guard !isAnimating else {
            return
        }
        isAnimating = true
        defer {
            isHidden = false
        }
        do {
            // rotation
            let animation = CABasicAnimation(keyPath: "transform.rotation")
            animation.duration  = duration / 0.375
            animation.fromValue = 0.0
            animation.toValue   = CGFloat.pi * 2
            animation.repeatCount = HUGE
            animation.isRemovedOnCompletion = false
            progressLayer.add(animation, forKey: AnimationKey.Rotation)
        }
        do {
            // stroke
            let headAnimation = CABasicAnimation(keyPath: "strokeStart")
            headAnimation.duration  = duration / 1.5
            headAnimation.fromValue = 0.0
            headAnimation.toValue   = 0.25
            headAnimation.timingFunction = timingFunction
            
            let tailAnimation = CABasicAnimation(keyPath: "strokeEnd")
            tailAnimation.duration  = duration / 1.5
            tailAnimation.fromValue = 0.0
            tailAnimation.toValue   = 1.0
            tailAnimation.timingFunction = timingFunction
            
            let endHeadAnimation = CABasicAnimation(keyPath: "strokeStart")
            endHeadAnimation.beginTime = duration / 1.5
            endHeadAnimation.duration  = duration / 3.0
            endHeadAnimation.fromValue = 0.25
            endHeadAnimation.toValue   = 1.0
            endHeadAnimation.timingFunction = timingFunction
            
            let endTailAnimation = CABasicAnimation(keyPath: "strokeEnd")
            endTailAnimation.beginTime = duration / 1.5
            endTailAnimation.duration  = duration / 3.0
            endTailAnimation.fromValue = 1.0
            endTailAnimation.toValue   = 1.0
            endTailAnimation.timingFunction = timingFunction
            
            let animations = CAAnimationGroup()
            animations.duration = duration
            animations.animations = [headAnimation, tailAnimation, endHeadAnimation, endTailAnimation]
            animations.repeatCount = HUGE
            animations.isRemovedOnCompletion = false
            progressLayer.add(animations, forKey: AnimationKey.Stroke)
        }
    }
    
    func p_stopAnimating() {
        guard isAnimating else {
            return
        }
        progressLayer.removeAllAnimations()
        isAnimating = false
        if hidesWhenStopped {
            isHidden = true
        }
    }
}

// MARK: - Consts

private struct AnimationKey {
    static let Rotation = "com.fsuikit.animation.materialSpinner.rotation"
    static let Stroke = "com.fsuikit.animation.materialSpinner.stroke"
}

private struct Consts {
    static let size: CGSize = .init(width: 28.0, height: 28.0)
}
