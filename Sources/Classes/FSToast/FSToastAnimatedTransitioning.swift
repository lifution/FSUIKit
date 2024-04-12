//
//  FSToastAnimatedTransitioning.swift
//  FSUIKitSwift
//
//  Created by Sheng on 2024/2/6.
//  Copyright © 2024 Sheng. All rights reserved.
//

import UIKit

/// FSToastView 显示 & 隐藏 的动画协议。
///
/// - Important:
///   - **Animation 对象禁止强持有 toast view，否则会导致内存泄漏。**
///
public protocol FSToastAnimatedTransitioning: AnyObject {
    
    /// 显示动画
    ///
    /// - Parameters:
    ///   - toastView:      动画所作用的图层（即 FSToastView）
    ///   - containerView:  toast view 显示所在的图层
    ///   - completion:     动画结束回调
    ///
    /// - Important:
    ///   - **Animation 对象禁止强持有 toast view，否则会导致内存泄漏。**
    ///   - 无论是否有动画，**最后必须回调 completion**，否则调用者无法获得该方法的结束状态，进而可能引起未知错误。
    ///
    func presentingAnimationBehavior(for toastView: UIView, in containerView: UIView, completion: (() -> Void)?)
    
    /// 隐藏动画
    ///
    /// - Parameters:
    ///   - toastView:      动画所作用的图层（即 FSToastView）
    ///   - containerView:  toast view 显示所在的图层
    ///   - completion:     动画结束回调
    ///
    /// - Important:
    ///   - **Animation 对象禁止强持有 toast view，否则会导致内存泄漏。**
    ///   - 无论是否有动画，**最后必须回调 completion**，否则调用者无法获得该方法的结束状态，进而可能引起未知错误。
    ///
    func dismissingAnimationBehavior(for toastView: UIView, in containerView: UIView, completion: (() -> Void)?)
}
