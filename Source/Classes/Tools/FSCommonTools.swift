//
//  FSCommonTools.swift
//  FSUIKitSwift
//
//  Created by VincentLee on 2024/10/25.
//

import UIKit
import Foundation

public func fs_print(_ items: Any...) {
    #if DEBUG
    print("\n>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
    let output = items.map { "\($0)" }.joined(separator: " ")
    print(output)
    print("<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<")
    #endif
}
