//
//  ToastViewController.swift
//  FSUIKit_Example
//
//  Created by Sheng on 2024/2/7.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import SnapKit
import FSUIKit

class ToastViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            FSKeyboardManager.shared.add(self)
        }
        do {
            let textField = UITextField()
            textField.font = .systemFont(ofSize: 14.0)
            textField.placeholder = "测试键盘弹出"
            textField.borderStyle = .roundedRect
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: textField)
            textField.snp.makeConstraints { (make) in
                make.size.equalTo(CGSize(width: 120.0, height: 35.0))
            }
        }
    }
}

extension ToastViewController {
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0:
            self.fs.dismissToast()
        case 1:
            self.fs.show(hint: "登录成功")
        case 2:
            do {
                let content = FSToastContent(style: .hint)
                content.richText = {
                    let style = NSMutableParagraphStyle()
                    style.alignment = .center
                    let attributes: [NSAttributedString.Key: Any] = [
                        .font: UIFont.boldSystemFont(ofSize: 16.0),
                        .paragraphStyle: style,
                        .foregroundColor: UIColor.orange
                    ]
                    return NSAttributedString(string: "温馨提示", attributes: attributes)
                }()
                content.richDetail = {
                    let attributes: [NSAttributedString.Key: Any] = [
                        .font: UIFont.systemFont(ofSize: 14.0),
                        .foregroundColor: UIColor.orange
                    ]
                    let text = "设计模式（Design pattern）代表了最佳的实践，通常被有经验的面向对象的软件开发人员所采用。设计模式是软件开发人员在软件开发过程中面临的一般问题的解决方案。这些解决方案是众多软件开发人员经过相当长的一段时间的试验和错误总结出来的。"
                    return NSAttributedString(string: text, attributes: attributes)
                }()
                self.fs.show(content: content)
            }
        case 3:
            do {
                let content = FSToastContent()
                content.duration = 3.0
                content.animation = FSToastAnimation(kind: .slideDown)
                content.backgroundColor = .black
                content.tapticEffect = {
                    if #available(iOS 13.0, *) {
                        return .impact(.soft)
                    }
                    return .impact(.medium)
                }()
                content.topView = {
                    
                    let iconView = UIImageView(image: UIImage(named: "smile"))
                    
                    let textLabel = UILabel()
                    textLabel.font = .systemFont(ofSize: 15.0)
                    textLabel.text = "Hello World!"
                    textLabel.textColor = .white
                    
                    let stack = UIStackView(arrangedSubviews: [iconView, textLabel])
                    stack.axis = .horizontal
                    stack.spacing = 8.0
                    stack.alignment = .center
                    stack.distribution = .fill
                    stack.bounds.size = stack.systemLayoutSizeFitting(.init(width: 1000.0, height: 1000.0))
                    
                    return stack
                }()
                self.fs.show(content: content)
            }
        case 4:
            do {
                let content = FSToastContent(style: .hint)
                content.text = "This is a hint toast with disappear handler, see console output."
                content.duration = 3.0
                content.onDidDismiss = {
                    print("👻 Hint Toast did disappear.")
                }
                self.fs.show(content: content)
            }
        case 5:
            self.fs.showLoading("请稍候...", isUserInteractionEnabled: true)
        case 6:
            self.fs.showSuccess("登录成功")
        case 7:
            self.fs.showError("交易失败")
        case 8:
            do {
                let content = FSToastContent(style: .warning)
                content.text = "本次交易存在较大风险"
                content.duration = 0.0
                content.bottomView = {
                    
                    let update: ((FSButton) -> Void) = { button in
                        let color: UIColor = {
                            if #available(iOS 13, *) {
                                return UITraitCollection.current.userInterfaceStyle == .dark ? .black : .white
                            }
                            return .white
                        }()
                        button.layer.borderColor = color.cgColor
                        button.setTitleColor(color, for: .normal)
                    }
                    
                    let button = FSButton()
                    button.titleLabel?.font = .systemFont(ofSize: 15.0)
                    button.layer.borderWidth = 1.0
                    button.layer.cornerRadius = 6.0
                    button.setTitle("知道了", for: .normal)
                    button.fs.setHandler(for: .touchUpInside) { [weak self] _ in
                        self?.fs.dismissToast()
                    }
                    update(button)
                    return button
                }()
                content.bottomViewSize = .init(width: 68.0, height: 30.0)
                self.fs.show(content: content)
            }
        case 9:
            self.fs.show(hint: "This toast forbids user touching the view.", isUserInteractionEnabled: false)
        case 10:
            do {
                FSToast.showLoading("正在登录...", isUserInteractionEnabled: false)
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    let content = FSToastContent(style: .success)
                    content.text = "登录成功"
                    content.duration = 2.0
                    content.onDidDismiss = {
                        print("登录成功，进入首页。")
                    }
                    FSToast.show(content: content, isUserInteractionEnabled: false)
                }
            }
        default:
            break
        }
    }
}

extension ToastViewController: FSKeyboardObserver {
    
    func keyboardChanged(_ transition: FSKeyboardTransition) {
        let manager = FSKeyboardManager.shared
        print("------------------")
        print("keyboard is visible: [\(manager.isKeyboardVisible ? "true" : "false")]")
        print("keyboard frame: [\(manager.keyboardFrame)]")
        print("------------------")
    }
}
