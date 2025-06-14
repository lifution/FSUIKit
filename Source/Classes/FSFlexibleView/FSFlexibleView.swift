//
//  FSFlexibleView.swift
//  FSUIKitSwift
//
//  Created by Sheng on 2024/3/13.
//  Copyright © 2024 Sheng. All rights reserved.
//

import UIKit

/// 该控件的使用场景为随意布局，比如九宫格。
///
/// - FSFlexibleView 是 data-driven 类型的控件，一个 FSFlexibleItem 对应一个 FSFlexibleCell。
/// - 每一个 FSFlexibleCell 的 frame 由 FSFlexibleItem 提供，因此要实现何种布局是完全由外部控制的。
/// - FSFlexibleView 会一次性全部展示所有的 cell，不会像 UITableView/UICollectionView 那样在显示范围内
///   的才展示。
/// - FSFlexibleView 内部实现了简单的重用机制，该重用机制和 UITableView/UICollectionView 的不一样，
///   FSFlexibleView 的重用机制仅仅是在 reload 时把上一次展示的 cell 缓存在重用池中，如果新展示的 cell 在
///   重用池中存在相同类型的 cell 则会使用重用池中的 cell（而不是创建新的 cell 对象）。
/// - 该控件无法滚动。
/// - 该控件仅适用于 item 数量比较少的情况下，比如图片九宫格等，如果 item 数量比较庞大，建议使用其它控件。
///
open class FSFlexibleView: UIView {
    
    // MARK: Properties/Public
    
    /// FSFlexibleView 的数据源。
    ///
    /// - 但该属性更新时，FSFlexibleView 会自动刷新。
    ///
    public final var items = [FSFlexibleItem]() {
        didSet {
            oldValue.forEach { $0.reloadHandler = nil }
            p_items = items
            p_setNeedsReload()
        }
    }
    
    /// 展示中的 cell 集合。
    ///
    /// - FSFlexibleView 会一次性展示全部的 cell，因此该属性表示的就是全部的 cell。
    ///
    public private(set) var visibleCells = [FSFlexibleCell]()
    
    /// 选中某个 cell 的回调。
    public final var onDidSelect: ((_ flexibleView: FSFlexibleView, _ item: FSFlexibleItem, _ index: Int) -> Void)?
    
    // MARK: Properties/Private
    
    private let tap = UITapGestureRecognizer()
    private let router = _DelegateRouter()
    private var viewSize = CGSize.zero
    private var needsReload = false
    
    private var p_items = [FSFlexibleItem]()
    
    private var cachedCells = [Int: FSFlexibleCell]()
    private var reusableCells = Set<FSFlexibleCell>()
    
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

extension FSFlexibleView {
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        defer {
            p_reloadIfNeeded()
        }
        if viewSize != bounds.size {
            viewSize = bounds.size
        }
    }
}

// MARK: - Private

private extension FSFlexibleView {
    
    /// Invoked after initialization.
    func p_didInitialize() {
        router.gestureRecognizerShouldBegin = { [unowned self] gestureRecognizer in
            if self.tap === gestureRecognizer {
                let point = gestureRecognizer.location(in: self)
                if let index = self.p_indexForItem(at: point), let item = self.p_item(at: index), item.shouldSelect {
                    return true
                }
            }
            return false
        }
        tap.delegate = router
        tap.addTarget(self, action: #selector(p_handle(tap:)))
        addGestureRecognizer(tap)
    }
    
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
        
        needsReload = false
        
        p_items.forEach { $0.reloadHandler = nil }
        
        cachedCells.removeAll()
        
        visibleCells.forEach {
            $0.removeFromSuperview()
            $0.internal_clear()
            reusableCells.insert($0)
        }
        visibleCells.removeAll()
        
        p_items.enumerated().forEach { (index, item) in
            item.reloadHandler = { [weak self] (item, type) in
                guard
                    let self = self,
                    // 防止 item 不在当前显示的 cell 中，因此优先判断是否存在相应的 cell，如不存在则不响应当前 reload 动作。
                    let cell = self.cachedCells.first(where: { $1.i_item === item })?.value
                else {
                    return
                }
                switch type {
                case .reload:
                    self.p_setNeedsReload()
                case .rerender:
                    cell.internal_render(with: item)
                }
            }
            
            let cell: FSFlexibleCell = {
                let typeName = "\(item.cellType.classForCoder())"
                if let cell = reusableCells.first(where: { "\($0.classForCoder)" == typeName }) {
                    reusableCells.remove(cell)
                    cell.internal_prepareForReuse()
                    return cell
                }
                return item.cellType.init()
            }()
            cell.frame = item.frame
            cachedCells[index] = cell
            visibleCells.append(cell)
            addSubview(cell)
            
            cell.internal_render(with: item)
        }
    }
    
    func p_indexForItem(at point: CGPoint) -> Int? {
        for (index, cell) in cachedCells {
            if cell.frame.contains(point) {
                return index
            }
        }
        return nil
    }
    
    func p_cellForItem(at index: Int) -> FSFlexibleCell? {
        return cachedCells[index]
    }
    
    func p_index(for cell: FSFlexibleCell) -> Int? {
        if let cache = cachedCells.first(where: { $1 === cell }) {
            return cache.key
        }
        return nil
    }
    
    func p_item(at index: Int) -> FSFlexibleItem? {
        if let cell = cachedCells[index] {
            return cell.i_item
        }
        return nil
    }
}

// MARK: - Action

@objc private extension FSFlexibleView {
    
    func p_handle(tap: UITapGestureRecognizer) {
        let point = tap.location(in: self)
        if let index = p_indexForItem(at: point),
           let item = p_item(at: index),
           let cell = p_cellForItem(at: index) {
            
            cell.internal_didSelect()
            onDidSelect?(self, item, index)
            item.onDidSelect?(self, item, index)
        }
    }
}

// MARK: - Public

public extension FSFlexibleView {
    
    func reload() {
        p_setNeedsReload()
    }
    
    func indexForItem(at point: CGPoint) -> Int? {
        return p_indexForItem(at: point)
    }
    
    func cellForItem(at index: Int) -> FSFlexibleCell? {
        return p_cellForItem(at: index)
    }
    
    func index(for cell: FSFlexibleCell) -> Int? {
        return p_index(for: cell)
    }
}

// MARK: - _DelegateRouter

private class _DelegateRouter: NSObject, UIGestureRecognizerDelegate {
    var gestureRecognizerShouldBegin: ((_ gestureRecognizer: UIGestureRecognizer) -> Bool)?
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizerShouldBegin?(gestureRecognizer) ?? false
    }
}
