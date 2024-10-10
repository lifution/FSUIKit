//
//  UIViewController+FSUIKitSwift.swift
//  FSUIKitSwift
//
//  Created by Sheng on 2024/1/26.
//

import UIKit

public extension FSUIKitWrapper where Base: UIViewController {
    
    /// 查找 application.rootViewController 最顶层的 UIViewController。
    static var rootTopViewController: UIViewController? {
        if let rootVC = UIApplication.shared.delegate?.window??.rootViewController {
            return UIViewController.fs.visibleViewController(of: rootVC)
        }
        var firstKeyWindow: UIWindow?
        if #available(iOS 15.0, *) {
            firstKeyWindow = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .filter { $0.activationState == .foregroundActive }
                .first?.keyWindow
        } else if #available(iOS 13, *) {
            firstKeyWindow = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .filter { $0.activationState == .foregroundActive }
                .first?.windows
                .first(where: \.isKeyWindow)
        }
        if let rootVC = firstKeyWindow?.rootViewController {
            return UIViewController.fs.visibleViewController(of: rootVC)
        }
        return nil
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
    
    func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        /// UIKit 的该方法有时候会延迟一点时间再跳转，使用 `DispatchQueue.main.async {}` 可缓解。
        DispatchQueue.main.async {
            base.present(viewControllerToPresent, animated: flag, completion: completion)
        }
    }
}
