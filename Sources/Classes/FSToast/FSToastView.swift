//
//  FSToastView.swift
//  FSUIKit
//
//  Created by Sheng on 2024/2/6.
//  Copyright © 2024 Sheng. All rights reserved.
//

/*
 FSToastView layout:
 ┌────────────────────────────────────────────────────────────────────────┐
 |                                   |                                    |
 |                           (contentInset.top)                           |
 |                                   |                                    |
 |                           ┌──────────────┐                             |
 |                           |    TopView   |                             |
 |                           └──────────────┘                             |
 |                                   |                                    |
 |                                (spacing)                               |
 |                                   |                                    |
 |                           ┌────────────────┐                           |
 |                           | UILabel (Text) |                           |
 |                           └────────────────┘                           |
 |                                   |                                    |
 | - (contentInset.right) -       (spacing)      - (contentInset.right) - |
 |                                   |                                    |
 |                          ┌──────────────────┐                          |
 |                          | UILabel (Detail) |                          |
 |                          └──────────────────┘                          |
 |                                   |                                    |
 |                                (spacing)                               |
 |                                   |                                    |
 |                           ┌──────────────┐                             |
 |                           |  BottomView  |                             |
 |                           └──────────────┘                             |
 |                                   |                                    |
 |                         (contentInset.bottom)                          |
 |                                   |                                    |
 └────────────────────────────────────────────────────────────────────────┘
 */

import UIKit

open class FSToastView: FSReloadableView {
    
    // MARK: Properties/Public
    
    open var content: FSToastContentConvertable? {
        didSet {
            setNeedsReload()
        }
    }
    
    // MARK: Properties/Private
    
    private var userInterfaceStyleRaw: Int = 0
    
    private var contentSize: CGSize = .zero
    
    private weak var topView: UIView?
    private weak var bottomView: UIView?
    
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var detailTextLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var blurView: FSVisualEffectView = {
        let view = FSVisualEffectView()
        view.isHidden = true
        return view
    }()
    
    private let paddingInset = UIEdgeInsets(top: 15.0, left: 15.0, bottom: 15.0, right: 15.0)
    
    // MARK: Initialization
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        p_didInitialize()
    }
}

// MARK: - Override

extension FSToastView {
    
    open override var intrinsicContentSize: CGSize {
        return contentSize
    }
    
    open override func sizeToFit() {
        super.sizeToFit()
        if contentSize == .zero {
            reloadDataIfNeeded()
        }
        var frame = self.frame
        frame.size = contentSize
        self.frame = frame
    }
    
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        if contentSize == .zero {
            reloadDataIfNeeded()
        }
        return .init(width: min(size.width, contentSize.width),
                     height: min(size.height, contentSize.height))
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        do {
            blurView.frame = .init(origin: .zero, size: bounds.size)
        }
    }
    
    open override func reloadData() {
        defer {
            p_layoutSubviews()
        }
        super.reloadData()
        do {
            backgroundColor = .clear
            layer.borderWidth = 0.0
            layer.borderColor = nil
            layer.cornerRadius = 0.0
            
            topView?.removeFromSuperview()
            bottomView?.removeFromSuperview()
            
            topView = nil
            bottomView = nil
            textLabel.isHidden = true
            detailTextLabel.isHidden = true
            textLabel.attributedText = nil
            detailTextLabel.attributedText = nil
        }
        guard let content = content else {
            return
        }
        do {
            if let effect = content.backgroundEffect {
                
                backgroundColor = .clear
                blurView.isHidden = false
                
                blurView.scale = effect.scale
                blurView.color = effect.color
                blurView.colorAlpha = effect.color == nil ? 0.0 : effect.colorAlpha
                blurView.blurRadius = effect.blurRadius
                
            } else {
                backgroundColor = content.backgroundColor
                blurView.isHidden = true
            }
        }
        do {
            layer.borderWidth = content.borderWidth
            layer.borderColor = content.borderColor?.cgColor
            layer.cornerRadius = content.cornerRadius
        }
        do {
            if let view = content.topView {
                topView = view
                addSubview(view)
            }
            if let view = content.bottomView {
                bottomView = view
                addSubview(view)
            }
        }
        do {
            if let text = content.richText {
                textLabel.isHidden = false
                textLabel.attributedText = text
            } else if let text = content.text {
                textLabel.isHidden = false
                textLabel.attributedText = NSAttributedString.fs.toast_richText(string: text)
            }
        }
        do {
            if let text = content.richDetail {
                detailTextLabel.isHidden = false
                detailTextLabel.attributedText = text
            } else if let text = content.detail {
                detailTextLabel.isHidden = false
                detailTextLabel.attributedText = NSAttributedString.fs.toast_richDetail(string: text)
            }
        }
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #unavailable(iOS 17) {
            p_traitCollectionDidChange()
        }
    }
}

// MARK: - Private

private extension FSToastView {
    
    /// Invoked after initialization.
    func p_didInitialize() {
        do {
            if #available(iOS 13, *) {
                userInterfaceStyleRaw = UITraitCollection.current.userInterfaceStyle.rawValue
            }
        }
        do {
            clipsToBounds = true
            if #available(iOS 17, *) {
                registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (self: Self, previousTraitCollection: UITraitCollection) in
                    self.p_traitCollectionDidChange()
                }
            }
        }
        addSubview(blurView)
        addSubview(textLabel)
        addSubview(detailTextLabel)
    }
    
    func p_layoutSubviews() {
        defer {
            sizeToFit()
            invalidateIntrinsicContentSize()
        }
        
        guard 
            let containerView = superview,
            let content = content
        else {
            contentSize = .zero
            return
        }
        
        let containerSize = containerView.frame.size
        
        let layoutWidthMax: CGFloat = {
            var result = containerSize.width
            result -= containerView.safeAreaInsets.fs.horizontalValue()
            result -= paddingInset.fs.horizontalValue()
            result -= content.contentInset.fs.horizontalValue()
            return result
        }()
        
        let layoutHeightMax: CGFloat = {
            var result = containerSize.height
            result -= containerView.safeAreaInsets.fs.verticalValue()
            result -= paddingInset.fs.verticalValue()
            result -= content.contentInset.fs.verticalValue()
            return result
        }()
        
        guard layoutWidthMax > 0.0, layoutHeightMax > 0.0 else {
            contentSize = .zero
            return
        }
        
        let fitsSize = CGSize(width: layoutWidthMax, height: layoutHeightMax)
        
        let topViewSize: CGSize = {
            if let view = topView {
                if let size = content.topViewSize {
                    return size
                } else {
                    return view.sizeThatFits(fitsSize)
                }
            }
            return .zero
        }()
        
        let bottomViewSize: CGSize = {
            if let view = bottomView {
                if let size = content.bottomViewSize {
                    return size
                } else {
                    return view.sizeThatFits(fitsSize)
                }
            }
            return .zero
        }()
        
        let textSize: CGSize = {
            guard !textLabel.isHidden else {
                return .zero
            }
            return textLabel.sizeThatFits(fitsSize)
        }()
        
        let detailSize: CGSize = {
            guard !detailTextLabel.isHidden else {
                return .zero
            }
            return detailTextLabel.sizeThatFits(fitsSize)
        }()
        
        var contentWidth: CGFloat = 0.0
        var contentHeight: CGFloat = 0.0
        
        contentWidth = {
            let sizes = [topViewSize, bottomViewSize, textSize, detailSize]
            return sizes.map { $0.width }.max() ?? 0.0
        }()
        contentWidth += content.contentInset.fs.horizontalValue()
        
        do {
            var lastMaxY = content.contentInset.top
            var spacing: CGFloat = 0.0
            
            if let view = topView {
                let x = (contentWidth - topViewSize.width) / 2
                let y = lastMaxY
                view.frame = .init(origin: .init(x: x, y: y), size: topViewSize)
                lastMaxY = view.frame.maxY
                spacing  = content.topViewBottomSpacing
            }
            if !textLabel.isHidden {
                let x = (contentWidth - textSize.width) / 2
                let y = lastMaxY + spacing
                textLabel.frame = .init(origin: .init(x: x, y: y), size: textSize)
                lastMaxY = textLabel.frame.maxY
                spacing  = content.textBottomSpacing
            }
            if !detailTextLabel.isHidden {
                let x = (contentWidth - detailSize.width) / 2
                let y = lastMaxY + spacing
                detailTextLabel.frame = .init(origin: .init(x: x, y: y), size: detailSize)
                lastMaxY = detailTextLabel.frame.maxY
                spacing  = content.detailBottomSpacing
            }
            if let view = bottomView {
                let x = (contentWidth - bottomViewSize.width) / 2
                let y = lastMaxY + spacing
                view.frame = .init(origin: .init(x: x, y: y), size: bottomViewSize)
                lastMaxY = view.frame.maxY
            }
            contentHeight = lastMaxY + content.contentInset.bottom
            contentHeight = min(contentHeight, layoutHeightMax)
        }
        contentSize = .init(width: contentWidth, height: contentHeight)
    }
    
    func p_traitCollectionDidChange() {
        guard #available(iOS 13, *), userInterfaceStyleRaw != UITraitCollection.current.userInterfaceStyle.rawValue else {
            return
        }
        content?.userInterfaceStyleDidChange()
        setNeedsReload()
    }
}
