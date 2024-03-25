//
//  FSPageControl.swift
//  FSUIKit
//
//  Created by Sheng on 2024/3/25.
//  Copyright © 2024 Sheng. All rights reserved.
//

import UIKit

open class FSPageControl: UIView {
    
    // MARK: Properties/Public
    
    /// 页码总数，默认为 0。
    public var numberOfPages: Int = 0 {
        didSet {
            if numberOfPages != oldValue {
                if numberOfPages < 0 {
                    numberOfPages = 0
                }
                p_setNeedsReload()
            }
        }
    }
    
    /// 当前页码，默认为 0。
    public var currentPage: Int {
        get { return p_currentPage }
        set {
            if needsReload {
                p_currentPage = newValue
            } else {
                p_selectPage(at: newValue)
            }
        }
    }
    
    /// 当只有一页时是否隐藏当前控件，默认为 false。
    public var hidesForSinglePage: Bool = false {
        didSet {
            p_updateIndicatorHiddenStatus()
        }
    }
    
    /// 未选中页码指示器的颜色。
    public var pageIndicatorColor: UIColor? = .fs.separator.withAlphaComponent(0.5) {
        didSet {
            p_updatePageIndicatorColor()
        }
    }
    
    /// 选中页码指示器的颜色。
    public var currentPageIndicatorColor: UIColor? = .fs.separator {
        didSet {
            p_updateCurrentPageIndicatorColor()
        }
    }
    
    /// 页码指示器之间的间隔。
    public var pageIndicatorSpacing: CGFloat = 4.0 {
        didSet {
            if pageIndicatorSpacing != oldValue {
                stackView.spacing = pageIndicatorSpacing
                sizeToFit()
                invalidateIntrinsicContentSize()
            }
        }
    }
    
    /// 未选中页码指示器的大小。
    public var pageIndicatorSize: CGSize = .init(width: 6.0, height: 6.0) {
        didSet {
            if pageIndicatorSize != oldValue {
                p_setNeedsReload()
            }
        }
    }
    
    /// 选中页码指示器的大小。
    public var currentPageIndicatorSize: CGSize = .init(width: 12.0, height: 6.0) {
        didSet {
            if currentPageIndicatorSize != oldValue {
                p_setNeedsReload()
            }
        }
    }
    
    // MARK: Properties/Private
    
    private var needsReload: Bool = false
    
    private var p_currentPage: Int = 0
    
    private var indicators = [_PageIndicator]()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .equalSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let widthConstraintsMap = NSMapTable<UIView, NSLayoutConstraint>.weakToStrongObjects()
    private let heightConstraintsMap = NSMapTable<UIView, NSLayoutConstraint>.weakToStrongObjects()
    
    // MARK: Initialization
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        p_didInitialize()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        p_didInitialize()
    }
}

// MARK: - Override

extension FSPageControl {
    
    open override var intrinsicContentSize: CGSize {
        guard numberOfPages > 0 else {
            return .zero
        }
        let height = max(pageIndicatorSize.height, currentPageIndicatorSize.height)
        var width: CGFloat = 0.0
        width += currentPageIndicatorSize.width
        width += pageIndicatorSize.width * CGFloat(numberOfPages - 1)
        width += pageIndicatorSpacing * CGFloat(numberOfPages - 1)
        return .init(width: ceil(width), height: ceil(height))
    }
    
    open override func sizeToFit() {
        var frame = self.frame
        frame.size = intrinsicContentSize
        self.frame = frame
    }
    
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        return intrinsicContentSize
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        p_reloadIfNeeded()
    }
}

// MARK: - Private

private extension FSPageControl {
    
    /// Called after initialization.
    func p_didInitialize() {
        defer {
            p_setNeedsReload()
        }
        addSubview(stackView)
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[stack]|", options: [], metrics: nil, views: ["stack": stackView]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[stack]|", options: [], metrics: nil, views: ["stack": stackView]))
    }
    
    func p_updateIndicatorHiddenStatus() {
        stackView.isHidden = hidesForSinglePage && indicators.count <= 1
    }
    
    func p_updatePageIndicatorColor() {
        indicators.forEach { $0.normalColor = pageIndicatorColor }
    }
    
    func p_updateCurrentPageIndicatorColor() {
        indicators.forEach { $0.selectedColor = currentPageIndicatorColor }
    }
    
    func p_selectPage(at page: Int, animated: Bool = false) {
        guard page >= 0, page < numberOfPages, page < indicators.count else {
            return
        }
        defer {
            p_currentPage = page
        }
        let dispose: (() -> Void) = { [weak self] in
            guard let self = self else { return }
            let current: _PageIndicator? = {
                if self.p_currentPage < self.indicators.count {
                    let indicator = self.indicators[self.p_currentPage]
                    if indicator.isSelected {
                        return indicator
                    }
                    return nil
                }
                return nil
            }()
            let target = self.indicators[page]
            if let current = current, current !== target {
                current.isSelected = false
                current.cornerRadius = self.pageIndicatorSize.height / 2
                if let width  = self.widthConstraintsMap.object(forKey: current) {
                    width.constant = self.pageIndicatorSize.width
                }
                if let height = self.heightConstraintsMap.object(forKey: current) {
                    height.constant = self.pageIndicatorSize.height
                }
            }
            do {
                target.isSelected = true
                target.cornerRadius = self.currentPageIndicatorSize.height / 2
                if let width  = self.widthConstraintsMap.object(forKey: target) {
                    width.constant = self.currentPageIndicatorSize.width
                }
                if let height = self.heightConstraintsMap.object(forKey: target) {
                    height.constant = self.currentPageIndicatorSize.height
                }
            }
        }
        if !animated {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            dispose()
            CATransaction.commit()
        } else {
            UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseOut) {
                dispose()
                self.stackView.layoutIfNeeded()
            }
        }
    }
}

// MARK: - Reloadable

private extension FSPageControl {
    
    func p_setNeedsReload() {
        needsReload = true
        setNeedsLayout()
    }
    
    func p_reloadIfNeeded() {
        if needsReload {
            p_reload()
        }
    }
    
    func p_reload() {
        defer {
            sizeToFit()
            p_updateIndicatorHiddenStatus()
            invalidateIntrinsicContentSize()
            p_updatePageIndicatorColor()
            p_updateCurrentPageIndicatorColor()
            p_selectPage(at: p_currentPage)
        }
        needsReload = false
        widthConstraintsMap.removeAllObjects()
        heightConstraintsMap.removeAllObjects()
        stackView.arrangedSubviews.forEach {
            stackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        indicators = (0..<numberOfPages).compactMap { index in
            let indicator = _PageIndicator()
            if index == p_currentPage {
                indicator.isSelected = true
            }
            return indicator
        }
        indicators.forEach {
            $0.cornerRadius = pageIndicatorSize.height / 2
            stackView.addArrangedSubview($0)
            let width = NSLayoutConstraint(item: $0,
                                           attribute: .width,
                                           relatedBy: .equal,
                                           toItem: nil,
                                           attribute: .notAnAttribute,
                                           multiplier: 1.0,
                                           constant: pageIndicatorSize.width)
            let height = NSLayoutConstraint(item: $0,
                                            attribute: .height,
                                            relatedBy: .equal,
                                            toItem: nil,
                                            attribute: .notAnAttribute,
                                            multiplier: 1.0,
                                            constant: pageIndicatorSize.height)
            stackView.addConstraints([width, height])
            widthConstraintsMap.setObject(width, forKey: $0)
            heightConstraintsMap.setObject(height, forKey: $0)
        }
    }
}

// MARK: - Public

public extension FSPageControl {
    
    func selectPage(at page: Int, animated: Bool = false) {
        if needsReload {
            if page >= 0, page < numberOfPages {
                p_currentPage = page
            }
        } else {
            p_selectPage(at: page, animated: animated)
        }
    }
}

// MARK: - _PageIndicator

private class _PageIndicator: UIView {
    
    // MARK: Properties/Fileprivate
    
    var normalColor: UIColor? {
        didSet {
            if !isSelected {
                colorLayer.backgroundColor = normalColor?.cgColor
            }
        }
    }
    
    var selectedColor: UIColor? {
        didSet {
            if isSelected {
                colorLayer.backgroundColor = selectedColor?.cgColor
            }
        }
    }
    
    var isSelected = false {
        didSet {
            if isSelected != oldValue {
                colorLayer.backgroundColor = (isSelected ? selectedColor : normalColor)?.cgColor
            }
        }
    }
    
    var cornerRadius: CGFloat {
        get { return layer.cornerRadius }
        set { layer.cornerRadius = newValue }
    }
    
    // MARK: Properties/Private
    
    private let colorLayer = CAShapeLayer()
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        p_didInitialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        p_didInitialize()
    }
    
    // MARK: Override
    
    override func layoutSubviews() {
        super.layoutSubviews()
        do {
            /*
             如果直接设定 `colorLayer.frame = .init(origin: .zero, size: bounds.size)` 则会引发一个
             问题：在当前 view 更改 size 时，colorLayer 会出现一个动画。
             因此此处设置一个比当前 view 的 size 更大的 size 作为 colorLayer 的 size。
             */
            let size = CGSize(width: ceil(bounds.width) * 2, height: ceil(bounds.height) * 2)
            if size.width > colorLayer.bounds.width || size.height > colorLayer.bounds.height {
                colorLayer.frame = .init(origin: .zero, size: size)
            }
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #unavailable(iOS 17) {
            let normal = normalColor
            let selected = selectedColor
            normalColor = normal
            selectedColor = selected
        }
    }
    
    // MARK: Private
    
    /// Invoked after initialization.
    private func p_didInitialize() {
        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
        layer.addSublayer(colorLayer)
        if #available(iOS 17, *) {
            registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (self: Self, previousTraitCollection: UITraitCollection) in
                let normal = self.normalColor
                let selected = self.selectedColor
                self.normalColor = normal
                self.selectedColor = selected
            }
        }
    }
}
