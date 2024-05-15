//
//  FSCollectionInsetGroupLayoutDelegate.swift
//  FSUIKitSwift
//
//  Created by Sheng on 2024/5/15.
//  Copyright © 2024 Sheng. All rights reserved.
//

import UIKit

public protocol FSCollectionInsetGroupLayoutDelegate: AnyObject {
    
    func collectionView(_ collectionView: UICollectionView, groupCornerRadiusAt section: Int) -> CGFloat
    
    func collectionView(_ collectionView: UICollectionView, groupBackgroundColorAt section: Int) -> UIColor?
    
    func collectionView(_ collectionView: UICollectionView, shouldShowGroupAt section: Int) -> Bool
}

public extension FSCollectionInsetGroupLayoutDelegate {
    
    func collectionView(_ collectionView: UICollectionView, groupCornerRadiusAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, groupBackgroundColorAt section: Int) -> UIColor? {
        return nil
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldShowGroupAt section: Int) -> Bool {
        return true
    }
}
