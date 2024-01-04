//
//  InternalNamespace.swift
//  FSUIKit
//
//  Created by Sheng on 2024/1/4.
//  Copyright © 2024 Sheng. All rights reserved.
//

import UIKit

struct FSUIKitInternalWrapper<Base> {
    let base: Base
    fileprivate init(_ base: Base) {
        self.base = base
    }
}

protocol FSUIKitInternalCompatible: AnyObject {}
extension FSUIKitInternalCompatible {
    static var inner: FSUIKitInternalWrapper<Self>.Type {
        get { return FSUIKitInternalWrapper<Self>.self }
        set {}
    }
    var inner: FSUIKitInternalWrapper<Self> {
        get { return FSUIKitInternalWrapper(self) }
        set {}
    }
}

protocol FSUIKitInternalCompatibleValue {}
extension FSUIKitInternalCompatibleValue {
    static var inner: FSUIKitInternalWrapper<Self>.Type {
        get { return FSUIKitInternalWrapper<Self>.self }
        set {}
    }
    var inner: FSUIKitInternalWrapper<Self> {
        get { return FSUIKitInternalWrapper(self) }
        set {}
    }
}

extension UIImage: FSUIKitInternalCompatible {}
