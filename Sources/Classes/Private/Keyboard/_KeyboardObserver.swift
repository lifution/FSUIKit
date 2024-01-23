//
//  _KeyboardObserver.swift
//  FSUIKit
//
//  Created by Sheng on 2024/1/23.
//  Copyright © 2024 Sheng. All rights reserved.
//

import UIKit

final class _KeyboardObserver {
    
    var onKeyboardDidChange: ((_ transition: FSKeyboardTransition) -> Void)?
    
    private var isObserving = false
    
    init() {}
    
    func start() {
        if !isObserving {
            isObserving = true
            FSKeyboardManager.shared.add(self)
        }
    }
    
    func stop() {
        if isObserving {
            isObserving = false
            FSKeyboardManager.shared.remove(self)
        }
    }
}

extension _KeyboardObserver: FSKeyboardObserver {
    
    func keyboardChanged(_ transition: FSKeyboardTransition) {
        onKeyboardDidChange?(transition)
    }
}
