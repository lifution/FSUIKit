//
//  UIViewController+FSUIKit.swift
//  FSUIKit
//
//  Created by Sheng on 2024/1/26.
//

import UIKit

public extension FSUIKitWrapper where Base: UIViewController {
    
    /// 查找 application.rootViewController 最顶层的 UIViewController。
    static var rootTopViewController: UIViewController? {
        guard let rootVC = UIApplication.shared.delegate?.window??.rootViewController else {
            return nil
        }
        return UIViewController.fs.visibleViewController(of: rootVC)
    }
    
    /// 查找指定的控制器正在显示中的那层控制器。
    static func visibleViewController(of viewController: UIViewController) -> UIViewController {
        
        if let vc = viewController.presentedViewController {
            return vc
        }
        
        if let tabBarController = viewController as? UITabBarController {
            if let vc = tabBarController.selectedViewController {
                return UIViewController.fs.visibleViewController(of: vc)
            }
        }
        
        if let nc = viewController as? UINavigationController {
            if let vc = nc.visibleViewController {
                return UIViewController.fs.visibleViewController(of: vc)
            }
        }
        
        return viewController
    }
}
