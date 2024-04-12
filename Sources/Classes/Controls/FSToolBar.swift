//
//  FSToolBar.swift
//  FSUIKitSwift
//
//  Created by Sheng on 2024/1/19.
//  Copyright © 2024 Sheng. All rights reserved.
//

import UIKit

public struct FSToolBarConst {
    public static let defaultHeight: CGFloat = 49.0
}

open class FSToolBar: UIView {
    
    // MARK: Properties/Override
    
    @available(*, unavailable)
    public override var backgroundColor: UIColor? {
        get {
            return backgroundView.backgroundColor
        }
        set {
            backgroundView.backgroundColor = newValue
        }
    }
    
    open override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        if size.height <= 0.0 {
            size.height = FSToolBarConst.defaultHeight
        }
        return size
    }
    
    // MARK: Properties/Public
    
    /// 背景修饰视图，如果要更改背景请在该控件上修改，比如更改背景颜色、透明度。
    /// 默认的背景色为 white。
    public let backgroundView = UIView()
    
    /// 顶部分割线颜色
    public var topSeparatorColor: UIColor? {
        get { return topSeparator.color }
        set { topSeparator.color = newValue }
    }
    
    /// 标识是否显示顶部分割线，默认为 true。
    public var shouldShowTopSeparator = true {
        didSet {
            topSeparator.isHidden = !shouldShowTopSeparator
        }
    }
    
    // MARK: Properties/Private
    
    private lazy var topSeparator: FSSeparatorView = {
        let separator = FSSeparatorView()
        separator.color = .fs.color(hexed: "B5B5B5")
        separator.translatesAutoresizingMaskIntoConstraints = false
        return separator
    }()
    
    // MARK: Initialization
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        p_didInitialize()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        p_didInitialize()
    }
    
    // MARK: Override
    
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        var result = super.sizeThatFits(size)
        if result.height <= 0.0 {
            result.height = self.intrinsicContentSize.height
        }
        return result
    }
    
    open override func sizeToFit() {
        frame.size = sizeThatFits(.init(width: CGFloat(Int16.max), height: CGFloat(Int16.max)))
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        sendSubviewToBack(backgroundView)
    }
}

// MARK: - Private

private extension FSToolBar {
    
    /// Invoked after initialization.
    func p_didInitialize() {
        do {
            super.backgroundColor = .clear
        }
        do {
            backgroundView.backgroundColor = .white
            backgroundView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(backgroundView)
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|",
                                                          metrics: nil,
                                                          views: ["view": backgroundView]))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]",
                                                          metrics: nil,
                                                          views: ["view": backgroundView]))
            addConstraint(.init(item: backgroundView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: self,
                                attribute: .bottom,
                                multiplier: 1.0,
                                constant: UIScreen.fs.safeAreaInsets.bottom))
        }
        do {
            addSubview(topSeparator)
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|",
                                                          metrics: nil,
                                                          views: ["view": topSeparator]))
            addConstraint(.init(item: topSeparator,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: self,
                                attribute: .top,
                                multiplier: 1.0,
                                constant: 0.0))
            addConstraint(.init(item: topSeparator,
                                attribute: .height,
                                relatedBy: .equal,
                                toItem: nil,
                                attribute: .notAnAttribute,
                                multiplier: 1.0,
                                constant: UIScreen.fs.pixelOne))
        }
    }
}
