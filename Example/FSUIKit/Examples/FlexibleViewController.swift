//
//  FlexibleViewController.swift
//  FSUIKit_Example
//
//  Created by Sheng on 2024/3/13.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import SnapKit
import FSUIKit_Swift

class FlexibleViewController: UIViewController {
    
    private let flexibleView = FSFlexibleView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            view.addSubview(flexibleView)
            flexibleView.snp.makeConstraints { (make) in
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
                make.left.bottom.right.equalTo(0.0)
            }
        }
        do {
            let contentInset = UIEdgeInsets(top: 15.0, left: 15.0, bottom: 15.0, right: 15.0)
            let layoutWidth = UIScreen.fs.portraitWidth - contentInset.fs.horizontalValue()
            let itemSpacing: CGFloat = 8.0
            let lineSpacing: CGFloat = 10.0
            var items = [FSFlexibleItem]()
            var last: FSFlexibleItem?
            for index in 0..<20 {
                let width: CGFloat = CGFloat(arc4random() % 100) + 50.0
                let size = CGSize(width: width, height: 30.0)
                let x: CGFloat = {
                    if let last = last {
                        let rightSpacing = layoutWidth - last.frame.maxX - itemSpacing
                        if rightSpacing >= size.width {
                            return last.frame.maxX + itemSpacing
                        }
                    }
                    return contentInset.left
                }()
                let y: CGFloat = {
                    if let last = last {
                        let rightSpacing = layoutWidth - last.frame.maxX - itemSpacing
                        if rightSpacing >= size.width {
                            return last.frame.minY
                        }
                        return last.frame.maxY + lineSpacing
                    }
                    return contentInset.top
                }()
                
                let item = _FlexibleItem()
                item.index = index
                item.frame = CGRect(origin: .init(x: x, y: y), size: size)
                item.onDidSelect = { _, index in
                    print("did select: [\(index)]")
                }
                items.append(item)
                last = item
                if index == 0 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        item.index = 100
                        item.reload(.rerender)
                    }
                }
            }
            flexibleView.items = items
        }
    }
}

private class _FlexibleItem: FSFlexibleItem {
    
    var index = 0
    
    override init() {
        super.init()
        cellType = _FlexibleCell.self
    }
}

private class _FlexibleCell: FSFlexibleCell {
    
    private let textLabel = UILabel()
    
    // MARK: Initialization
    
    required init() {
        super.init()
        
        backgroundColor = UIColor.red.withAlphaComponent(0.3)
        layer.cornerRadius = 3.0
        
        textLabel.font = .systemFont(ofSize: 12.0)
        textLabel.textColor = .white
        addSubview(textLabel)
        textLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    // MARK: Override
    
    override func render(with item: FSFlexibleItem) {
        super.render(with: item)
        guard let item = item as? _FlexibleItem else {
            return
        }
        textLabel.text = "\(item.index)"
    }
}
