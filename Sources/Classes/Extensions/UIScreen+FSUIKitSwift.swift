//
//  UIScreen+FSUIKitSwift.swift
//  FSUIKitSwift
//
//  Created by Sheng on 2023/12/23.
//  Copyright © 2023 Sheng. All rights reserved.
//

import UIKit
import Foundation

public extension FSUIKitWrapper where Base: UIScreen {
    
    static var scale: CGFloat {
        return _UIScreenConsts.scale
    }
    
    static var pixelOne: CGFloat {
        return _UIScreenConsts.pixelOne
    }
    
    static var width: CGFloat {
        return UIScreen.main.bounds.width
    }
    
    static var height: CGFloat {
        return UIScreen.main.bounds.height
    }
    
    static var portraitWidth: CGFloat {
        return _UIScreenConsts.portraitWidth
    }
    
    static var portraitHeight: CGFloat {
        return _UIScreenConsts.portraitHeight
    }
    
    static var safeAreaInsets: UIEdgeInsets {
        if #available(iOS 13.0, *), let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if let insets = scene.windows.first?.safeAreaInsets {
                return insets
            }
            return .zero
        }
        if let delegate = UIApplication.shared.delegate {
            if let insets = delegate.window??.safeAreaInsets {
                return insets
            }
        }
        return .zero
    }
    
    static var isPhone: Bool {
        return _UIScreenConsts.isPhone
    }
    
    static var isPad: Bool {
        return _UIScreenConsts.isPad
    }
    
    @available(iOS 14.0, *)
    static var isMac: Bool {
        return _UIScreenConsts.isMac
    }
}

private struct _UIScreenConsts {
    
    static let scale: CGFloat = {
        return UIScreen.main.scale
    }()
    
    static let pixelOne: CGFloat = {
        return  1.0 / UIScreen.main.scale
    }()
    
    static let portraitWidth: CGFloat = {
        let bounds = UIScreen.main.bounds
        return min(bounds.width, bounds.height)
    }()
    
    static let portraitHeight: CGFloat = {
        let bounds = UIScreen.main.bounds
        return max(bounds.width, bounds.height)
    }()
    
    static var isPhone: Bool = {
        return UIDevice.current.userInterfaceIdiom == .phone
    }()
    
    static var isPad: Bool = {
        return UIDevice.current.userInterfaceIdiom == .pad
    }()
    
    @available(iOS 14.0, *)
    static var isMac: Bool = {
        return UIDevice.current.userInterfaceIdiom == .mac
    }()
}
