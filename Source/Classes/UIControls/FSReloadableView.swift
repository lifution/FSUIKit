//
//  FSReloadableView.swift
//  FSUIKitSwift
//
//  Created by Sheng on 2024/2/6.
//  Copyright © 2024 Sheng. All rights reserved.
//

import UIKit

/// 带刷新机制的 UIView 封装。
open class FSReloadableView: FSView {
    
    private var needsReload: Bool = false

    // MARK: Initialization
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Override

    open override func layoutSubviews() {
        super.layoutSubviews()
        reloadDataIfNeeded()
    }
    
    // MARK: Public
    
    /// 标记需要执行刷新操作，真正的刷新操作会在下一个 runloop 的刷新周期中进行。
    ///
    /// - Note: 子类重写该方法必须调用 `super.setNeedsReload()`。
    ///
    @objc dynamic open func setNeedsReload() {
        needsReload = true
        setNeedsLayout()
    }
    
    /// 调用该方法会立马执行更新操作(假设需要更新的话)。
    ///
    /// - Note: 子类重写该方法必须调用 `super.reloadDataIfNeeded()`。
    ///
    @objc dynamic open func reloadDataIfNeeded() {
        if needsReload {
            reloadData()
        }
    }
    
    /// 子类可重写该方法做一些刷新的操作。
    ///
    /// - Note: 子类重写该方法必须调用 `super.reloadData()`。
    ///
    @objc dynamic open func reloadData() {
        needsReload = false
    }
}
