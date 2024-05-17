//
//  FullscreenPopViewController.swift
//  FSUIKit_Example
//
//  Created by Sheng on 2024/5/17.
//  Copyright © 2024 Sheng. All rights reserved.
//

import UIKit
import FSUIKitSwift

final class FullscreenPopViewController: UIViewController {
    
    @IBOutlet weak var stateControl: UISwitch!
    
    // MARK: Initialization
    
    static func createFromStoryboard() -> FullscreenPopViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if #available(iOS 13.0, *) {
            return storyboard.instantiateViewController(identifier: String(describing: self)) { coder in
                FullscreenPopViewController(coder: coder)
            }
        } else {
            return storyboard.instantiateViewController(withIdentifier: String(describing: self)) as! FullscreenPopViewController
        }
    }
    
    @IBAction func push(_ sender: Any) {
        let vc = FullscreenPopViewController.createFromStoryboard()
        vc.fs.prefersNavigationBarHidden = stateControl.isOn
        navigationController?.pushViewController(vc, animated: true)
    }
}
