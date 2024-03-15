//
//  FSCornerRoundingView.swift
//  FSUIKit
//
//  Created by Sheng on 2024/3/13.
//

import UIKit

/// 可设置圆角的控件。
///
/// - 该控件并非适合所有使用场景，开发者应根据实际使用场景判断是否该使用该控件。
/// - 该控件设置的圆角只是视觉上达到了圆角的效果，但其实只是覆盖了一层 layer 在顶层而已。
/// - 选择这种方式设置圆角是为了避免离屏渲染，从而提升信息流列表的滑动性能。
/// - ⚠️ 当 cornerColor 更改时，FSCornerRoundingView 内部会通过设置 layer.mask 临时实现
///   一个真实的圆角，然后在 cornerColor 设置完成后会再移除 layer.mask，因此**建议外部不要
///   设置 layer.mask**，同时不建议外部短时间内频繁修改圆角。
///
open class FSCornerRoundingView: UIView {
    
    // MARK: Properties/Public
    
    /// 圆角颜色。
    ///
    /// - 当前控件设置的圆角只是视觉上达到了圆角的效果，但其实只是覆盖了一层 layer 在顶层而已，
    ///   因此，此处的圆角颜色应该与当前控件所在的背景颜色一致，以此达到视觉上的圆角效果。
    ///
    public var cornerColor: UIColor? {
        didSet {
            p_updateCornerColor()
            p_setNeedsCornerUpdate()
        }
    }
    
    /// 圆角半径。
    public var cornerRadius: CGFloat = 0.0 {
        didSet {
            if cornerRadius != oldValue {
                p_setNeedsCornerUpdate()
            }
        }
    }
    
    /// 圆角类型。
    public var corners: UIRectCorner = .allCorners {
        didSet {
            if corners != oldValue {
                p_setNeedsCornerUpdate()
            }
        }
    }
    
    /// 边框颜色。
    public var borderColor: UIColor? {
        didSet {
            p_updateBorderColor()
            p_setNeedsCornerUpdate()
        }
    }
    
    /// 边框宽度。
    public var borderWidth: CGFloat = 0.0 {
        didSet {
            borderLayer.lineWidth = borderWidth
            p_setNeedsCornerUpdate()
        }
    }
    
    // MARK: Properties/Private
    
    private let cornerLayer = CAShapeLayer()
    private let borderLayer = CAShapeLayer()
    
    private var viewSize = CGSize.zero
    private var needsUpdateCorner = false
    
    // MARK: Initialization
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        p_didInitialize()
    }
    
    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Open
    
    /// 初始化后会调用该方法，subclass 可重载该方法做一些初始化后的相关操作。
    @objc open dynamic func didInitialize() {
        
    }
    
    /// 系统 dark mode 更改时会回调该方法。
    /// FSCornerRoundingView 内部已做了 iOS17 API 的适配，iOS17 后使用新 API，
    /// iOS17 之前使用旧 API，因此 subclass 只需要重载该方法做 dark mode 的适配即可。
    @objc open dynamic func userInterfaceDidChange() {
        
    }
}

// MARK: Override

extension FSCornerRoundingView {
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #unavailable(iOS 17) {
            p_userInterfaceDidChange()
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        defer {
            p_updateCornerIfNeeded()
        }
        if viewSize != bounds.size {
            viewSize = bounds.size
            needsUpdateCorner = true
        }
    }
}

// MARK: - Private

private extension FSCornerRoundingView {
    
    func p_didInitialize() {
        defer {
            p_updateCornerColor()
            p_setNeedsCornerUpdate()
            didInitialize()
        }
        
        if #available(iOS 17, *) {
            registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (self: Self, previousTraitCollection: UITraitCollection) in
                self.p_userInterfaceDidChange()
            }
        }
        
        cornerLayer.fillRule = .evenOdd
        cornerLayer.zPosition = CGFloat(Int32.max-1)
        layer.addSublayer(cornerLayer)
        
        borderLayer.fillRule = .evenOdd
        borderLayer.zPosition = CGFloat(Int32.max)
        borderLayer.lineWidth = 0.0
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = nil
        layer.addSublayer(borderLayer)
    }
    
    func p_userInterfaceDidChange() {
        defer {
            userInterfaceDidChange()
        }
        p_updateCornerColor()
        p_updateBorderColor()
    }
    
    func p_updateCornerColor() {
        // 因为 CAShapeLayer 在更改 fillColor 时会有一个动画渐变的过程，因此此处
        // 先设置一个 mask 设置真实的圆角裁剪操作，等 fillColor 更改后再移除 mask。
        if viewSize.width > 0.0, viewSize.height > 0.0 {
            self.layer.mask = {
                let rect = CGRect(origin: .zero, size: viewSize)
                let cornerRadii = CGSize(width: cornerRadius, height: cornerRadius)
                let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: cornerRadii)
                let mask = CAShapeLayer()
                mask.path = path.cgPath
                return mask
            }()
        }
        cornerLayer.fillColor = cornerColor?.cgColor
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.layer.mask = nil
        }
    }
    
    func p_updateBorderColor() {
        borderLayer.strokeColor = borderColor?.cgColor
    }
    
    func p_setNeedsCornerUpdate() {
        needsUpdateCorner = true
        setNeedsLayout()
    }
    
    func p_updateCornerIfNeeded() {
        if needsUpdateCorner {
            p_updateCorner()
        }
    }
    
    func p_updateCorner() {
        needsUpdateCorner = false
        do {
            if cornerRadius <= 0.0 {
                cornerLayer.isHidden = true
            } else {
                cornerLayer.isHidden = false
            }
            if cornerColor == nil {
                cornerLayer.isHidden = true
            }
            if !cornerLayer.isHidden {
                let rect = CGRect(origin: .zero, size: viewSize)
                let path = UIBezierPath(rect: rect)
                let cornerRadii = CGSize(width: cornerRadius, height: cornerRadius)
                let cornerPath = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: cornerRadii)
                path.append(cornerPath)
                cornerLayer.path = path.cgPath
            }
        }
        do {
            if borderWidth <= 0.0 {
                borderLayer.isHidden = true
            } else {
                borderLayer.isHidden = false
            }
            if borderColor == nil {
                borderLayer.isHidden = true
            }
            if !borderLayer.isHidden {
                let inset = borderWidth / 2
                let rect = CGRect(origin: .zero, size: viewSize).insetBy(dx: inset, dy: inset)
                let cornerRadii = CGSize(width: cornerRadius - inset, height: cornerRadius - inset)
                let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: cornerRadii)
                borderLayer.path = path.cgPath
            }
        }
    }
}
