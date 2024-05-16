//
//  CustomBarViewController.swift
//  FSUIKit_Example
//
//  Created by Sheng on 2024/5/16.
//  Copyright © 2024 Sheng. All rights reserved.
//

import UIKit
import SnapKit
import FSUIKitSwift

final class CustomBarViewController: UIViewController {
    
    // MARK: Properties/Private
    
    private let navigationBar = FSNavigationBar()
    private let toolBar = FSToolBar()
    
    // MARK: Initialization
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        p_didInitialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        p_didInitialize()
    }
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.title = "Custom Bar"
        toolBar.backgroundView.backgroundColor = .fs.groupBackground
        
        view.addSubview(navigationBar)
        view.addSubview(toolBar)
        navigationBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalTo(0)
        }
        toolBar.snp.makeConstraints { make in
            make.left.right.equalTo(0)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        do {
            let button = FSButton()
            button.titleLabel?.font = .boldSystemFont(ofSize: 20.0)
            button.hitTestEdgeInsets = .init(top: -12.0, left: -12.0, bottom: -12.0, right: -12.0)
            button.setTitle("Show Album", for: .normal)
            button.setTitleColor(.fs.color(hexed: "#387bfb"), for: .normal)
            toolBar.addSubview(button)
            button.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }
        }
    }
    
    // MARK: Private
    
    private func p_didInitialize() {
        fs.prefersNavigationBarHidden = true
        navigationBar.resetDefaultBackButton()
        navigationBar.setDefaultBackButton(tintColor: .fs.color(hexed: "#387bfb"))
    }
}
