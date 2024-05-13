//
//  FSKeyboardObserver.swift
//  FSUIKitSwift
//
//  Created by Sheng on 2024/3/25.
//  Copyright © 2024 Sheng. All rights reserved.
//

import UIKit

open class FSKeyboardObserver: FSKeyboardListener {
    
    open var onKeyboardDidChange: ((_ transition: FSKeyboardTransition) -> Void)?
    
    private var isObserving = false
    
    public init() {}
    
    open func start() {
        if !isObserving {
            isObserving = true
            FSKeyboardManager.shared.add(self)
        }
    }
    
    open func stop() {
        if isObserving {
            isObserving = false
            FSKeyboardManager.shared.remove(self)
        }
    }
    
    open func keyboardChanged(_ transition: FSKeyboardTransition) {
        onKeyboardDidChange?(transition)
    }
}
