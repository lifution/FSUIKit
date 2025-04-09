//
//  FSControl.swift
//  FSUIKitSwift
//
//  Created by VincentLee on 2025/4/9.
//  Copyright © 2025 VincentLee. All rights reserved.
//

import UIKit

open class FSControl: UIControl {
    
    public private(set) var viewSize = CGSize.zero
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        p_didInitialize()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        p_didInitialize()
    }
    
    private func p_didInitialize() {
        didInitialize()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        if viewSize != frame.size {
            viewSize = frame.size
            viewSizeDidChange()
        }
    }
    
    open func didInitialize() {
        
    }
    
    open func viewSizeDidChange() {
        
    }
}
