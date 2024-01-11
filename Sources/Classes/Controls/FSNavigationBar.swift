//
//  FSNavigationBar.swift
//  FSUIKit
//
//  Created by Sheng on 2024/1/4.
//  Copyright © 2024 Sheng. All rights reserved.
//

import UIKit

/**
 该控件是用于在某些隐藏系统导航栏的场景下使用的自定义导航栏，用于完成一些系统导航栏无法完成的需求。
 
 该控件类似于 UINavigationBar，会自动往顶部延伸一个状态栏的高度，因此使用者只需要约束本控件的顶部为状态栏的底部即可，
 同时因为控件会有一个默认的高度: 44.0，因此使用者多数情况下的布局约束为如下代码:
 ```
 navigationBar.snp.makeConstraints { (make) in
     make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
     make.left.right.equalTo(0.0)
 }
 ```
 
 - Note: FSNavigationBar 有默认的高度：44pt，如果外部不设置高度的话，会使用默认高度。
 */
open class FSNavigationBar: UIView {
    
    open var title: String? {
        didSet {
            titleLabel.text = title
            setNeedsUpdateConstraints()
        }
    }
    
    open var titleFont: UIFont? {
        didSet {
            if let font = titleFont {
                titleLabel.font = font
            }
        }
    }
    
    open var titleColor: UIColor? {
        didSet {
            if let color = titleColor {
                titleLabel.textColor = color
            }
        }
    }
    
    /// 标题视图，默认为 nil，外部可以设置一个 UIView 作为 FSNavigationBar 的 titleView，
    /// 该 titleView 是居中在内容区显示的，size 需外部设置好，否则内部是调用 titleView 的
    /// sizeToFit 来适应 titleView 的 size。
    ///
    /// - Note: 如果设置了 titleView 的话则会隐藏标题。
    open var titleView: UIView? {
        didSet {
            if titleView == nil, oldValue == nil {
                return
            }
            if let new = titleView, let old = oldValue, new === old {
                return
            }
            titleViewLeftConstraint = nil
            titleViewRightConstraint = nil
            if let old = oldValue {
                NSLayoutConstraint.deactivate(old.constraints)
                old.removeFromSuperview()
            }
            if let new = titleView {
                do {
                    new.translatesAutoresizingMaskIntoConstraints = false
                    contentView.addSubview(new)
                    contentView.addConstraint(.init(item: new,
                                                    attribute: .centerY,
                                                    relatedBy: .equal,
                                                    toItem: contentView,
                                                    attribute: .centerY,
                                                    multiplier: 1.0,
                                                    constant: 0.0))
                    do {
                        let constraint = NSLayoutConstraint(item: new,
                                                            attribute: .left,
                                                            relatedBy: .greaterThanOrEqual,
                                                            toItem: leftItemsView,
                                                            attribute: .right,
                                                            multiplier: 1.0,
                                                            constant: 0.0)
                        contentView.addConstraint(constraint)
                        titleViewLeftConstraint = constraint
                    }
                    do {
                        let constraint = NSLayoutConstraint(item: new,
                                                            attribute: .right,
                                                            relatedBy: .lessThanOrEqual,
                                                            toItem: rightItemsView,
                                                            attribute: .left,
                                                            multiplier: 1.0,
                                                            constant: 0.0)
                        contentView.addConstraint(constraint)
                        titleViewRightConstraint = constraint
                    }
                    do {
                        let centerX = NSLayoutConstraint(item: new,
                                                         attribute: .centerX,
                                                         relatedBy: .equal,
                                                         toItem: contentView,
                                                         attribute: .centerX,
                                                         multiplier: 1.0,
                                                         constant: 0.0)
                        centerX.priority = .defaultLow
                        contentView.addConstraint(centerX)
                    }
                }
            }
            setNeedsUpdateConstraints()
        }
    }
    
    /// 背景修饰视图，如果要更改背景请在该控件上修改，比如更改背景颜色、透明度。
    /// 默认的背景色为 white。
    public let backgroundView = UIView()
    
    /// 底部分割线颜色
    public var bottomSeparatorColor: UIColor? {
        get { return bottomSeparator.color }
        set { bottomSeparator.color = newValue }
    }
    
    /// 标识是否显示底部分割线，默认为 true。
    public var shouldShowBottomSeparator = true {
        didSet {
            bottomSeparator.isHidden = !shouldShowBottomSeparator
        }
    }
    
    /// 类似 `UINavigationitem` 的 `leftBarButtonItems` 的用法，
    /// 只是此处使用的是 `UIView` 集合而非 `UIBarButtonItem` 集合。
    ///
    /// - Note: 设置该属性时会自动移除 backButton，二者不可共存。
    open var leftItemViews: [UIView]? {
        didSet {
            if let new = leftItemViews, let old = oldValue {
                if (new.isEmpty && old.isEmpty) || new.elementsEqual(old) {
                    return
                }
            }
            if let old = oldValue {
                for view in old {
                    view.removeFromSuperview()
                    leftItemsView.removeArrangedSubview(view)
                }
                setNeedsUpdateConstraints()
            }
            guard let views = leftItemViews, !views.isEmpty else {
                return
            }
            views.forEach { leftItemsView.addArrangedSubview($0) }
            setNeedsUpdateConstraints()
        }
    }
    
    /// 类似 `UINavigationitem` 的 `rightBarButtonItems` 的用法，
    /// 只是此处使用的是 `UIView` 集合而非 `UIBarButtonItem` 集合。
    open var rightItemViews: [UIView]? {
        didSet {
            if let new = rightItemViews, let old = oldValue {
                if (new.isEmpty && old.isEmpty) || new.elementsEqual(old) {
                    return
                }
            }
            if let old = oldValue {
                for view in old {
                    view.removeFromSuperview()
                    rightItemsView.removeArrangedSubview(view)
                }
                setNeedsUpdateConstraints()
            }
            guard let views = rightItemViews, !views.isEmpty else {
                return
            }
            views.forEach { rightItemsView.addArrangedSubview($0) }
            setNeedsUpdateConstraints()
        }
    }
    
    private let contentView = UIView()
    
    private weak var backButton: FSButton?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18.0)
        label.isHidden = true
        label.textColor = .black
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var leftItemsView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 10.0
        stack.isHidden = true
        stack.alignment = .center
        stack.distribution = .equalSpacing
        stack.layoutMargins = .init(top: 0.0,
                                    left: FSNavigationBarConst.horizontalMargin,
                                    bottom: 0.0,
                                    right: FSNavigationBarConst.horizontalMargin)
        stack.isLayoutMarginsRelativeArrangement = true
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var rightItemsView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 10.0
        stack.isHidden = true
        stack.alignment = .center
        stack.distribution = .equalSpacing
        stack.layoutMargins = .init(top: 0.0,
                                    left: FSNavigationBarConst.horizontalMargin,
                                    bottom: 0.0,
                                    right: FSNavigationBarConst.horizontalMargin)
        stack.isLayoutMarginsRelativeArrangement = true
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var bottomSeparator: FSSeparatorView = {
        let separator = FSSeparatorView()
        separator.color = .fs.color(hexed: "F0F1F3")
        separator.translatesAutoresizingMaskIntoConstraints = false
        return separator
    }()
    
    private weak var titleLabelLeftConstraint: NSLayoutConstraint?
    private weak var titleLabelRightConstraint: NSLayoutConstraint?
    private weak var titleViewLeftConstraint: NSLayoutConstraint?
    private weak var titleViewRightConstraint: NSLayoutConstraint?
    
    // MARK: Initialization
    
    public init() {
        let bounds = UIScreen.main.bounds
        let width = min(bounds.width, bounds.height)
        let height = FSNavigationBarConst.defaultHeight
        super.init(frame: .init(x: 0.0, y: 0.0, width: width, height: height))
        p_didInitialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        p_didInitialize()
    }
    
    // MARK: Override
    
    open override var backgroundColor: UIColor? {
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
            size.height = FSNavigationBarConst.defaultHeight
        }
        return size
    }
    
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
    
    open override func updateConstraints() {
        super.updateConstraints()
        do {
            var shouldHideTitle = false
            if let _ = titleView {
                shouldHideTitle = true
            } else {
                if let text = titleLabel.text {
                    shouldHideTitle = text.isEmpty
                } else {
                    shouldHideTitle = true
                }
            }
            titleLabel.isHidden = shouldHideTitle
            leftItemsView.isHidden = leftItemsView.arrangedSubviews.isEmpty
            rightItemsView.isHidden = rightItemsView.arrangedSubviews.isEmpty
            if leftItemsView.isHidden {
                titleLabelLeftConstraint?.constant = FSNavigationBarConst.horizontalMargin
                titleViewLeftConstraint?.constant = FSNavigationBarConst.horizontalMargin
            }
            if rightItemsView.isHidden {
                titleLabelRightConstraint?.constant = -FSNavigationBarConst.horizontalMargin
                titleViewRightConstraint?.constant = -FSNavigationBarConst.horizontalMargin
            }
        }
    }
    
    // MARK: Private
    
    /// Invoked after initialization.
    private func p_didInitialize() {
        do {
            super.backgroundColor = .clear
        }
        do {
            backgroundView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(backgroundView)
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|",
                                                          metrics: nil,
                                                          views: ["view": backgroundView]))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[view]|",
                                                          metrics: nil,
                                                          views: ["view": backgroundView]))
            addConstraint(.init(item: backgroundView,
                                attribute: .top,
                                relatedBy: .equal,
                                toItem: self,
                                attribute: .top,
                                multiplier: 1.0,
                                constant: -UIApplication.shared.statusBarFrame.height))
        }
        do {
            contentView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(contentView)
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|",
                                                          metrics: nil,
                                                          views: ["view": contentView]))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[view]|",
                                                          metrics: nil,
                                                          views: ["view": contentView]))
            addConstraint(.init(item: contentView,
                                attribute: .height,
                                relatedBy: .equal,
                                toItem: self,
                                attribute: .height,
                                multiplier: 1.0,
                                constant: 0.0))
        }
        do {
            contentView.addSubview(titleLabel)
            contentView.addSubview(leftItemsView)
            contentView.addSubview(rightItemsView)
            do {
                contentView.addConstraint(.init(item: leftItemsView,
                                                attribute: .left,
                                                relatedBy: .equal,
                                                toItem: contentView,
                                                attribute: .left,
                                                multiplier: 1.0,
                                                constant: 0.0))
                contentView.addConstraint(.init(item: leftItemsView,
                                                attribute: .centerY,
                                                relatedBy: .equal,
                                                toItem: contentView,
                                                attribute: .centerY,
                                                multiplier: 1.0,
                                                constant: 0.0))
                contentView.addConstraint(.init(item: leftItemsView,
                                                attribute: .height,
                                                relatedBy: .equal,
                                                toItem: contentView,
                                                attribute: .height,
                                                multiplier: 1.0,
                                                constant: 0.0))
            }
            do {
                contentView.addConstraint(.init(item: rightItemsView,
                                                attribute: .right,
                                                relatedBy: .equal,
                                                toItem: contentView,
                                                attribute: .right,
                                                multiplier: 1.0,
                                                constant: 0.0))
                contentView.addConstraint(.init(item: rightItemsView,
                                                attribute: .centerY,
                                                relatedBy: .equal,
                                                toItem: contentView,
                                                attribute: .centerY,
                                                multiplier: 1.0,
                                                constant: 0.0))
                contentView.addConstraint(.init(item: rightItemsView,
                                                attribute: .height,
                                                relatedBy: .equal,
                                                toItem: contentView,
                                                attribute: .height,
                                                multiplier: 1.0,
                                                constant: 0.0))
            }
            do {
                contentView.addConstraint(.init(item: titleLabel,
                                                attribute: .centerY,
                                                relatedBy: .equal,
                                                toItem: contentView,
                                                attribute: .centerY,
                                                multiplier: 1.0,
                                                constant: 0.0))
                do {
                    let constraint = NSLayoutConstraint(item: titleLabel,
                                                        attribute: .left,
                                                        relatedBy: .greaterThanOrEqual,
                                                        toItem: leftItemsView,
                                                        attribute: .right,
                                                        multiplier: 1.0,
                                                        constant: 0.0)
                    contentView.addConstraint(constraint)
                    titleLabelLeftConstraint = constraint
                }
                do {
                    let constraint = NSLayoutConstraint(item: titleLabel,
                                                        attribute: .right,
                                                        relatedBy: .lessThanOrEqual,
                                                        toItem: rightItemsView,
                                                        attribute: .left,
                                                        multiplier: 1.0,
                                                        constant: 0.0)
                    contentView.addConstraint(constraint)
                    titleLabelRightConstraint = constraint
                }
                do {
                    let centerX = NSLayoutConstraint(item: titleLabel,
                                                     attribute: .centerX,
                                                     relatedBy: .equal,
                                                     toItem: contentView,
                                                     attribute: .centerX,
                                                     multiplier: 1.0,
                                                     constant: 0.0)
                    centerX.priority = .defaultLow
                    contentView.addConstraint(centerX)
                }
            }
        }
        do {
            addSubview(bottomSeparator)
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|",
                                                          metrics: nil,
                                                          views: ["view": bottomSeparator]))
            addConstraint(.init(item: bottomSeparator,
                                attribute: .top,
                                relatedBy: .equal,
                                toItem: self,
                                attribute: .bottom,
                                multiplier: 1.0,
                                constant: 0.0))
            addConstraint(.init(item: bottomSeparator,
                                attribute: .height,
                                relatedBy: .equal,
                                toItem: nil,
                                attribute: .notAnAttribute,
                                multiplier: 1.0,
                                constant: UIScreen.fs.pixelOne))
        }
        do {
            resetDefaultBackButton()
            titleColor = .black
            titleLabel.textColor = titleColor
            setDefaultBackButton(tintColor: titleColor)
        }
    }
}

// MARK: Private/Actions

private extension FSNavigationBar {
    
    @objc func p_didPressBackButton(_ sender: Any) {
        guard let currentVC = p_findCurrentViewController() else { return }
        if let nc = currentVC.navigationController {
            if nc.viewControllers.first !== currentVC {
                nc.popViewController(animated: true)
            } else {
                nc.dismiss(animated: true, completion: nil)
            }
        } else {
            currentVC.dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: - Public

public extension FSNavigationBar {
    
    /// 重置默认的返回按钮，调用该方法会清除原设置的 leftItemViews (假设已设置)。
    ///
    /// - Note: FSNavigationBar 在初始化时会默认调用该方法设置一个默认的返回按钮，外部不需要在初始化后再调用该方法，
    ///         如果要清除默认的返回按钮的话直接设置 leftItemViews 为 nil 即可。
    func resetDefaultBackButton() {
        let button = FSButton(type: .custom)
        button.backgroundColor = .clear
        button.hitTestEdgeInsets = .init(top: 0.0,
                                         left: -FSNavigationBarConst.horizontalMargin,
                                         bottom: 0.0,
                                         right: -FSNavigationBarConst.horizontalMargin)
        // 按钮的颜色会在 p_updateTintColor() 方法中配置，因此此处直接设置图片即可。
        button.setImage(.inner.image(named: "icon_back"), for: .normal)
        button.addTarget(self, action: #selector(p_didPressBackButton(_:)), for: .touchUpInside)
        backButton = button
        leftItemViews = [button]
    }
    
    /// 设置默认的返回按钮的颜色。
    /// 该方法内部会自动创建一个高亮时的颜色。
    ///
    /// - Note: 如果 isFollowingTheme 为 true 的话，该方法所设置的颜色有可能会被覆盖。
    func setDefaultBackButton(tintColor: UIColor?) {
        guard let button = backButton, let tintColor = tintColor else {
            return
        }
        let color_hi = tintColor.withAlphaComponent(0.65)
        if let image = button.image(for: .normal) {
            if let image_n = image.fs.redraw(with: tintColor) {
                button.setImage(image_n, for: .normal)
            }
            if let image_hi = image.fs.redraw(with: color_hi) {
                button.setImage(image_hi, for: .highlighted)
            }
        }
    }
    
    /// 为默认的返回按钮添加 target-action 事件。
    ///
    /// - Note: 
    ///   如果默认的返回按钮不存在的话，调用该方法则无效。
    ///   另，调用该方法会清除返回按钮原来的 target-action 事件。
    ///
    func addActionForDefaultBackButton(_ target: Any?, action: Selector, for controlEvents: UIControl.Event) {
        guard let button = backButton else { return }
        button.removeTarget(self, action: nil, for: .allEvents)
        button.addTarget(target, action: action, for: controlEvents)
    }
}

private extension UIView {
    /// 查找当前 UIView 所属的 UIViewController。
    func p_findCurrentViewController() -> UIViewController? {
        guard let next = next else {
            return nil
        }
        if next is UIViewController {
            return next as? UIViewController
        }
        if next is UIView {
            return (next as! UIView).p_findCurrentViewController()
        }
        return nil
    }
}

// MARK: - FSNavigationBarConst

public struct FSNavigationBarConst {
    public static let defaultHeight: CGFloat = 44.0
    fileprivate static let horizontalMargin: CGFloat = 15.0
}
