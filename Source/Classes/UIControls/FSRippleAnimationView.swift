//
//  FSRippleAnimationView.swift
//  FSUIKitSwift
//
//  Created by VincentLee on 2024/6/15.
//

import UIKit

open class FSRippleAnimationView: UIView {
    
    // MARK: Properties/Open
    
    /// 动画停止后自动隐藏，默认为 true。
    open var hidesWhenStopped: Bool = true {
        didSet {
            isHidden = !isAnimating && hidesWhenStopped
        }
    }
    
    /// 波纹颜色
    open var rippleColor: UIColor = .red {
        didSet {
            p_startAnimatingIfNeeded()
        }
    }
    
    /// 是否自动开始动画，默认为 true。
    open var autostartsAnimating: Bool = true
    
    /// 当前是否正在执行动画。
    open private(set) var isAnimating: Bool = false
    
    // MARK: Properties/Private
    
    private let rippleAnimationLayer = CALayer()
    
    private var viewSize = CGSize.zero
    
    private var isStartingAnimation = false
    private var isStoppingAnimation = false
    
    // MARK: Deinitialization
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Initialization
    
    public override init(frame: CGRect) {
        var frame = frame
        if frame.size == .zero {
            frame.size = .init(width: 100.0, height: 100.0)
        }
        super.init(frame: frame)
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

extension FSRippleAnimationView {
    
    public override var isHidden: Bool {
        didSet {
            guard !isStartingAnimation, !isStoppingAnimation else {
                return
            }
            if isHidden {
                p_stopAnimating()
            } else if !isAnimating, autostartsAnimating, rippleAnimationLayer.frame != .zero {
                p_startAnimating()
            }
        }
    }
    
    public override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        if let _ = newWindow {
            p_startAnimatingIfNeeded()
        }
    }
    
    public override func didMoveToWindow() {
        super.didMoveToWindow()
        if window == nil {
            p_stopAnimating()
        }
    }
    
    public override var intrinsicContentSize: CGSize {
        return frame.size
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        if viewSize != frame.size {
            viewSize = frame.size
            rippleAnimationLayer.frame = .init(origin: .zero, size: viewSize)
            p_startAnimatingIfNeeded()
        }
    }
}

// MARK: - Private

private extension FSRippleAnimationView {
    
    /// Invoked after initialization.
    func p_didInitialize() {
        layer.addSublayer(rippleAnimationLayer)
        NotificationCenter.default.addObserver(self, selector: #selector(p_receive(notification:)), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    func p_startAnimatingIfNeeded() {
        guard
            rippleAnimationLayer.frame != .zero,
            autostartsAnimating
        else {
            return
        }
        p_startAnimating()
    }
    
    func p_startAnimating() {
        
        isStartingAnimation = true
        defer {
            isStartingAnimation = false
        }
        
        p_stopAnimating()
        
        isAnimating = true
        defer {
            isHidden = false
        }
        
        let rect = CGRect(origin: .zero, size: rippleAnimationLayer.frame.size)
        let duration: TimeInterval = 3.0
        let initialPath = UIBezierPath(ovalIn: .init(x: rect.midX - 2.0, y: rect.midY - 2.0, width: 4.0, height: 4.0))
        let finalPath = UIBezierPath(ovalIn: rect)
        
        let replicatorLayer = CAReplicatorLayer()
        replicatorLayer.instanceCount = 5
        replicatorLayer.instanceDelay = duration / CGFloat(replicatorLayer.instanceCount)
        replicatorLayer.backgroundColor = UIColor.clear.cgColor
        rippleAnimationLayer.addSublayer(replicatorLayer)
        
        let layer = CAShapeLayer()
        layer.path = initialPath.cgPath
        layer.frame = rect
        layer.fillColor = rippleColor.cgColor
        replicatorLayer.addSublayer(layer)
        
        let pathAnimation = CABasicAnimation(keyPath: "path")
        pathAnimation.fromValue = initialPath.cgPath
        pathAnimation.toValue = finalPath.cgPath
        
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 1.0
        opacityAnimation.toValue = 0.0
        
        let groupAnimation = CAAnimationGroup()
        groupAnimation.duration = duration
        groupAnimation.animations = [pathAnimation, opacityAnimation]
        groupAnimation.repeatCount = Float.greatestFiniteMagnitude
        groupAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        
        layer.add(groupAnimation, forKey: nil)
    }
    
    func p_stopAnimating() {
        isStoppingAnimation = true
        defer {
            isStoppingAnimation = false
        }
        if let layers = rippleAnimationLayer.sublayers?.filter({ $0 is CAReplicatorLayer }), !layers.isEmpty {
            layers.forEach { $0.removeFromSuperlayer() }
        }
        isAnimating = false
        if hidesWhenStopped {
            isHidden = true
        }
    }
    
    @objc
    func p_receive(notification: Notification) {
        if notification.name == UIApplication.willEnterForegroundNotification {
            p_startAnimatingIfNeeded()
        }
    }
}
