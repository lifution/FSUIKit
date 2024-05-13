//
//  FSCollectionViewWaterfallLayout.swift
//  FSUIKitSwift
//
//  Created by Sheng on 2024/3/31.
//  Copyright © 2024 Sheng. All rights reserved.
//

import UIKit

/// 瀑布流布局。
///
/// - TODO:
///   - Supports horizontal direction.
///   - Perfects collectionView updates.
///
open class FSCollectionViewWaterfallLayout: UICollectionViewLayout {
    
    // MARK: Properties/Public
    
    public final weak var delegate: FSCollectionViewWaterfallLayoutDelegate? {
        didSet {
            if let _ = collectionView, collectionViewSize != .zero {
                invalidateLayout()
            }
        }
    }
    
    /// 列数。
    ///
    /// - Note:
    ///   - 如果没有实现 delegate，则使用该属性。
    ///   - 该属性用于方便外部直接配置所有 section 为同一样式，layout 内部不会修改该属性。
    ///
    public final var numberOfColumns = 0 {
        didSet {
            if delegate == nil, numberOfColumns != oldValue, collectionViewSize != .zero {
                invalidateLayout()
            }
        }
    }
    
    /// item 高度。
    ///
    /// - Note:
    ///   - 如果没有实现 delegate，则使用该属性。
    ///   - 该属性用于方便外部直接配置所有 section 为同一样式，layout 内部不会修改该属性。
    ///
    public final var itemHeight: CGFloat = 50.0 {
        didSet {
            if delegate == nil, itemHeight != oldValue, collectionViewSize != .zero {
                invalidateLayout()
            }
        }
    }
    
    /// item 垂直方向间距。
    ///
    /// - Note:
    ///   - 如果没有实现 delegate，则使用该属性。
    ///   - 该属性用于方便外部直接配置所有 section 为同一样式，layout 内部不会修改该属性。
    ///
    public final var lineSpacing: CGFloat = 8.0 {
        didSet {
            if delegate == nil, lineSpacing != oldValue, collectionViewSize != .zero {
                invalidateLayout()
            }
        }
    }
    
    /// item 水平方向间距。
    ///
    /// - Note:
    ///   - 如果没有实现 delegate，则使用该属性。
    ///   - 该属性用于方便外部直接配置所有 section 为同一样式，layout 内部不会修改该属性。
    ///
    public final var interitemSpacing: CGFloat = 8.0 {
        didSet {
            if delegate == nil, interitemSpacing != oldValue, collectionViewSize != .zero {
                invalidateLayout()
            }
        }
    }
    
    /// section inset。
    ///
    /// - Note:
    ///   - 如果没有实现 delegate，则使用该属性。
    ///   - 该属性用于方便外部直接配置所有 section 为同一样式，layout 内部不会修改该属性。
    ///
    public final var sectionInset: UIEdgeInsets = .init(top: 12.0, left: 12.0, bottom: 12.0, right: 12.0) {
        didSet {
            if delegate == nil, sectionInset != oldValue, collectionViewSize != .zero {
                invalidateLayout()
            }
        }
    }
    
    /// section header size。
    ///
    /// - Note:
    ///   - 如果没有实现 delegate，则使用该属性。
    ///   - 该属性用于方便外部直接配置所有 section 为同一样式，layout 内部不会修改该属性。
    ///
    public final var headerSize: CGSize = .zero {
        didSet {
            if delegate == nil, headerSize != oldValue, collectionViewSize != .zero {
                invalidateLayout()
            }
        }
    }
    
    /// section header size。
    ///
    /// - Note:
    ///   - 如果没有实现 delegate，则使用该属性。
    ///   - 该属性用于方便外部直接配置所有 section 为同一样式，layout 内部不会修改该属性。
    ///
    public final var footerSize: CGSize = .zero {
        didSet {
            if delegate == nil, footerSize != oldValue, collectionViewSize != .zero {
                invalidateLayout()
            }
        }
    }
    
    /// 是否开启插入动画，默认为 true。
    public var isInsertionAnimationEnabled = true
    
    // MARK: Properties/Private
    
    private var sections = [_Section]()
    private var shouldReprepare = true
    private var contentSize: CGSize = .zero
    private var collectionViewSize: CGSize = .zero
    private var insertingIndexPaths = [IndexPath]()
    
    // MARK: Initialization
    
    public override init() {
        super.init()
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Override

extension FSCollectionViewWaterfallLayout {
    
    open override var collectionViewContentSize: CGSize {
        return contentSize
    }
    
    open override func invalidateLayout() {
        shouldReprepare = true
        super.invalidateLayout()
    }
    
    open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        if collectionViewSize != newBounds.size {
            shouldReprepare = true
            return true
        }
        return false
    }
    
    open override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard
            indexPath.section >= 0,
            indexPath.section < sections.count
        else {
            return nil
        }
        let section = sections[indexPath.section]
        guard
            indexPath.item >= 0,
            indexPath.item < section.items.count
        else {
            return nil
        }
        return section.items[indexPath.item]
    }
    
    open override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard
            indexPath.section >= 0,
            indexPath.section < sections.count
        else {
            return nil
        }
        let section = sections[indexPath.section]
        switch elementKind {
        case UICollectionView.elementKindSectionHeader:
            return section.header
        case UICollectionView.elementKindSectionFooter:
            return section.footer
        default:
            return nil
        }
    }
    
    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributes = [UICollectionViewLayoutAttributes]()
        attributes += sections.flatMap { $0.items }.filter { $0.frame.intersects(rect) }
        attributes += sections.compactMap { $0.header }.filter { $0.frame.intersects(rect) }
        attributes += sections.compactMap { $0.footer }.filter { $0.frame.intersects(rect) }
        return attributes
    }
    
    open override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        if isInsertionAnimationEnabled {
            insertingIndexPaths.removeAll()
            insertingIndexPaths = updateItems.filter {
                return ($0.indexPathAfterUpdate != nil && $0.updateAction == .insert)
            }.compactMap { $0.indexPathAfterUpdate }
        }
        shouldReprepare = true
        prepare()
    }
    
    open override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard
            itemIndexPath.section >= 0,
            itemIndexPath.section < sections.count
        else {
            return nil
        }
        let section = sections[itemIndexPath.section]
        guard
            itemIndexPath.item >= 0,
            itemIndexPath.item < section.items.count,
            let attributes = section.items[itemIndexPath.item].copy() as? UICollectionViewLayoutAttributes
        else {
            return nil
        }
        if isInsertionAnimationEnabled, insertingIndexPaths.contains(itemIndexPath) {
            attributes.alpha = 0.3
            attributes.transform = CGAffineTransform(translationX: 0.0, y: 50.0)
        }
        return attributes
    }
    
    open override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard
            itemIndexPath.section >= 0,
            itemIndexPath.section < sections.count
        else {
            return nil
        }
        let section = sections[itemIndexPath.section]
        guard
            itemIndexPath.item >= 0,
            itemIndexPath.item < section.items.count
        else {
            return nil
        }
        return section.items[itemIndexPath.item]
    }
    
    open override func finalizeCollectionViewUpdates() {
        insertingIndexPaths.removeAll()
    }
    
    open override func prepare() {
        guard shouldReprepare else {
            return
        }
        
        var sections = [_Section]()
        var contentSize: CGSize = .zero
        
        defer {
            self.sections.removeAll()
            self.sections += sections
            self.contentSize = contentSize
            /// Fix:
            /// UICollectionView 调用 `insertItems` 刷新 UI 时，
            /// collectionView.contentSize 和 layout.collectionViewContentSize 会不同步。
            collectionView?.contentSize = contentSize
        }
        
        guard let collectionView = self.collectionView else {
            return
        }
        
        shouldReprepare = false
        collectionViewSize = collectionView.bounds.size
        
        let numberOfSections = collectionView.numberOfSections
        var contentHeight: CGFloat = 0.0
        
        for section in 0..<numberOfSections {
            let sectionObj = _Section()
            let sectionInset = p_sectionInset(in: section)
            do {
                let size = p_headerSize(in: section)
                if size.height > 0 {
                    let indexPath = IndexPath(item: 0, section: section)
                    let header = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, with: indexPath)
                    header.frame.origin = .init(x: 0.0, y: contentHeight)
                    header.frame.size = .init(width: collectionViewSize.width, height: size.height)
                    sectionObj.header = header
                    contentHeight = header.frame.maxY
                }
            }
            let numberOfItems = collectionView.numberOfItems(inSection: section)
            let numberOfColumns = p_numberOfColumns(in: section)
            let itemWidth = p_itemWidth(in: section)
            let lineSpacing = p_lineSpacing(in: section)
            let interitemSpacing = p_interitemSpacing(in: section)
            let initialY = contentHeight + sectionInset.top
            var columnMaxYs = [Int: CGFloat]()
            do {
                /// Initial value for each column.
                /// columnMaxYs would be never empty as numberOfColumns would be never 0 in here.
                (0..<numberOfColumns).forEach { columnMaxYs[$0] = initialY }
            }
            if numberOfItems > 0, numberOfColumns > 0 {
                for item in 0..<numberOfItems {
                    let indexPath = IndexPath(item: item, section: section)
                    let itemHeight = p_itemHeight(at: indexPath)
                    let column: Int = {
                        var index = 0
                        var minY = columnMaxYs[0]!
                        for i in 0..<numberOfColumns {
                            if let y = columnMaxYs[i], y < minY {
                                minY = y
                                index = i
                            }
                        }
                        return index
                    }()
                    let x: CGFloat = {
                        let x = sectionInset.left + CGFloat(column) * (itemWidth + max(0.0, interitemSpacing))
                        if interitemSpacing > 0.0 {
                            return x
                        } else {
                            // Fix: 像素不对齐导致 cell 有可能顶到水平方向前一个 cell 的最后 1px(X轴)。
                            return _Flat(x)
                        }
                    }()
                    let y: CGFloat = {
                        var y = columnMaxYs[column]!
                        if y == initialY {
                            return y
                        } else {
                            y += max(0.0, lineSpacing)
                        }
                        if lineSpacing > 0.0 {
                            return y
                        } else {
                            // Fix: 像素不对齐导致 cell 有可能顶到垂直方向前一个 cell 的最后 1px(Y轴)。
                            return _Flat(y)
                        }
                    }()
                    let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                    attributes.frame.size = .init(width: itemWidth, height: itemHeight)
                    attributes.frame.origin = .init(x: x, y: y)
                    columnMaxYs[column] = attributes.frame.maxY
                    sectionObj.items.append(attributes)
                }
            }
            let itemsMaxY: CGFloat = {
                var maxY: CGFloat = 0.0
                for y in columnMaxYs.values {
                    if y > maxY {
                        maxY = y
                    }
                }
                return maxY
            }()
            do {
                let size = p_footerSize(in: section)
                if size.height > 0 {
                    let indexPath = IndexPath(item: 0, section: section)
                    let footer = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, with: indexPath)
                    footer.frame.origin = .init(x: 0.0, y: _Flat(itemsMaxY + sectionInset.bottom))
                    footer.frame.size = .init(width: collectionViewSize.width, height: size.height)
                    sectionObj.footer = footer
                }
            }
            sections.append(sectionObj)
            contentHeight = _Flat({
                if let footer = sectionObj.footer {
                    return footer.frame.maxY
                }
                return itemsMaxY + sectionInset.bottom
            }())
        }
        
        contentSize.width = collectionViewSize.width
        contentSize.height = contentHeight
    }
}

// MARK: - Private

private extension FSCollectionViewWaterfallLayout {
    
    func p_numberOfColumns(in section: Int) -> Int {
        guard
            let delegate = delegate,
            let collection = collectionView
        else {
            return numberOfColumns
        }
        return delegate.collectionView(collection, layout: self, numberOfColumnsIn: section)
    }
    
    func p_sectionInset(in section: Int) -> UIEdgeInsets {
        guard
            let delegate = delegate,
            let collection = collectionView
        else {
            return sectionInset
        }
        return delegate.collectionView(collection, layout: self, insetForSectionAt: section)
    }
    
    func p_interitemSpacing(in section: Int) -> CGFloat {
        guard
            let delegate = delegate,
            let collection = collectionView
        else {
            return interitemSpacing
        }
        return delegate.collectionView(collection, layout: self, interitemSpacingForSectionAt: section)
    }
    
    func p_lineSpacing(in section: Int) -> CGFloat {
        guard
            let delegate = delegate,
            let collection = collectionView
        else {
            return lineSpacing
        }
        return delegate.collectionView(collection, layout: self, lineSpacingForSectionAt: section)
    }
    
    func p_itemHeight(at indexPath: IndexPath) -> CGFloat {
        guard
            let delegate = delegate,
            let collection = collectionView
        else {
            return itemHeight
        }
        return delegate.collectionView(collection, layout: self, heightForItemAt: indexPath)
    }
    
    func p_itemWidth(in section: Int) -> CGFloat {
        guard
            let collection = collectionView,
            section >= 0,
            section < collection.numberOfSections,
            collectionViewSize != .zero
        else {
            return 0.0
        }
        let numberOfColumns = p_numberOfColumns(in: section)
        if numberOfColumns <= 0 {
            return 0.0
        }
        let inset = p_sectionInset(in: section)
        let interitemSpacing = p_interitemSpacing(in: section)
        let itemWidth = (collectionViewSize.width - inset.fs.horizontalValue() - interitemSpacing * CGFloat(numberOfColumns - 1)) / CGFloat(numberOfColumns)
        return floor(itemWidth)
    }
    
    func p_headerSize(in section: Int) -> CGSize {
        guard
            let delegate = delegate,
            let collection = collectionView
        else {
            return headerSize
        }
        return delegate.collectionView(collection, layout: self, referenceSizeForHeaderInSection: section)
    }
    
    func p_footerSize(in section: Int) -> CGSize {
        guard
            let delegate = delegate,
            let collection = collectionView
        else {
            return footerSize
        }
        return delegate.collectionView(collection, layout: self, referenceSizeForFooterInSection: section)
    }
}

// MARK: - Public

public extension FSCollectionViewWaterfallLayout {
    
    /// 读取 section 的 item 宽度。
    ///
    /// - Note:
    ///   - 一个 section 的 numberOfColumns、sectionInset、interitemSpacing 一旦确定了，
    ///     那么该 section 的 item 宽度也就确定了。
    ///   - 如果该 section 的 numberOfColumns 为 0 则返回 0。
    ///   - 如果该 section 的 index 超出了 UICollectionView 的 section 数量，则返回 0。
    ///   - 如果 section 的 numberOfColumns、sectionInset、interitemSpacing 参数有变，
    ///     则该 section 的 item 宽度也一样会变化。
    ///   - 外部可通过该方法获取 section 的 item 宽度。
    ///
    func itemWidth(in section: Int) -> CGFloat {
        return p_itemWidth(in: section)
    }
}


// MARK: - _Section

private class _Section {
    var header: UICollectionViewLayoutAttributes?
    var footer: UICollectionViewLayoutAttributes?
    var items = [UICollectionViewLayoutAttributes]()
    init() {}
}


// MARK: - Flat

private func _Flat<T: FloatingPoint>(_ x: T) -> T {
    guard
        x != T.leastNormalMagnitude,
        x != T.leastNonzeroMagnitude,
        x != T.greatestFiniteMagnitude
    else {
        return x
    }
    let scale: T = T(Int(UIScreen.main.scale))
    let flattedValue = ceil(x * scale) / scale
    return flattedValue
}
