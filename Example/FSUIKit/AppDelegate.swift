//
//  AppDelegate.swift
//  FSUIKitSwift
//
//  Created by Sheng on 12/21/2023.
//  Copyright (c) 2023 Sheng. All rights reserved.
//

import UIKit
import FSUIKitSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
//        UIView.appearance().semanticContentAttribute = .forceRightToLeft
        
        if #available(iOS 13, *) {
            // 从 iOS13 开始，通过 UINavigationBarAppearance 配置状态栏样式。
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.shadowColor = nil
            appearance.backgroundColor = .white
            appearance.titleTextAttributes = [
                .font: UIFont.boldSystemFont(ofSize: 18.0),
                .foregroundColor: UIColor.black
            ]
            
            let buttonAppearance = UIBarButtonItemAppearance()
            buttonAppearance.normal.titleTextAttributes = [.font: UIFont.systemFont(ofSize: 16.0)]
            appearance.buttonAppearance = buttonAppearance
            
            let backImage: UIImage? = {
                var image = UIImage(named: "icon_back")
//                image = image?.withRenderingMode(.alwaysOriginal) // 保持原图颜色
                image = image?.withAlignmentRectInsets(.init(top: 0.0, left: 0.0, bottom: -FSFlat(1.5), right: 0.0))
                return image
            }()
            appearance.setBackIndicatorImage(backImage, transitionMaskImage: backImage)
            
            let bar = UINavigationBar.appearance()
            bar.tintColor = .black
            bar.scrollEdgeAppearance = appearance
            bar.standardAppearance = {
                let a = appearance.copy()
                a.shadowColor = .fs.separator
                return a
            }()
        }
        return true
    }
}

