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
    
    private let textField = FSTextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.font = .systemFont(ofSize: 16.0)
//        textField.delegate = self
        textField.placeholder = "请输入(限制 10 个字符)"
        textField.maximumTextCount = 10
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

extension TextFieldViewController: FSTextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        fs_print("did begin editing")
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        fs_print("did end editing: [\(reason)]")
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String, originalValue: Bool) -> Bool {
        
        let predicate = NSPredicate(format: "SELF MATCHES %@", "[0-9.]+")
        guard predicate.evaluate(with: string) else {
            return false
        }
        let old = textField.text ?? ""
        if string.first == "." {
            if range.location == 0 {
                return false
            }
            if old.contains(".") {
                return false
            }
        }
        let text = (old as NSString).replacingCharacters(in: range, with: string)
        if text.first == "0" {
            if text.count >= 2, text.fs.substring(at: 1) != "." {
                return false
            }
        }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        if let value = formatter.number(from: text)?.doubleValue {
            if value > 100 { // 百分比是不能超过 100 的
                return false
            }
            if text.contains("."), let decimalComponent = text.components(separatedBy: ".").last {
                if decimalComponent.count > 2 {
                    return false
                }
            }
            return true
        }
        return false
    }
}
