//
//  FSKeyboardObserver.swift
//  FSUIKit
//
//  Created by Sheng on 2024/1/19.
//  Copyright © 2024 Sheng. All rights reserved.
//

import UIKit

/**
 The FSKeyboardObserver protocol defines the method you can use
 to receive system keyboard change information.
 */
public protocol FSKeyboardObserver: AnyObject {
    
    func keyboardChanged(_ transition: FSKeyboardTransition)
}
