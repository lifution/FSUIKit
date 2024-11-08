//
//  TextFieldViewController.swift
//  FSUIKit_Example
//
//  Created by VincentLee on 2024/11/7.
//  Copyright © 2024 Sheng. All rights reserved.
//

import UIKit
import FSUIKitSwift

final class TextFieldViewController: FSViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let textField = FSTextField()
        textField.font = .systemFont(ofSize: 16.0)
//        textField.fs_delegate = self
        textField.placeholder = "请输入(限制 5 个字符)"
        textField.maximumTextCount = 5
        textField.onDidHitMaximumTextCountHandler = { _ in
            FSToast.show(hint: "达到限制字数")
        }
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.black.cgColor
        textField.layer.cornerRadius = 6.0
        view.addSubview(textField)
        textField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20.0)
            make.left.equalTo(20.0)
            make.right.equalTo(-20.0)
            make.height.equalTo(44.0)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
}
