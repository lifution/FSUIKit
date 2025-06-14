//
//  FSFlexibleItem.swift
//  FSUIKitSwift
//
//  Created by Sheng on 2024/3/13.
//  Copyright © 2024 Sheng. All rights reserved.
//

import UIKit

open class FSFlexibleItem {
    
    // MARK: Definition
    
    /// 刷新类型
    public enum ReloadType {
        /// 只重新绘制，不更新 FSFlexibleView。
        case rerender
        /// 重新绘制，并更新 FSFlexibleView。
        case reload
    }
    
    // MARK: Properties/Public
    
    /// 该属性表示的就是 item 对应的 cell 的 frame。
    open var frame: CGRect = .zero
    
    /// cell 的类型。
    open var cellType: FSFlexibleCell.Type = FSFlexibleCell.self
    
    /// 是否允许选中。
    open var shouldSelect = true
    
    /// cell 绑定的数据。
    open var data: Any?
    
    /// 当前 item 的 frame 更新回调
    ///
    /// - Note:
    ///   该属性是提供给 subclass 在 frame 更新时主动回调给外部，
    ///   并不是监听 ``FSFlexibleItem/frame`` 的变化而回调。
    ///   部份场景下，item 的 frame.size 并不会立刻确定，需等一会后
    ///   才会确定，这时需要更新 item.frame，就可以使用该 closure 回
    ///   调通知外部。
    ///
    open var onFrameDidUpdate: ((_ item: FSFlexibleItem) -> Void)?
    
    /// 选中回调。
    open var onDidSelect: ((_ flexibleView: FSFlexibleView, _ item: FSFlexibleItem, _ index: Int) -> Void)?
    
    // MARK: Properties/Internal
    
    /// reload 处理者，用于 FSFlexibleView 内部监听当前类的 reload 操作。
    ///
    /// - Warning:
    ///   - ⚠️ FSFlexibleView 会实现该 closure，其它地方禁止实现。
    ///
    final var reloadHandler: ((FSFlexibleItem, FSFlexibleItem.ReloadType) -> Void)?
    
    // MARK: Initialization
    
    public init() {}
    
    // MARK: Open
    
    open func updateLayout() {
        // 默认不做任何布局更新，子类可以重写该方法。
    }
}

// MARK: - Public

public extension FSFlexibleItem {
    
    /// 刷新 item 对应的 cell。
    ///
    /// - Parameter type: 刷新类型，默认为 `.rerender`。
    ///
    final func reload(_ type: FSFlexibleItem.ReloadType = .rerender) {
        reloadHandler?(self, type)
    }
}
