//
//  FSToastTapticEffect.swift
//  FSUIKitSwift
//
//  Created by Sheng on 2024/2/6.
//  Copyright © 2024 Sheng. All rights reserved.
//

import UIKit

public enum FSToastTapticEffect {
    
    case none
    case selection
    case impact(FSTapticEngine.Impact.Style)
    case notification(FSTapticEngine.Notification.Style)
    
    public func feedback() {
        switch self {
        case .selection:
            FSTapticEngine.selection.feedback()
        case .impact(let style):
            FSTapticEngine.impact.feedback(style)
        case .notification(let style):
            FSTapticEngine.notification.feedback(style)
        default:
            break
        }
    }
}
