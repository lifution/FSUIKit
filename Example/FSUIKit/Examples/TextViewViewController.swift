//
//  TextViewViewController.swift
//  FSUIKit_Example
//
//  Created by VincentLee on 2024/11/8.
//  Copyright © 2024 Sheng. All rights reserved.
//

import UIKit
import FSUIKitSwift

final class TextViewViewController: FSViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let textView = FSTextView()
        textView.font = .systemFont(ofSize: 16.0)
//        textView.delegate = self
        textView.placeholder = "请输入(限制 5 个字符)"
        textView.maximumTextCount = 5
        textView.onDidHitMaximumTextCountHandler = { _ in
            FSToast.show(hint: "达到限制字数")
        }
        textView.layer.borderWidth = 1.0
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.cornerRadius = 6.0
        view.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20.0)
            make.left.equalTo(20.0)
            make.right.equalTo(-20.0)
            make.height.equalTo(100.0)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
}
