//
//  CollectionInsetGroupViewController.swift
//  FSUIKit_Example
//
//  Created by Sheng on 2024/5/13.
//  Copyright © 2024 Sheng. All rights reserved.
//

import UIKit
import SnapKit
import FSUIKitSwift

final class CollectionInsetGroupViewController: FSViewController {
    
    // MARK: Properties/Private
    
    private let layout = FSCollectionInsetGroupLayout()
    
    private lazy var collectionView: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.delegate = self
        collection.dataSource = self
        collection.backgroundColor = .fs.groupBackground
        collection.register(Cell.self, forCellWithReuseIdentifier: "cell")
        return collection
    }()
    
    private var numberOfItems = [Int]()
    
    private var itemSize = CGSize.zero
    
    // MARK: Initialization
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        p_didInitialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        p_didInitialize()
    }
}

// MARK: - Life Cycle

extension CollectionInsetGroupViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        p_setupViews()
    }
}

// MARK: - Override

extension CollectionInsetGroupViewController {
    
    override func viewSizeDidChange() {
        super.viewSizeDidChange()
        itemSize.width = viewSize.width - 16.0 * 2
        collectionView.reloadData()
    }
}

// MARK: - Private

private extension CollectionInsetGroupViewController {
    
    /// Called after initialization.
    func p_didInitialize() {
        itemSize.height = 44.0
        numberOfItems = Array(0..<10).map { _ in Int(arc4random() % 5) + 1 }
        layout.delegate = self
    }
    
    /// Called in the `viewDidLoad` method.
    func p_setupViews() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(0.0)
        }
    }
}

// MARK: - UICollectionViewDataSource

extension CollectionInsetGroupViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return numberOfItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfItems[section]
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? Cell else {
            fatalError()
        }
        let numberOfItems = numberOfItems[indexPath.section]
        cell.textLabel.text = "Section: \(indexPath.section), Row: \(indexPath.row)"
        cell.separatorView.isHidden = indexPath.row == (numberOfItems - 1)
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension CollectionInsetGroupViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return itemSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 10.0, left: 16.0, bottom: 0.0, right: 16.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
}

// MARK: - FSCollectionInsetGroupLayoutDelegate

extension CollectionInsetGroupViewController: FSCollectionInsetGroupLayoutDelegate {
    
    func collectionView(_ collectionView: UICollectionView, shouldShowGroupAt section: Int) -> Bool {
//        if section == 0 {
//            return false
//        }
        return true
    }
}

private final class Cell: UICollectionViewCell {
    
    let textLabel = UILabel()
    let separatorView = FSSeparatorView()
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        p_didInitialize()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Private
    
    private func p_didInitialize() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        textLabel.font = .systemFont(ofSize: 15.0)
        textLabel.textColor = .black
        contentView.addSubview(textLabel)
        textLabel.snp.makeConstraints { make in
            make.left.equalTo(12.0)
            make.centerY.equalToSuperview()
        }
        
        contentView.addSubview(separatorView)
        separatorView.snp.makeConstraints { make in
            make.left.equalTo(12.0)
            make.bottom.equalTo(0.0)
            make.right.equalTo(-12.0)
            make.height.equalTo(UIScreen.fs.pixelOne)
        }
    }
}
