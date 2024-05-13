//
//  FSKeyboardListener.swift
//  FSUIKitSwift
//
//  Created by Sheng on 2024/1/19.
//  Copyright © 2024 Sheng. All rights reserved.
//

import UIKit

/**
 The FSKeyboardListener protocol defines the method you can use
 to receive system keyboard change information.
 */
public protocol FSKeyboardListener: AnyObject {
    
    func keyboardChanged(_ transition: FSKeyboardTransition)
}
