//
//  DispatchQueue+FSUIKitSwift.swift
//  FSUIKitSwift
//
//  Created by VincentLee on 2024/6/22.
//  Copyright © 2023 Sheng. All rights reserved.
//

import UIKit
import Foundation

public extension FSUIKitWrapper where Base: DispatchQueue {
    
    static func asyncOnMainThread(execute work: @escaping () -> Void) {
        if Thread.isMainThread {
            work()
        } else {
            DispatchQueue.main.async(execute: work)
        }
    }
}
