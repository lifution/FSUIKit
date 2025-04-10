//
//  FSButton.swift
//  FSUIKitSwift
//
//  Created by Sheng on 2023/12/24.
//  Copyright © 2023 Sheng. All rights reserved.
//

import UIKit

/// FSButton 提供以下功能：
///
/// 1. 支持让文字和图片自动跟随 tintColor 变化（系统的 UIButton 默认是不响应 tintColor 的）。
/// 2. highlighted、disabled 状态均通过改变整个按钮的 alpha 来表现，无需分别设置不同 state 下的 titleColor、image。
/// 3. 支持点击时改变背景色颜色（highlightedBackgroundColor）。
/// 4. 支持点击时改变边框颜色（highlightedBorderColor）。
/// 5. 支持设置图片相对于 titleLabel 的位置（imagePosition）。
/// 6. 支持设置图片和 titleLabel 之间的间距，无需自行调整 titleEdgeInests、imageEdgeInsets（spacingBetweenImageAndTitle）。
/// 7. 可调整控件的响应范围。
/// 8. 支持 RightToLeft 自动适应。
///
/// - Note: FSButton 重新定义了 titleEdgeInests、imageEdgeInsets、contentEdgeInsets 这三者的布局逻辑，
///         sizeThatFits: 里会把 titleEdgeInests 和 imageEdgeInsets 也考虑在内（UIButton 不会），以使这三个接口的使用更符合直觉。
///

import UIKit

open class FSButton: UIButton {
    
    // MARK: ImagePosition
    
    /// FSButton 的 `image` 和 `title` 的样式。
    public enum ImagePosition {
        /// image 在上，text 在下。
        case top
        /// image 在左，text 在右。
        case left
        /// image 在下，text 在上。
        case bottom
        /// image 在右，text 在左。
        case right
    }
    
    // MARK: Properties/Open
    
    /// 标识是否让按钮的文字颜色自动跟随 tintColor 调整（系统默认titleColor是不跟随的）。
    /// 默认为 false。
    open var adjustsTitleTintColorAutomatically: Bool = false {
        didSet {
            if adjustsTitleTintColorAutomatically != oldValue {
                p_updateTitleColorIfNeeded()
            }
        }
    }
    
    /// 让按钮的图片颜色自动跟随 tintColor 调整（系统默认image是需要更改renderingMode才可以达到这种效果）。
    /// 默认为 false。
    open var adjustsImageTintColorAutomatically: Bool = false {
        didSet {
            if adjustsImageTintColorAutomatically != oldValue {
                p_updateImageRenderingModeIfNeeded()
            }
        }
    }
    
    /// 等价于 adjustsTitleTintColorAutomatically = true & adjustsImageTintColorAutomatically = true & tintColor = xxx。
    open var tintColorAdjustsTitleAndImage: UIColor? {
        didSet {
            if let color = tintColorAdjustsTitleAndImage {
                tintColor = color
                adjustsTitleTintColorAutomatically = true
                adjustsImageTintColorAutomatically = true
            }
        }
    }
    
    /// 是否自动调整 highlighted 时的按钮样式，默认为 true。
    /// 当值为 true 时，按钮 highlighted 时会改变自身的 alpha 属性。
    open var adjustsButtonWhenHighlighted: Bool = true
    
    /// 是否自动调整 disabled 时的按钮样式，默认为 true。
    /// 当值为 true 时，按钮 disabled 时会改变自身的 alpha 属性。
    open var adjustsButtonWhenDisabled: Bool = true
    
    /// 设置按钮点击时的背景色，默认为nil。
    /// - Warning: 不支持带透明度的背景颜色。当设置 highlightedBackgroundColor 时，会强制把 adjustsButtonWhenHighlighted 设为 false，避免两者效果冲突。
    open var highlightedBackgroundColor: UIColor? {
        didSet {
            if let _ = highlightedBackgroundColor {
                // 只要开启了 highlightedBackgroundColor，就默认不需要 alpha 的高亮。
                adjustsButtonWhenHighlighted = false
            }
        }
    }
    
    /// 按钮点击时的边框颜色，默认为nil。
    /// - Warning: 当设置 highlightedBorderColor 时，会强制把 adjustsButtonWhenHighlighted 设为 false，避免两者效果冲突。
    open var highlightedBorderColor: UIColor? {
       didSet {
           if let _ = highlightedBorderColor {
               // 只要开启了 highlightedBorderColor，就默认不需要 alpha 的高亮。
               adjustsButtonWhenHighlighted = false
           }
       }
   }
    
    /// 设置按钮里图标和文字的相对位置，默认为 FSButton.ImagePosition.left。
    /// 可配合 imageEdgeInsets、titleEdgeInsets、contentHorizontalAlignment、contentVerticalAlignment 使用。
    open var imagePosition: FSButton.ImagePosition = .left {
        didSet {
            if imagePosition != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    /// 设置按钮里图标和文字之间的间隔，会自动响应 imagePosition 的变化而变化，默认为 0.0。
    /// 系统默认实现需要同时设置 titleEdgeInsets 和 imageEdgeInsets，同时还需考虑 contentEdgeInsets 的增加（否则不会影响布局，
    /// 可能会让图标或文字溢出或挤压），使用该属性可以避免以上情况。
    /// - Warning: 该属性会与 imageEdgeInsets、 titleEdgeInsets、 contentEdgeInsets 共同作用。
    open var spacingBetweenImageAndTitle: CGFloat = 0.0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// 调整 button 的响应范围。
    ///
    /// - Note:
    /// top/left/bottom/right 为正数时是往内收缩响应范围，为负数时才是往外扩张响应范围，
    /// 所以，**如果你需要扩大响应范围的话应该赋值负数**。
    ///
    open var hitTestEdgeInsets: UIEdgeInsets = .zero
    
    // MARK: Properties/Private
    
    private var originalBorderColor: UIColor?
    
    private var highlightedBackgroundLayer: CALayer?
    
    // MARK: Initialization
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        p_didInitialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        p_didInitialize()
    }
    
    // MARK: Override
    
    open override var isEnabled: Bool {
        didSet {
            if !isEnabled && adjustsButtonWhenDisabled {
                alpha = 0.5
            } else {
                alpha = 1.0
            }
        }
    }
    
    open override var isHighlighted: Bool {
        didSet {
            if isHighlighted && originalBorderColor == nil {
                // 手指按在按钮上会不断触发 setHighlighted:，所以这里做了保护，设置过一次就不用再设置了。
                if let color = layer.borderColor {
                    originalBorderColor = UIColor(cgColor: color)
                }
            }
            
            // 渲染背景色
            if highlightedBackgroundColor != nil || highlightedBorderColor != nil {
                p_adjustsButtonHighlighted()
            }
            // 如果此时是 disabled，则 disabled 的样式优先。
            if !isEnabled {
                return
            }
            // 自定义highlighted样式
            if adjustsButtonWhenHighlighted {
                if isHighlighted {
                    alpha = 0.5
                } else {
                    alpha = 1.0
                }
            }
        }
    }
    
    open override var intrinsicContentSize: CGSize {
        return sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
    }
    
    open override var semanticContentAttribute: UISemanticContentAttribute {
        didSet {
            if semanticContentAttribute != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    open override func setImage(_ image: UIImage?, for state: UIControl.State) {
        var image_ = image
        if adjustsImageTintColorAutomatically {
            image_ = image_?.withRenderingMode(.alwaysTemplate)
        }
        super.setImage(image_, for: state)
    }
    
    open override func tintColorDidChange() {
        super.tintColorDidChange()
        p_updateTitleColorIfNeeded()
        if adjustsImageTintColorAutomatically {
            p_updateImageRenderingModeIfNeeded()
        }
    }
    
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard hitTestEdgeInsets != .zero, isUserInteractionEnabled, isEnabled, !isHidden, alpha > 0.1 else {
            return super.point(inside: point, with: event)
        }
        let relativeFrame = bounds
        let hitFrame = relativeFrame.inset(by: hitTestEdgeInsets)
        return hitFrame.contains(point)
    }
    
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        var size = size
        // 如果调用 sizeToFit，那么传进来的 size 就是当前按钮的 size，此时的计算不要去限制宽高。
        if bounds.size == size {
            size = .init(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        }
        let isImageViewShowing: Bool = {
            if let _ = currentImage {
                return true
            }
            return false
        }()
        let isTitleLabelShowing: Bool = {
            if let title = currentTitle, !title.isEmpty {
                return true
            }
            if let title_att = currentAttributedTitle, !title_att.string.isEmpty {
                return true
            }
            return false
        }()
        var imageTotalSize = CGSize.zero // 包含 imageEdgeInsets 那些空间。
        var titleTotalSize = CGSize.zero // 包含 titleEdgeInsets 那些空间。
        // 如果图片或文字某一者没显示，则这个 spacing 不考虑进布局。
        let spacingBetweenImageAndTitle: CGFloat = (isImageViewShowing && isTitleLabelShowing) ? FSFlat(self.spacingBetweenImageAndTitle) : 0.0
        let contentEdgeInsets = p_UIEdgeInsetsRemoveFloatMin(self.contentEdgeInsets)
        var resultSize = CGSize.zero
        let contentLimitSize = CGSize(width: size.width - (contentEdgeInsets.left + contentEdgeInsets.right),
                                      height: size.height - (contentEdgeInsets.top + contentEdgeInsets.bottom))
        switch imagePosition {
        case .top, .bottom:
            // 图片和文字上下排版时，宽度以文字或图片的最大宽度为最终宽度。
            if isImageViewShowing {
                let imageLimitWidth = contentLimitSize.width - (imageEdgeInsets.left + imageEdgeInsets.right)
                var imageSize: CGSize = {
                    if let imageView = self.imageView {
                        return imageView.sizeThatFits(CGSize(width: imageLimitWidth, height: CGFloat.greatestFiniteMagnitude))
                    }
                    return currentImage?.size ?? .zero
                }()
                imageSize.width = min(imageSize.width, imageLimitWidth)
                imageTotalSize = .init(width: imageSize.width + (imageEdgeInsets.left + imageEdgeInsets.right),
                                       height: imageSize.height + (imageEdgeInsets.top + imageEdgeInsets.bottom))
            }
            if isTitleLabelShowing {
                let titleLimitSize = CGSize(width: contentLimitSize.width - (titleEdgeInsets.left + titleEdgeInsets.right),
                                            height: contentLimitSize.height - imageTotalSize.height - spacingBetweenImageAndTitle - (titleEdgeInsets.top + titleEdgeInsets.bottom))
                var titleSize: CGSize = {
                    if let label = titleLabel {
                        return label.sizeThatFits(titleLimitSize)
                    }
                    return .zero
                }()
                titleSize.height = min(titleSize.height, titleLimitSize.height)
                titleTotalSize = .init(width: titleSize.width + (titleEdgeInsets.left + titleEdgeInsets.right),
                                       height: titleSize.height + (titleEdgeInsets.top + titleEdgeInsets.bottom))
            }
            resultSize.width = (contentEdgeInsets.left + contentEdgeInsets.right) + max(imageTotalSize.width, titleTotalSize.width)
            resultSize.height = (contentEdgeInsets.top + contentEdgeInsets.bottom) + imageTotalSize.height + spacingBetweenImageAndTitle + titleTotalSize.height
        case .left, .right:
            // 图片和文字水平排版时，高度以文字或图片的最大高度为最终高度。
            // 注意这里有一个和系统不一致的行为：当 titleLabel 为多行时，系统的 sizeThatFits: 计算结果固定是单行的，
            // 所以当 FSButton.ImagePosition.left 并且 titleLabel 多行的情况下，FSButton 计算的结果与系统不一致。
            if isImageViewShowing {
                let imageLimitHeight = contentLimitSize.height - (imageEdgeInsets.top + imageEdgeInsets.bottom)
                var imageSize: CGSize = {
                    if let imageView = self.imageView {
                        return imageView.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: imageLimitHeight))
                    }
                    return currentImage?.size ?? .zero
                }()
                imageSize.height = min(imageSize.height, imageLimitHeight)
                imageTotalSize = .init(width: imageSize.width + (imageEdgeInsets.left + imageEdgeInsets.right),
                                       height: imageSize.height + (imageEdgeInsets.top + imageEdgeInsets.bottom))
            }
            if isTitleLabelShowing {
                let titleLimitSize = CGSize(width: contentLimitSize.width - (titleEdgeInsets.left + titleEdgeInsets.right) - imageTotalSize.width - spacingBetweenImageAndTitle,
                                            height: contentLimitSize.height - (titleEdgeInsets.top + titleEdgeInsets.bottom))
                var titleSize: CGSize = {
                    if let label = titleLabel {
                        return label.sizeThatFits(titleLimitSize)
                    }
                    return .zero
                }()
                titleSize.height = min(titleSize.height, titleLimitSize.height)
                titleTotalSize = .init(width: titleSize.width + (titleEdgeInsets.left + titleEdgeInsets.right),
                                       height: titleSize.height + (titleEdgeInsets.top + titleEdgeInsets.bottom))
            }
            resultSize.width = (contentEdgeInsets.left + contentEdgeInsets.right) + imageTotalSize.width + spacingBetweenImageAndTitle + titleTotalSize.width
            resultSize.height = (contentEdgeInsets.top + contentEdgeInsets.bottom) + max(imageTotalSize.height, titleTotalSize.height)
        }
        
        return resultSize
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        if bounds.isEmpty {
            return
        }
        let isImageViewShowing: Bool = {
            if let _ = currentImage {
                return true
            }
            return false
        }()
        let isTitleLabelShowing: Bool = {
            if let title = currentTitle, !title.isEmpty {
                return true
            }
            if let title_att = currentAttributedTitle, !title_att.string.isEmpty {
                return true
            }
            return false
        }()
        do {
            // Fix: 有时候，在 `layoutSubviews` 方法内有可能会得到错误的 bounds，需要把子控件调用一次布局才行。
            if isImageViewShowing {
                imageView?.layoutIfNeeded()
            }
            if isTitleLabelShowing {
                titleLabel?.layoutIfNeeded()
            }
        }
        var imageLimitSize = CGSize.zero
        var titleLimitSize = CGSize.zero
        var imageTotalSize = CGSize.zero // 包含 imageEdgeInsets 那些空间。
        var titleTotalSize = CGSize.zero // 包含 titleEdgeInsets 那些空间。
        // 如果图片或文字某一者没显示，则这个 spacing 不考虑进布局。
        let spacingBetweenImageAndTitle: CGFloat = FSFlat((isImageViewShowing && isTitleLabelShowing) ? self.spacingBetweenImageAndTitle : 0.0)
        var imageFrame = CGRect.zero
        var titleFrame = CGRect.zero
        let contentEdgeInsets = p_UIEdgeInsetsRemoveFloatMin(self.contentEdgeInsets)
        let contentSize = CGSize(width: bounds.width - (contentEdgeInsets.left + contentEdgeInsets.right),
                                 height: bounds.height - (contentEdgeInsets.top + contentEdgeInsets.bottom))
        
        // 图片的布局原则都是尽量完整展示，所以不管 imagePosition 的值是什么，这个计算过程都是相同的。
        if isImageViewShowing {
            imageLimitSize = .init(width: contentSize.width - (imageEdgeInsets.left + imageEdgeInsets.right),
                                   height: contentSize.height - (imageEdgeInsets.top + imageEdgeInsets.bottom))
            var imageSize: CGSize = {
                if let imageView = self.imageView {
                    return imageView.sizeThatFits(imageLimitSize)
                }
                return currentImage?.size ?? .zero
            }()
            imageSize.width = min(imageLimitSize.width, imageSize.width)
            imageSize.height = min(imageLimitSize.height, imageSize.height)
            imageFrame = CGRect(origin: .zero, size: imageSize)
            imageTotalSize = .init(width: imageSize.width + (imageEdgeInsets.left + imageEdgeInsets.right),
                                   height: imageSize.height + (imageEdgeInsets.top + imageEdgeInsets.bottom))
        }
        
        if imagePosition == .top || imagePosition == .bottom {
            if isTitleLabelShowing {
                titleLimitSize = .init(width: contentSize.width - (titleEdgeInsets.left + titleEdgeInsets.right),
                                       height: contentSize.height - imageTotalSize.height - spacingBetweenImageAndTitle - (titleEdgeInsets.top + titleEdgeInsets.bottom))
                var titleSize: CGSize = {
                    if let label = titleLabel {
                        return label.sizeThatFits(titleLimitSize)
                    }
                    return .zero
                }()
                titleSize.width = min(titleLimitSize.width, titleSize.width)
                titleSize.height = min(titleLimitSize.height, titleSize.height)
                titleFrame = CGRect(origin: .zero, size: titleSize)
                titleTotalSize = .init(width: titleSize.width + (titleEdgeInsets.left + titleEdgeInsets.right),
                                       height: titleSize.height + (titleEdgeInsets.top + titleEdgeInsets.bottom))
            }
            switch contentHorizontalAlignment {
            case .left:
                if isImageViewShowing {
                    imageFrame.origin.x = contentEdgeInsets.left + imageEdgeInsets.left
                }
                if isTitleLabelShowing {
                    titleFrame.origin.x = contentEdgeInsets.left + titleEdgeInsets.left
                }
            case .center:
                if isImageViewShowing {
                    imageFrame.origin.x = contentEdgeInsets.left + imageEdgeInsets.left + p_CGFloatGetCenter(imageLimitSize.width, imageFrame.width)
                }
                if isTitleLabelShowing {
                    titleFrame.origin.x = contentEdgeInsets.left + titleEdgeInsets.left + p_CGFloatGetCenter(titleLimitSize.width, titleFrame.width)
                }
            case .right:
                if isImageViewShowing {
                    imageFrame.origin.x = bounds.width - contentEdgeInsets.right - imageEdgeInsets.right - imageFrame.width
                }
                if isTitleLabelShowing {
                    titleFrame.origin.x = bounds.width - contentEdgeInsets.right - titleEdgeInsets.right - titleFrame.width
                }
            case .fill:
                if isImageViewShowing {
                    imageFrame.origin.x = contentEdgeInsets.left + imageEdgeInsets.left
                    imageFrame.size.width = imageLimitSize.width
                }
                if isTitleLabelShowing {
                    titleFrame.origin.x = contentEdgeInsets.left + titleEdgeInsets.left
                    titleFrame.size.width = titleLimitSize.width
                }
            default:
                break
            }
            
            if imagePosition == .top {
                switch contentVerticalAlignment {
                case .top:
                    if isImageViewShowing {
                        imageFrame.origin.y =  contentEdgeInsets.top + imageEdgeInsets.top
                    }
                    if isTitleLabelShowing {
                        titleFrame.origin.y = contentEdgeInsets.top + imageTotalSize.height + spacingBetweenImageAndTitle + titleEdgeInsets.top
                    }
                case .center:
                    let contentHeight = imageTotalSize.height + spacingBetweenImageAndTitle + titleTotalSize.height
                    let minY = p_CGFloatGetCenter(contentSize.height, contentHeight) + contentEdgeInsets.top
                    if isImageViewShowing {
                        imageFrame.origin.y = minY + imageEdgeInsets.top
                    }
                    if isTitleLabelShowing {
                        titleFrame.origin.y = minY + imageTotalSize.height + spacingBetweenImageAndTitle + titleEdgeInsets.top
                    }
                case .bottom:
                    if isImageViewShowing {
                        imageFrame.origin.y = bounds.height - contentEdgeInsets.bottom - titleTotalSize.height - spacingBetweenImageAndTitle - imageEdgeInsets.bottom - imageFrame.height
                    }
                    if isTitleLabelShowing {
                        titleFrame.origin.y = bounds.height - contentEdgeInsets.bottom - titleEdgeInsets.bottom - titleFrame.height
                    }
                case .fill:
                    if isImageViewShowing && isTitleLabelShowing {
                        // 同时显示图片和 label 的情况下，图片高度按本身大小显示，剩余空间留给 label。
                        if isImageViewShowing {
                            imageFrame.origin.y = contentEdgeInsets.top + imageEdgeInsets.top
                        }
                        if isTitleLabelShowing {
                            titleFrame.origin.y = contentEdgeInsets.top + imageTotalSize.height + spacingBetweenImageAndTitle + titleEdgeInsets.top
                            titleFrame.size.height = bounds.height - contentEdgeInsets.bottom - titleEdgeInsets.bottom - titleFrame.minY
                        }
                    } else if isImageViewShowing {
                        imageFrame.origin.y = contentEdgeInsets.top + imageEdgeInsets.top
                        imageFrame.size.height = contentSize.height - (imageEdgeInsets.top + imageEdgeInsets.bottom)
                    } else {
                        titleFrame.origin.y = contentEdgeInsets.top + titleEdgeInsets.top
                        titleFrame.size.height = contentSize.height - (titleEdgeInsets.top + titleEdgeInsets.bottom)
                    }
                default:
                    break
                }
            } else {
                switch contentVerticalAlignment {
                case .top:
                    if isImageViewShowing {
                        imageFrame.origin.y = contentEdgeInsets.top + titleTotalSize.height + spacingBetweenImageAndTitle + imageEdgeInsets.top
                    }
                    if isTitleLabelShowing {
                        titleFrame.origin.y = contentEdgeInsets.top + titleEdgeInsets.top
                    }
                case .center:
                    let contentHeight = imageTotalSize.height + titleTotalSize.height + spacingBetweenImageAndTitle
                    let minY = p_CGFloatGetCenter(contentSize.height, contentHeight) + contentEdgeInsets.top
                    if isImageViewShowing {
                        imageFrame.origin.y = minY + titleTotalSize.height + spacingBetweenImageAndTitle + imageEdgeInsets.top
                    }
                    if isTitleLabelShowing {
                        titleFrame.origin.y = minY + titleEdgeInsets.top
                    }
                case .bottom:
                    if isImageViewShowing {
                        imageFrame.origin.y = bounds.height - contentEdgeInsets.bottom - imageEdgeInsets.bottom - imageFrame.height
                    }
                    if isTitleLabelShowing {
                        titleFrame.origin.y = bounds.height - contentEdgeInsets.bottom - imageTotalSize.height - spacingBetweenImageAndTitle - titleEdgeInsets.bottom - titleFrame.height
                    }
                case .fill:
                    if isImageViewShowing && isTitleLabelShowing {
                        // 同时显示图片和 label 的情况下，图片高度按本身大小显示，剩余空间留给 label。
                        imageFrame.origin.y = bounds.height - contentEdgeInsets.bottom - imageEdgeInsets.bottom - imageFrame.height
                        titleFrame.origin.y = contentEdgeInsets.top + titleEdgeInsets.top
                        titleFrame.size.height = bounds.height - contentEdgeInsets.bottom - imageTotalSize.height - spacingBetweenImageAndTitle - titleEdgeInsets.bottom - titleFrame.minY
                    } else if isImageViewShowing {
                        imageFrame.origin.y = contentEdgeInsets.top + imageEdgeInsets.top
                        imageFrame.size.height = contentSize.height - (imageEdgeInsets.top + imageEdgeInsets.bottom)
                    } else {
                        titleFrame.origin.y = contentEdgeInsets.top + titleEdgeInsets.top
                        titleFrame.size.height = contentSize.height - (titleEdgeInsets.top + titleEdgeInsets.bottom)
                    }
                default:
                    break
                }
            }
            
            if isImageViewShowing {
                imageView?.frame = imageFrame.fs.flatted()
            }
            if isTitleLabelShowing {
                titleLabel?.frame = titleFrame.fs.flatted()
            }
        } else {
            if isTitleLabelShowing {
                titleLimitSize = .init(width: contentSize.width - (titleEdgeInsets.left + titleEdgeInsets.right) - imageTotalSize.width - spacingBetweenImageAndTitle,
                                       height: contentSize.height - (titleEdgeInsets.top + titleEdgeInsets.bottom))
                var titleSize: CGSize = {
                    if let label = titleLabel {
                        return label.sizeThatFits(titleLimitSize)
                    }
                    return .zero
                }()
                titleSize.width = min(titleLimitSize.width, titleSize.width)
                titleSize.height = min(titleLimitSize.height, titleSize.height)
                titleFrame = CGRect(origin: .zero, size: titleSize)
                titleTotalSize = .init(width: titleSize.width + (titleEdgeInsets.left + titleEdgeInsets.right),
                                       height: titleSize.height + (titleEdgeInsets.top + titleEdgeInsets.bottom))
            }
            
            switch contentVerticalAlignment {
            case .top:
                if isImageViewShowing {
                    imageFrame.origin.y = contentEdgeInsets.top + imageEdgeInsets.top
                }
                if isTitleLabelShowing {
                    titleFrame.origin.y = contentEdgeInsets.top + titleEdgeInsets.top
                }
            case .center:
                if isImageViewShowing {
                    imageFrame.origin.y = contentEdgeInsets.top + p_CGFloatGetCenter(contentSize.height, imageFrame.height) + imageEdgeInsets.top
                }
                if isTitleLabelShowing {
                    titleFrame.origin.y = contentEdgeInsets.top + p_CGFloatGetCenter(contentSize.height, titleFrame.height) + titleEdgeInsets.top
                }
            case .bottom:
                if isImageViewShowing {
                    imageFrame.origin.y = bounds.height - contentEdgeInsets.bottom - imageEdgeInsets.bottom - imageFrame.height
                }
                if isTitleLabelShowing {
                    titleFrame.origin.y = bounds.height - contentEdgeInsets.bottom - titleEdgeInsets.bottom - titleFrame.height
                }
            case .fill:
                if isImageViewShowing {
                    imageFrame.origin.y = contentEdgeInsets.top + imageEdgeInsets.top
                    imageFrame.size.height = contentSize.height - (imageEdgeInsets.top + imageEdgeInsets.bottom)
                }
                if isTitleLabelShowing {
                    titleFrame.origin.y = contentEdgeInsets.top + titleEdgeInsets.top
                    titleFrame.size.height = contentSize.height - (titleEdgeInsets.top + titleEdgeInsets.bottom)
                }
            default:
                break
            }
            
            let leftOperation: () -> Void = {
                switch self.contentHorizontalAlignment {
                case .left:
                    if isImageViewShowing {
                        imageFrame.origin.x = contentEdgeInsets.left + self.imageEdgeInsets.left
                    }
                    if isTitleLabelShowing {
                        titleFrame.origin.x = contentEdgeInsets.left + imageTotalSize.width + spacingBetweenImageAndTitle + self.titleEdgeInsets.left
                    }
                case .center:
                    let contentWidth = imageTotalSize.width + spacingBetweenImageAndTitle + titleTotalSize.width
                    let minX = contentEdgeInsets.left + self.p_CGFloatGetCenter(contentSize.width, contentWidth)
                    if isImageViewShowing {
                        imageFrame.origin.x = minX + self.imageEdgeInsets.left
                    }
                    if isTitleLabelShowing {
                        titleFrame.origin.x = minX + imageTotalSize.width + spacingBetweenImageAndTitle + self.titleEdgeInsets.left
                    }
                case .right:
                    if (imageTotalSize.width + spacingBetweenImageAndTitle + titleTotalSize.width) > contentSize.width {
                        // 图片和文字总宽超过按钮宽度，则优先完整显示图片。
                        if isImageViewShowing {
                            imageFrame.origin.x = contentEdgeInsets.left + self.imageEdgeInsets.left
                        }
                        if isTitleLabelShowing {
                            titleFrame.origin.x = contentEdgeInsets.left + imageTotalSize.width + spacingBetweenImageAndTitle + self.titleEdgeInsets.left
                        }
                    } else {
                        // 内容不超过按钮宽度，则靠右布局即可。
                        if isImageViewShowing {
                            imageFrame.origin.x = self.bounds.width - contentEdgeInsets.right - titleTotalSize.width - spacingBetweenImageAndTitle - imageTotalSize.width + self.imageEdgeInsets.left
                        }
                        if isTitleLabelShowing {
                            titleFrame.origin.x = self.bounds.width - contentEdgeInsets.right - self.titleEdgeInsets.right - titleFrame.width
                        }
                    }
                case .fill:
                    if isImageViewShowing && isTitleLabelShowing {
                        // 同时显示图片和 label 的情况下，图片按本身宽度显示，剩余空间留给 label。
                        imageFrame.origin.x = contentEdgeInsets.left + self.imageEdgeInsets.left
                        titleFrame.origin.x = contentEdgeInsets.left + imageTotalSize.width + spacingBetweenImageAndTitle + self.titleEdgeInsets.left
                        titleFrame.size.width = self.bounds.width - contentEdgeInsets.right - self.titleEdgeInsets.right - titleFrame.minX
                    } else if isImageViewShowing {
                        imageFrame.origin.x = contentEdgeInsets.left + self.imageEdgeInsets.left
                        imageFrame.size.width = contentSize.width - (self.imageEdgeInsets.left + self.imageEdgeInsets.right)
                    } else {
                        titleFrame.origin.x = contentEdgeInsets.left + self.titleEdgeInsets.left
                        titleFrame.size.width = contentSize.width - (self.titleEdgeInsets.left + self.titleEdgeInsets.right)
                    }
                default:
                    break
                }
            }
            let rightOperation: () -> Void = {
                switch self.contentHorizontalAlignment {
                case .left:
                    if (imageTotalSize.width + spacingBetweenImageAndTitle + titleTotalSize.width) > contentSize.width {
                        // 图片和文字总宽超过按钮宽度，则优先完整显示图片。
                        if isImageViewShowing {
                            imageFrame.origin.x = self.bounds.width - contentEdgeInsets.right - self.imageEdgeInsets.right - imageFrame.width
                        }
                        if isTitleLabelShowing {
                            titleFrame.origin.x = self.bounds.width - contentEdgeInsets.right - imageTotalSize.width - spacingBetweenImageAndTitle - titleTotalSize.width + self.titleEdgeInsets.left
                        }
                    } else {
                        // 内容不超过按钮宽度，则靠左布局即可。
                        if isImageViewShowing {
                            imageFrame.origin.x = contentEdgeInsets.left + titleTotalSize.width + spacingBetweenImageAndTitle + self.imageEdgeInsets.left
                        }
                        if isTitleLabelShowing {
                            titleFrame.origin.x = contentEdgeInsets.left + self.titleEdgeInsets.left
                        }
                    }
                case .center:
                    let contentWidth = imageTotalSize.width + spacingBetweenImageAndTitle + titleTotalSize.width
                    let minX = contentEdgeInsets.left + self.p_CGFloatGetCenter(contentSize.width, contentWidth)
                    if isImageViewShowing {
                        imageFrame.origin.x = minX + titleTotalSize.width + spacingBetweenImageAndTitle + self.imageEdgeInsets.left
                    }
                    if isTitleLabelShowing {
                        titleFrame.origin.x = minX + self.titleEdgeInsets.left
                    }
                case .right:
                    if isImageViewShowing {
                        imageFrame.origin.x = self.bounds.width - contentEdgeInsets.right - self.imageEdgeInsets.right - imageFrame.width
                    }
                    if isTitleLabelShowing {
                        titleFrame.origin.x = self.bounds.width - contentEdgeInsets.right - imageTotalSize.width - spacingBetweenImageAndTitle - self.titleEdgeInsets.right - titleFrame.width
                    }
                case .fill:
                    if isImageViewShowing && isTitleLabelShowing {
                        // 图片按自身大小显示，剩余空间由标题占满。
                        imageFrame.origin.x = self.bounds.width - contentEdgeInsets.right - self.imageEdgeInsets.right - imageFrame.width
                        titleFrame.origin.x = contentEdgeInsets.left + self.titleEdgeInsets.left
                        titleFrame.size.width = imageFrame.minX - self.imageEdgeInsets.left - spacingBetweenImageAndTitle - self.titleEdgeInsets.right - titleFrame.minX
                    } else if isImageViewShowing {
                        imageFrame.origin.x = contentEdgeInsets.left + self.imageEdgeInsets.left
                        imageFrame.size.width = contentSize.width - (self.imageEdgeInsets.left + self.imageEdgeInsets.right)
                    } else {
                        titleFrame.origin.x = contentEdgeInsets.left + self.titleEdgeInsets.left
                        titleFrame.size.width = contentSize.width - (self.titleEdgeInsets.left + self.titleEdgeInsets.right)
                    }
                default:
                    break
                }
            }
            
            if semanticContentAttribute == .forceRightToLeft {
                if imagePosition == .left {
                    rightOperation()
                } else {
                    leftOperation()
                }
            } else {
                if imagePosition == .left {
                    leftOperation()
                } else {
                    rightOperation()
                }
            }
            
            if isImageViewShowing {
                imageView?.frame = imageFrame.fs.flatted()
            }
            if isTitleLabelShowing {
                titleLabel?.frame = titleFrame.fs.flatted()
            }
        }
    }
    
    // MARK: - Open
    
    /// 初始化后调用。
    /// 子类可重写该方法做初始化操作。
    ///
    /// - Note: 不建议子类重写 `init` 方法。
    ///
    open func didInitialize() {
        // 子类实现。
    }
}

// MARK: - Private

private extension FSButton {
    
    func p_didInitialize() {
        do {
            // 默认接管 highlighted 和 disabled 的表现，去掉系统默认的表现。
            adjustsImageWhenHighlighted = false
            adjustsImageWhenDisabled = false
            
            isExclusiveTouch = true
            tintColor = UIColor(red: 49.0/255.0, green: 189.0/255.0, blue: 243.0/255.0, alpha: 1.0)
        }
        didInitialize()
        do {
            if adjustsTitleTintColorAutomatically {
                setTitleColor(tintColor, for: .normal)
            }
            // iOS7 以后的 button，sizeToFit 后默认会自带一个上下的 contentInsets，为了保证按钮大小即为内容大小，这里直接去掉，改为一个最小的值。
            contentEdgeInsets = .init(top: CGFloat.leastNormalMagnitude, left: 0.0, bottom: CGFloat.leastNormalMagnitude, right: 0.0)
        }
    }
    
    func p_adjustsButtonHighlighted() {
        if let color = highlightedBackgroundColor {
            func setLayer(_ layer: CALayer) {
                layer.frame = bounds
                layer.cornerRadius = self.layer.cornerRadius
                layer.backgroundColor = (isHighlighted ? color.cgColor : UIColor.clear.cgColor)
            }
            if let layer = highlightedBackgroundLayer {
                setLayer(layer)
            } else {
                highlightedBackgroundLayer = CALayer()
                highlightedBackgroundLayer?.fs.removeDefaultAnimations()
                layer.insertSublayer(highlightedBackgroundLayer!, at: 0)
                setLayer(highlightedBackgroundLayer!)
            }
        }
        if let color = highlightedBorderColor {
            layer.borderColor = (isHighlighted ? color.cgColor : (originalBorderColor ?? UIColor.clear).cgColor)
        }
    }
    
    func p_updateTitleColorIfNeeded() {
        if adjustsTitleTintColorAutomatically {
            setTitleColor(tintColor, for: .normal)
        }
        if let title_att = currentAttributedTitle, !title_att.string.isEmpty, let tintColor = tintColor, adjustsTitleTintColorAutomatically {
            let att_string = NSMutableAttributedString(attributedString: title_att)
            att_string.addAttribute(NSAttributedString.Key.foregroundColor, value: tintColor, range: NSRange(location: 0, length: att_string.length))
            setAttributedTitle(att_string, for: .normal)
        }
    }
    
    func p_updateImageRenderingModeIfNeeded() {
        guard let _ = currentImage else { return }
        let states: [UIControl.State] = [
            .normal,
            .highlighted,
            .selected,
            [.selected, .highlighted],
            .disabled
        ]
        for state in states {
            if let image = image(for: state) {
                if adjustsImageTintColorAutomatically {
                    // 这里的 setImage: 操作不需要使用 renderingMode 对 image 重新处理，而是放到重写的 `setImage:forState` 里去做就行了。
                    setImage(image, for: state)
                } else {
                    // 如果不需要用 template 的模式渲染，并且之前是使用 template 的，则把 renderingMode 改回 Original。
                    setImage(image.withRenderingMode(.alwaysOriginal), for: state)
                }
            }
        }
    }
    
    func p_UIEdgeInsetsRemoveFloatMin(_ insets: UIEdgeInsets) -> UIEdgeInsets {
        func removeFloatMin(_ float: CGFloat) -> CGFloat {
            return ((float == CGFloat.leastNormalMagnitude) ? 0.0 : float)
        }
        return UIEdgeInsets(top: removeFloatMin(insets.top),
                            left: removeFloatMin(insets.left),
                            bottom: removeFloatMin(insets.bottom),
                            right: removeFloatMin(insets.right))
    }
    
    /// 居中运算
    func p_CGFloatGetCenter(_ parent: CGFloat, _ child: CGFloat) -> CGFloat {
        return FSFlat((parent - child) / 2.0)
    }
}
