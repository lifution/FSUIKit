//
//  TextInputAlertViewController.swift
//  FSUIKit_Example
//
//  Created by Sheng on 2024/4/13.
//  Copyright © 2024 Sheng. All rights reserved.
//

import UIKit
import SnapKit
import FSUIKitSwift

class TextInputAlertViewController: UIViewController {
    
    // MARK: Properties/Internal
    
    @IBOutlet weak var textLabel: UILabel!
    
    // MARK: Override
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textLabel.text = nil
    }
    
    // MARK: Actions
    
    @IBAction func showTextFieldInput(_ sender: Any) {
        let vc = FSTextFieldInputViewController()
        vc.summary = "Password"
        present(vc, animated: true)
    }
    
    @IBAction func showTextViewInput(_ sender: Any) {
        
    }
}
