//
//  GradientViewController.swift
//  FSUIKit_Example
//
//  Created by Sheng on 2024/4/18.
//  Copyright © 2024 Sheng. All rights reserved.
//

import UIKit
import SnapKit
import FSUIKitSwift

class GradientViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gradientView = FSGradientView()
        gradientView.colors = [.blue, .cyan, .red]
        gradientView.locations = [0, 0.5, 1.0]
        gradientView.startPoint = .init(x: 0, y: 0)
        gradientView.endPoint = .init(x: 1.0, y: 1.0)
        view.addSubview(gradientView)
        gradientView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20.0)
            make.size.equalTo(CGSize(width: 200.0, height: 100.0))
            make.centerX.equalToSuperview()
        }
        
        let gradientLabel = FSGradientLabel()
        gradientLabel.text = "FSGradientLabel"
        gradientLabel.font = .boldSystemFont(ofSize: 30.0)
        gradientLabel.colors = [.brown, .orange, .green]
//        gradientLabel.colors = [.green]
        gradientLabel.locations = [0, 0.5, 1.0]
        gradientLabel.startPoint = .init(x: 0, y: 0.5)
        gradientLabel.endPoint = .init(x: 1.0, y: 0.5)
        view.addSubview(gradientLabel)
        gradientLabel.snp.makeConstraints { make in
            make.top.equalTo(gradientView.snp.bottom).offset(20.0)
            make.centerX.equalToSuperview()
        }
    }
}
