//
//  FSCollectionInsetGroupLayout.swift
//  FSUIKitSwift
//
//  Created by Sheng on 2024/5/13.
//  Copyright © 2024 Vincent. All rights reserved.
//

import UIKit

open class FSCollectionInsetGroupLayout: UICollectionViewFlowLayout {
    
    // MARK: Properties/Public
    
    public weak var delegate: FSCollectionInsetGroupLayoutDelegate?
    
    /// background color of group.
    /// Collection view needs reload when this property is changed.
    public var color: UIColor? = .white
    
    /// corner radius of group.
    /// Collection view needs reload when this property is changed.
    public var cornerRadius: CGFloat = 10.0
    
    // MARK: Properties/Private
    
    private var decorations = [Int: FSInsetGroupDecorationAttributes]()
    
    private let cornerDecorationViewKind = "_kCornerDecorationViewKind"
    
    // MARK: Initialization
    
    override public init() {
        super.init()
        p_didInitialize()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        p_didInitialize()
    }
    
    // MARK: Private
    
    private func p_didInitialize() {
        register(FSInsetGroupDecorationView.self, forDecorationViewOfKind: cornerDecorationViewKind)
    }
}

// MARK: - Override

extension FSCollectionInsetGroupLayout {
    
    override open func prepare() {
        super.prepare()
        var attributeses = [Int: FSInsetGroupDecorationAttributes]()
        defer {
            decorations = attributeses
        }
        guard let collectionView = collectionView else {
            return
        }
        let numberOfSections = collectionView.numberOfSections
        for section in 0..<numberOfSections {
            if let delegate = delegate, !delegate.collectionView(collectionView, shouldShowGroupAt: section) {
                continue
            }
            let numberOfItems = collectionView.numberOfItems(inSection: section)
            if numberOfItems <= 0 {
                continue
            }
            let firstItemIndexPath = IndexPath(item: 0, section: section)
            let lastItemIndexPath = IndexPath(item: numberOfItems - 1, section: section)
            if let firstItemAttributes = layoutAttributesForItem(at: firstItemIndexPath),
               let lastItemAttributes = layoutAttributesForItem(at: lastItemIndexPath) {
                let x = firstItemAttributes.frame.minX
                let y = firstItemAttributes.frame.minY
                let w = firstItemAttributes.frame.width
                let h = lastItemAttributes.frame.maxY - y
                let indexPath = IndexPath(item: 0, section: section)
                let attributes = FSInsetGroupDecorationAttributes(forDecorationViewOfKind: cornerDecorationViewKind, with: indexPath)
                attributes.frame = .init(x: x, y: y, width: w, height: h)
                attributes.zIndex = -1
                attributes.color = color ?? .clear
                attributes.cornerRadius = cornerRadius
                attributeses[section] = attributes
            }
        }
    }
    
    override open func layoutAttributesForDecorationView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if elementKind == cornerDecorationViewKind {
            return decorations[indexPath.section]
        }
        return super.layoutAttributesForDecorationView(ofKind: elementKind, at: indexPath)
    }
    
    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributes = super.layoutAttributesForElements(in: rect) ?? []
        attributes += decorations.values.filter { $0.frame.intersects(rect) }
        return attributes
    }
}

private final class FSInsetGroupDecorationAttributes: UICollectionViewLayoutAttributes {
    
    var color: UIColor = .white
    var cornerRadius: CGFloat = 10.0
    
    override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! FSInsetGroupDecorationAttributes
        copy.color = color
        copy.cornerRadius = cornerRadius
        return copy
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? FSInsetGroupDecorationAttributes else {
            return false
        }
        if !color.isEqual(rhs.color) {
            return false
        }
        if cornerRadius != rhs.cornerRadius {
            return false
        }
        return super.isEqual(object)
    }
}

private final class FSInsetGroupDecorationView: UICollectionReusableView {
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        guard let attributes = layoutAttributes as? FSInsetGroupDecorationAttributes else {
            return
        }
        backgroundColor = attributes.color
        layer.cornerRadius = attributes.cornerRadius
    }
}
