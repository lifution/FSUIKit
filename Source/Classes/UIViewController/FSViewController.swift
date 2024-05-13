//
//  FSViewController.swift
//  FSUIKitSwift
//
//  Created by Sheng on 2024/4/15.
//  Copyright © 2024 Sheng. All rights reserved.
//

import UIKit

public typealias FSViewControllerAppearanceHandler = (_ animated: Bool, _ isFirstTime: Bool) -> Void
public typealias FSViewControllerDisappearanceHandler = (_ animated: Bool, _ isFirstTime: Bool) -> Void

open class FSViewController: UIViewController {
    
    // MARK: Properties/Public
    
    /// 让子类不需要重写方法也能快速监听当前控制器的某些生命周期函数调用。
    ///
    /// - Note:
    ///   - 建议在初始化之后就设置，否则可能会错过相应的回调。
    ///   - ⚠️ closure 内部切记要弱引用 `self` 以免引起循环引用导致内存泄漏。
    ///
    public var onViewWillAppear: FSViewControllerAppearanceHandler?
    public var onViewDidAppear: FSViewControllerAppearanceHandler?
    public var onViewWillDisappear: FSViewControllerDisappearanceHandler?
    public var onViewDidDisappear: FSViewControllerDisappearanceHandler?
    
    /// 当前控制器的 view 的 size。
    /// 当该属性更新时会回调 `viewSizeDidChange` 方法。
    public private(set) var viewSize: CGSize = .zero
    
    // MARK: Properties/Private
    
    private var isFirstTimeOfViewWillAppear = true
    private var isFirstTimeOfViewDidAppear = true
    private var isFirstTimeOfViewWillDisappear = true
    private var isFirstTimeOfViewDidDisappear = true
    
    // MARK: Initialization
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        p_didInitialize()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        p_didInitialize()
    }
    
    // MARK: Life cycle
        
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if viewSize != view.frame.size {
            viewSize = view.frame.size
            viewSizeDidChange()
        }
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        do {
            onViewWillAppear?(animated, isFirstTimeOfViewWillAppear)
            if isFirstTimeOfViewWillAppear {
                isFirstTimeOfViewWillAppear = false
            }
        }
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        do {
            onViewDidAppear?(animated, isFirstTimeOfViewDidAppear)
            if isFirstTimeOfViewDidAppear {
                isFirstTimeOfViewDidAppear = false
            }
        }
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        do {
            onViewWillDisappear?(animated, isFirstTimeOfViewWillDisappear)
            if isFirstTimeOfViewWillDisappear {
                isFirstTimeOfViewWillDisappear = false
            }
        }
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        do {
            onViewDidDisappear?(animated, isFirstTimeOfViewDidDisappear)
            if isFirstTimeOfViewDidDisappear {
                isFirstTimeOfViewDidDisappear = false
            }
        }
    }
    
    // MARK: Open
    
    /// 当 viewSize 更改后会回调该方法。
    @objc dynamic open func viewSizeDidChange() {
        
    }
    
    /// 默认的 reload empty 会回调该方法。
    @objc dynamic open func emptyReload() {
        
    }
    
    @objc dynamic open func setContents(hidden isHidden: Bool) {
        contentViews().forEach { $0.isHidden = isHidden }
    }
    
    @objc dynamic open func contentViews() -> [UIView] {
        return []
    }
}

// MARK: - Private

private extension FSViewController {
    
    /// Called after initialization.
    func p_didInitialize() {
        
    }
}
