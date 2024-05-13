//
//  FSCollectionViewAnimatedFlowLayout.swift
//  FSUIKitSwift
//
//  Created by Sheng on 2024/1/19.
//  Copyright © 2024 Sheng. All rights reserved.
//

import UIKit

open class FSCollectionViewAnimatedFlowLayout: UICollectionViewFlowLayout {
    
    // MARK: Properties/Open
    
    /// contentSize 更新后的回调，外部可实现该 closure 达到监听 contentSize 更新的效果。
    open var onContentSizeDidChange: ((CGSize) -> Void)?
    
    /// 当该属性为 true 时，UICollectionView 插入新的 cell 时会有动画，而不是生硬地更新 UI
    /// 默认为 true
    open var isAnimationEnabled = true
    
    // MARK: Properties/Private
    
    private var insertingIndexPaths: [IndexPath] = []
    
    // MARK: Override
    
    open override func prepare() {
        super.prepare()
        do {
            /// Fix:
            /// UICollectionView 调用 `insertItems` 刷新 UI 时，
            /// collectionView.contentSize 和 layout.collectionViewContentSize 会不同步。
            collectionView?.contentSize = collectionViewContentSize
        }
    }
    
    open override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        super.prepare(forCollectionViewUpdates: updateItems)
        if isAnimationEnabled {
            insertingIndexPaths.removeAll()
            for item in updateItems {
                if let indexPath = item.indexPathAfterUpdate {
                    if item.updateAction == .insert {
                        insertingIndexPaths.append(indexPath)
                    }
                }
            }
        }
    }
    
    open override func finalizeCollectionViewUpdates() {
        if isAnimationEnabled {
            insertingIndexPaths.removeAll()
        }
        super.finalizeCollectionViewUpdates()
    }
    
    open override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)
        if isAnimationEnabled {
            if insertingIndexPaths.contains(itemIndexPath) {
                attributes?.alpha = 0.0
                attributes?.transform = CGAffineTransform(translationX: 0.0, y: 80.0)
            }
        }
        return attributes
    }
}
