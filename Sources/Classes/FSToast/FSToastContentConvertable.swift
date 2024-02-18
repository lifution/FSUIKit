//
//  FSToastContentConvertable.swift
//  FSUIKit
//
//  Created by Sheng on 2024/2/6.
//  Copyright © 2024 Sheng. All rights reserved.
//

import Foundation

/// ToastView 的内容协议。
public protocol FSToastContentConvertable: AnyObject {
    
    /// 显示持续时间，如果设为 `0` 或 `小于 0` 则表示无限长时间。
    /// 默认为 `0`。
    var duration: TimeInterval { get set }
    
    /// Taptic 效果，默认为 `.none`。
    var tapticEffect: FSToastTapticEffect { get set }
    
    /// 圆角半径，默认为 8.0
    var cornerRadius: CGFloat { get set }
    
    /// 边框颜色，默认为 nil。
    var borderColor: UIColor? { get set }
    
    /// 边框宽度，默认为 0。
    var borderWidth: CGFloat { get set }
    
    /// 背景颜色，默认为 `.black`，
    /// 当 `backgroundEffect` 为 nil 时该属性才生效。
    var backgroundColor: UIColor? { get set }
    
    /// 背景效果，该属性用于配置背景高斯模糊效果，
    /// 当该属性不为 nil 时忽略 `backgroundColor` 属性，
    /// 如果该属性为 nil 则取消高斯模糊效果并设置 `backgroundColor` 属性。
    /// 默认为 nil。
    var backgroundEffect: FSToastBackgroundEffect? { get set }
    
    /// 整体内容的四边距，
    /// 默认为 `(top: 12.0, left: 16.0, bottom: 12.0, right: 16.0)`。
    var contentInset: UIEdgeInsets { get set }
    
    /// 顶部视图的底部空隙
    var topViewBottomSpacing: CGFloat { get set }
    
    /// 正文的底部空隙
    var textBottomSpacing: CGFloat { get set }
    
    /// 详细文本的底部空隙
    var detailBottomSpacing: CGFloat { get set }
    
    /// 顶部视图
    var topView: UIView? { get set }
    
    /// 顶部视图的 size，如果该属性为 nil 则会使用 topView 的 `sizeThatFits(_:)` 方法获取 size。
    /// 默认为 nil。
    var topViewSize: CGSize? { get set }
    
    /// 正文
    var text: String? { get set }
    
    /// 正文的富文本（该字段优先级比 `text` 高）
    var richText: NSAttributedString? { get set }
    
    /// 详细内容
    var detail: String? { get set }
    
    /// 详细内容的富文本（该字段优先级比 `detail` 高）
    var richDetail: NSAttributedString? { get set }
    
    /// 底部视图
    var bottomView: UIView? { get set }
    
    /// 底部视图的 size，如果该属性为 nil 则会使用 bottomView 的 `sizeThatFits(_:)` 方法获取 size。
    /// 默认为 nil。
    var bottomViewSize: CGSize? { get set }
    
    /// 显示 & 隐藏 的动画。
    var animation: FSToastAnimatedTransitioning? { get set }
    
    /// 隐藏完成回调。
    ///
    /// - Note:
    ///   - 当使用 `UIView+FSToast / UIViewController+FSToast` 中的方法显示 toast 时，
    ///     只有在自动隐藏的情况下才会回调该 closure，手动调用 `dismissToast()` 不会回调该 closure。
    ///   - `UIView+FSToast / UIViewController+FSToast` 以外的方式显示 toast 时，
    ///     需开发者自己管理调用该 closure 的时机。
    ///
    var onDidDismiss: (() -> Void)? { get set }
    
    /// Dark mode has been change.
    /// This method will be called when the dark mode changes.
    ///
    /// - Note: Only available after iOS13.
    ///
    func userInterfaceStyleDidChange()
}

// optional
public extension FSToastContentConvertable {
    var duration: TimeInterval { get { return 0.0 } set {} }
    var tapticEffect: FSToastTapticEffect { get { return .none } set {} }
    var cornerRadius: CGFloat { get { return 8.0 } set {} }
    var borderColor: UIColor? { get { return nil } set {} }
    var borderWidth: CGFloat { get { return 0.0 } set {} }
    var backgroundColor: UIColor? { get { return .black } set {} }
    var backgroundEffect: FSToastBackgroundEffect? { get { return nil } set {} }
    var contentInset: UIEdgeInsets { get { return .init(top: 12.0, left: 16.0, bottom: 12.0, right: 16.0) } set {} }
    var topViewBottomSpacing: CGFloat { get { return 12.0 } set {} }
    var textBottomSpacing: CGFloat { get { return 12.0 } set {} }
    var detailBottomSpacing: CGFloat { get { return 12.0 } set {} }
    var topView: UIView? { get { return nil } set {} }
    var topViewSize: CGSize? { get { return nil } set {} }
    var text: String? { get { return nil } set {} }
    var richText: NSAttributedString? { get { return nil } set {} }
    var detail: String? { get { return nil } set {} }
    var richDetail: NSAttributedString? { get { return nil } set {} }
    var bottomView: UIView? { get { return nil } set {} }
    var bottomViewSize: CGSize? { get { return nil } set {} }
    var animation: FSToastAnimatedTransitioning? { get { return nil } set {} }
    var onDidDismiss: (() -> Void)? { get { return nil } set {} }
    func userInterfaceStyleDidChange() {}
}
