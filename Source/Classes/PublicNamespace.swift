//
//  PublicNamespace.swift
//  FSUIKitSwift
//
//  Created by Sheng on 2023/12/23.
//  Copyright © 2023 Sheng. All rights reserved.
//

import UIKit

public struct FSUIKitWrapper<Base> {
    var base: Base
    fileprivate init(_ base: Base) {
        self.base = base
    }
}

public protocol FSUIKitCompatible: AnyObject {}
extension FSUIKitCompatible {
    public static var fs: FSUIKitWrapper<Self>.Type {
        get { return FSUIKitWrapper<Self>.self }
        set {}
    }
    public var fs: FSUIKitWrapper<Self> {
        get { return FSUIKitWrapper(self) }
        set {}
    }
}

public protocol FSUIKitCompatibleValue {}
extension FSUIKitCompatibleValue {
    public static var fs: FSUIKitWrapper<Self>.Type {
        get { return FSUIKitWrapper<Self>.self }
        set {}
    }
    public var fs: FSUIKitWrapper<Self> {
        get { return FSUIKitWrapper(self) }
        set {}
    }
}

extension Int: FSUIKitCompatibleValue {}
extension Float: FSUIKitCompatibleValue {}
extension Double: FSUIKitCompatibleValue {}
extension Date: FSUIKitCompatibleValue {}
extension CGRect: FSUIKitCompatibleValue {}
extension String: FSUIKitCompatibleValue {}
extension CGFloat: FSUIKitCompatibleValue {}
extension Array: FSUIKitCompatibleValue {}
extension Dictionary: FSUIKitCompatibleValue {}
extension UIEdgeInsets: FSUIKitCompatibleValue {}
extension Decimal: FSUIKitCompatibleValue {}
extension CGSize: FSUIKitCompatibleValue {}

extension NSObject: FSUIKitCompatible {}
