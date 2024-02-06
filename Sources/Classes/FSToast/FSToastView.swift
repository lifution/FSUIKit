//
//  FSToastView.swift
//  FSUIKit
//
//  Created by Sheng on 2024/2/6.
//  Copyright © 2024 Sheng. All rights reserved.
//

/*
 FSToastView layout:
 ┌────────────────────────────────┐
 |      ┌──────────────┐          |
 |      |    TopView   |          |
 |      └──────────────┘          |
 |               |                |
 |            (space)             |
 |               |                |
 |       ┌────────────────┐       |
 |       | UILabel (Text) |       |
 |       └────────────────┘       |
 |               |                |
 |            (space)             |
 |               |                |
 |    ┌──────────────────────┐    |
 |    | UILabel (DetailText) |    |
 |    └──────────────────────┘    |
 |               |                |
 |            (space)             |
 |               |                |
 |       ┌──────────────┐         |
 |       |  BottomView  |         |
 |       └──────────────┘         |
 └────────────────────────────────┘
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
        guard let content = content else {
            contentSize = .zero
            return
        }
        
        let layoutWidthMax: CGFloat = {
            var result = UIScreen.fs.width
            result -= paddingInset.fs.horizontalValue()
            result -= content.contentInset.fs.horizontalValue()
            result -= UIScreen.fs.safeAreaInsets.fs.horizontalValue()
            return result
        }()
        
        let layoutHeightMax: CGFloat = {
            var result = UIScreen.fs.height
            result -= paddingInset.fs.horizontalValue()
            result -= content.contentInset.fs.horizontalValue()
            result -= UIScreen.fs.safeAreaInsets.fs.verticalValue()
            return result
        }()
        
        var contentWidth: CGFloat = content.contentInset.fs.horizontalValue()
        var contentHeight: CGFloat = content.contentInset.fs.verticalValue()
        
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
        
        contentWidth += {
            var result: CGFloat = 0.0
            let sizes = [topViewSize, bottomViewSize, textSize, detailSize]
            sizes.forEach { result = max(result, $0.width) }
            return result
        }()
        contentWidth = min(contentWidth, layoutWidthMax)
        
        do {
            var lastMaxY = content.contentInset.top
            var spacing: CGFloat = 0.0
            
            if let view = topView {
                let x = (contentWidth - topViewSize.width) / 2
                let y = lastMaxY
                view.frame = .init(origin: .init(x: x, y: y), size: topViewSize)
                lastMaxY = view.frame.maxY
                spacing  = content.topViewBottomSpace
            }
            if !textLabel.isHidden {
                let x = content.contentInset.left
                let y = lastMaxY + spacing
                let w = contentWidth - x - content.contentInset.right
                let h = textSize.height
                textLabel.frame = .init(x: x, y: y, width: w, height: h)
                lastMaxY = textLabel.frame.maxY
                spacing  = content.textBottomSpace
            }
            if !detailTextLabel.isHidden {
                let x = content.contentInset.left
                let y = lastMaxY + spacing
                let w = contentWidth - x - content.contentInset.right
                let h = detailSize.height
                detailTextLabel.frame = .init(x: x, y: y, width: w, height: h)
                lastMaxY = detailTextLabel.frame.maxY
                spacing  = content.detailBottomSpace
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
        content?.traitCollectionDidChange()
        setNeedsReload()
    }
}
