//
//  FSView.swift
//  FSUIKitSwift
//
//  Created by VincentLee on 2025/2/6.
//

import UIKit

open class FSView: UIView {
    
    public private(set) var viewSize = CGSize.zero
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        p_didInitialize()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        p_didInitialize()
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
    
    private func p_didInitialize() {
        didInitialize()
        
    }
}
