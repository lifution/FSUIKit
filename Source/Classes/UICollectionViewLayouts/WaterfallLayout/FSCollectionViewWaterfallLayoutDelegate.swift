//
//  FSCollectionViewWaterfallLayoutDelegate.swift
//  FSUIKitSwift
//
//  Created by Sheng on 2024/3/31.
//  Copyright © 2024 Sheng. All rights reserved.
//

import UIKit

/// 瀑布流布局代理。
public protocol FSCollectionViewWaterfallLayoutDelegate: AnyObject {
    
    // MARK: Required
    
    /// 列数
    func collectionView(_ collectionView: UICollectionView, layout: FSCollectionViewWaterfallLayout, numberOfColumnsIn section: Int) -> Int
    
    /// item 高度
    func collectionView(_ collectionView: UICollectionView, layout: FSCollectionViewWaterfallLayout, heightForItemAt indexPath: IndexPath) -> CGFloat
    
    // MARK: Optional
    
    /// section inset
    func collectionView(_ collectionView: UICollectionView, layout: FSCollectionViewWaterfallLayout, insetForSectionAt section: Int) -> UIEdgeInsets
    
    /// item 垂直方向间距
    func collectionView(_ collectionView: UICollectionView, layout: FSCollectionViewWaterfallLayout, lineSpacingForSectionAt section: Int) -> CGFloat
    
    /// item 水平方向间距
    func collectionView(_ collectionView: UICollectionView, layout: FSCollectionViewWaterfallLayout, interitemSpacingForSectionAt section: Int) -> CGFloat
    
    /// section header 的 size。
    ///
    /// - Note:
    ///   - 在 vertical 模式下，size.height 表示的是 header 的高度，header 的宽度默认为 collectionView 的宽度。
    ///   - 在 horizontal 模式下，size.width 表示的是 header 的宽度，header 的高度默认为 collectionView 的高度。
    ///   - 如果该方法返回的 size 的生效属性（参考上面的说明）为 0，则表示没有 header。
    ///
    func collectionView(_ collectionView: UICollectionView, layout: FSCollectionViewWaterfallLayout, referenceSizeForHeaderInSection section: Int) -> CGSize
    
    /// section footer 的 size。
    ///
    /// - Note:
    ///   - 在 vertical 模式下，size.height 表示的是 footer 的高度，footer 的宽度默认为 collectionView 的宽度。
    ///   - 在 horizontal 模式下，size.width 表示的是 footer 的宽度，footer 的高度默认为 collectionView 的高度。
    ///   - 如果该方法返回的 size 的生效属性（参考上面的说明）为 0，则表示没有 footer。
    ///
    func collectionView(_ collectionView: UICollectionView, layout: FSCollectionViewWaterfallLayout, referenceSizeForFooterInSection section: Int) -> CGSize
}

public extension FSCollectionViewWaterfallLayoutDelegate {
    
    func collectionView(_ collectionView: UICollectionView, layout: FSCollectionViewWaterfallLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 12.0, left: 12.0, bottom: 12.0, right: 12.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: FSCollectionViewWaterfallLayout, lineSpacingForSectionAt section: Int) -> CGFloat {
        return 8.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: FSCollectionViewWaterfallLayout, interitemSpacingForSectionAt section: Int) -> CGFloat {
        return 8.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: FSCollectionViewWaterfallLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: FSCollectionViewWaterfallLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return .zero
    }
}
