//
//  ViewController.swift
//  FSUIKitSwift
//
//  Created by Sheng on 12/21/2023.
//  Copyright (c) 2023 Sheng. All rights reserved.
//

import UIKit
import RxSwift
import SnapKit
import FSUIKitSwift

class ViewController: UITableViewController {
    
//    private let timer = FSTimer(timeInterval: 1.0)
    
    @IBOutlet weak var canvasView: UIView!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        timer.autoSuspendInBackground = false
//        timer.eventHandler = {
//            print("timer callback")
//        }
//        timer.resume()
        
//        do {
//            UIView.appearance().semanticContentAttribute = .forceRightToLeft
//            
//            let view = SwitchView()
//            view.isOn = true
//            view.onColor = .green
//            view.hitInsets = .fs.create(with: -10.0)
//            canvasView.addSubview(view)
//            view.snp.makeConstraints { make in
//                make.center.equalToSuperview()
//            }
//        }
        
//        do {
//            UIView.appearance().semanticContentAttribute = .forceRightToLeft
//
//            let button = FSButton()
//            button.setImage(UIImage(named: "gift"), for: .normal)
//            button.setTitle("Gifts", for: .normal)
//            button.setTitleColor(.black, for: .normal)
//            button.imagePosition = .left
//            button.spacingBetweenImageAndTitle = 5.0
//            button.backgroundColor = .cyan.withAlphaComponent(0.15)
//            canvasView.addSubview(button)
//            button.snp.makeConstraints { make in
//                make.center.equalToSuperview()
//            }
//        }
        
        do {
//            let label = UILabel()
//            label.text = "😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂"
//            label.font = UIFont.boldSystemFont(ofSize: 18.0)
//            label.textColor = .black
//            label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
//            navigationBar.titleView = label
            
//            navigationBar.title = "😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂"
//            navigationBar.leftItemViews = []
//            view.addSubview(navigationBar)
//            navigationBar.snp.makeConstraints { (make) in
//                make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
//                make.left.right.equalTo(0.0)
//            }
        }
        do {
            /*
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
             */
        }
//        do {
//            let toolBar = FSToolBar()
//            toolBar.backgroundView.backgroundColor = .yellow.withAlphaComponent(0.35)
//            view.addSubview(toolBar)
//            toolBar.snp.makeConstraints { make in
//                make.left.right.equalTo(0.0)
//                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
//            }
//        }
        
//        do {
//            let view = UIImageView()
//            canvasView.addSubview(view)
//            view.snp.makeConstraints { make in
//                make.size.equalTo(CGSize(width: 300.0, height: 150.0))
//                make.center.equalToSuperview()
//            }
//            view.image = GradientImageRenderer.render(.init(
//                size: .init(width: 300.0, height: 150.0),
//                colors: [.fs.colorWithHex(0xFC308C), .fs.colorWithHex(0x8771DE)],
//                locations: [0, 1],
//                direction: .leftToRight,
//                cornerRadius: 20.0))
//        }
    }
}

extension ViewController {
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
}
