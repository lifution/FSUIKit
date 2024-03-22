//
//  FSFlexibleItem.swift
//  FSUIKit
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
    
    /// 选中回调。
    open var onDidSelect: ((_ flexibleView: FSFlexibleView, _ index: Int) -> Void)?
    
    // MARK: Properties/Internal
    
    /// reload 处理者，用于 FSFlexibleView 内部监听当前类的 reload 操作。
    ///
    /// - Warning:
    ///   - ⚠️ FSFlexibleView 会实现该 closure，其它地方禁止实现。
    ///
    final var reloadHandler: ((FSFlexibleItem, FSFlexibleItem.ReloadType) -> Void)?
    
    // MARK: Initialization
    
    public init() {}
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
