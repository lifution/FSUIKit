//
//  FSFlexibleCell.swift
//  FSUIKitSwift
//
//  Created by Sheng on 2024/3/13.
//  Copyright © 2024 Sheng. All rights reserved.
//

import UIKit

open class FSFlexibleCell: UIView {
    
    // MARK: Properties/Public
    
    /// 与 cell 绑定的 item。
    ///
    /// - 该属性会在 `render(with:)` 方法中进行绑定。
    /// - 该属性会在 `prepareForReuse()` 方法调用前被设置为 nil。
    ///
    open var item: FSFlexibleItem?
    
    // MARK: Properties/Internal
    
    private(set) var i_item: FSFlexibleItem?
    
    // MARK: Initialization
    
    required public init() {
        super.init(frame: .zero)
        didInitialize()
    }
    
    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Open
    
    /// 该方法会在初始化后调用。
    open func didInitialize() {}
    
    /// 在当前 cell 被重用前会调用该方法。
    ///
    /// - 只有被重用的 cell 才会调用该方法，新创建的 cell 不会调用该方法。
    ///
    open func prepareForReuse() {}
    
    /// 当 cell 被选中后会回调该方法。
    ///
    /// - 如果 cell 对应的 item 的 shouldSelect 为 false，则不会回调该方法。
    /// - FSFlexibleCell 和 UITableViewCell 不一样，没有「选中」和 「取消选中」的概念，
    ///   FSFlexibleCell 的「选中」其实就是点击了，因此该方法是可能会被多次回调的，每一
    ///   次用户选中后都会回调该方法。
    ///
    open func didSelect() {}
    
    /// 该方法用于把 item 和 cell 绑定。
    ///
    /// - 该方法默认把 cell 绑定 item。
    /// - 子类可重栽该方法对 cell 做一些更新。
    ///
    open func render(with item: FSFlexibleItem) {
        self.item = item
    }
}

// MARK: - Internal

extension FSFlexibleCell {
    
    final func internal_prepareForReuse() {
        defer {
            prepareForReuse()
        }
        item = nil
        i_item = nil
    }
    
    final func internal_didSelect() {
        didSelect()
    }
    
    final func internal_render(with item: FSFlexibleItem) {
        defer {
            render(with: item)
        }
        i_item = item
    }
    
    final func internal_clear() {
        item = nil
        i_item = nil
    }
}
