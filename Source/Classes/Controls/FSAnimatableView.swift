//
//  FSAnimatableView.swift
//  FSUIKitSwift
//
//  Created by VincentLee on 2025/2/6.
//

import UIKit

open class FSAnimatableView: FSView {
    
    public private(set) var isAnimating = false
    
    open override var isHidden: Bool {
        get { return super.isHidden }
        set {
            super.isHidden = newValue
            if newValue {
                if isAnimating {
                    p_removeAnimation()
                }
            } else {
                if let _ = window, isAnimating {
                    p_addAnimation()
                }
            }
        }
    }
    
    open override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        if newWindow == nil {
            if isAnimating {
                p_removeAnimation()
            }
        } else {
            if !isHidden, isAnimating {
                p_addAnimation()
            }
        }
    }
    
    open func addAnimation() {
        // 留子类实现具体的动画添加
    }
    
    open func removeAnimation() {
        // 留子类实现具体的动画移除
    }
    
    public final func startAnimating() {
        guard !isAnimating else {
            return
        }
        isAnimating = true
        if window == nil || isHidden {
            // 还未显示，只是标记，暂时未开始动画
            return
        }
        p_addAnimation()
    }
    
    public final func stopAnimating() {
        isAnimating = false
        p_removeAnimation()
    }
    
    private func p_addAnimation() {
        removeAnimation()
        addAnimation()
    }
    
    private func p_removeAnimation() {
        removeAnimation()
    }
}
