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
        vc.textField.placeholder = "Please enter your password"
        present(vc, animated: true)
    }
    
    @IBAction func showTextViewInput(_ sender: Any) {
        let vc = FSTextViewInputViewController()
        vc.summary = "设计模式"
        vc.textView.text = "设计模式（Design pattern）代表了最佳的实践，通常被有经验的面向对象的软件开发人员所采用。设计模式是软件开发人员在软件开发过程中面临的一般问题的解决方案。这些解决方案是众多软件开发人员经过相当长的一段时间的试验和错误总结出来的。"
        present(vc, animated: true)
    }
}
