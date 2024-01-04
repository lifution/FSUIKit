//
//  ViewController.swift
//  FSUIKit
//
//  Created by Sheng on 12/21/2023.
//  Copyright (c) 2023 Sheng. All rights reserved.
//

import UIKit
import SnapKit
import FSUIKit

class ViewController: UIViewController {
    
    private let navigationBar = FSNavigationBar()

    override func viewDidLoad() {
        super.viewDidLoad()
        p_setupViews()
    }
}

// MARK: - Private

private extension ViewController {
    
    /// Invoked in the `viewDidLoad` method.
    func p_setupViews() {
        do {
//            let label = UILabel()
//            label.text = "😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂"
//            label.font = UIFont.boldSystemFont(ofSize: 18.0)
//            label.textColor = .black
//            label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
//            navigationBar.titleView = label
            
            navigationBar.title = "😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭😭"
            view.addSubview(navigationBar)
            navigationBar.snp.makeConstraints { (make) in
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
                make.left.right.equalTo(0.0)
            }
        }
        do {
            let view = UIView()
            view.backgroundColor = .red
            
            let label = UILabel()
            label.text = "I'm a label"
            label.backgroundColor = .cyan
            
            let giftButton = FSButton()
            giftButton.backgroundColor = .cyan
            giftButton.setImage(UIImage(named: "gift"), for: .normal)
            
            navigationBar.rightItemViews = [view, label, giftButton]
            
            view.snp.makeConstraints { (make) in
                make.size.equalTo(CGSize(width: 40.0, height: 40.0))
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                label.text = "Oh!"
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.navigationBar.rightItemViews = nil
                }
            }
        }
    }
}

