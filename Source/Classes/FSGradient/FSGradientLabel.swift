//
//  FSGradientLabel.swift
//  FSUIKitSwift
//
//  Created by Sheng on 2023/11/4.
//  Copyright (c) 2023 Sheng. All rights reserved.
//

import UIKit
import Combine

open class FSGradientLabel: UIView {
    
    open var text: String? {
        get { return textLabel.text }
        set {
            textLabel.text = newValue
            invalidateIntrinsicContentSize()
            setNeedsUpdateConstraints()
        }
    }
    
    open var font: UIFont? {
        get { return textLabel.font }
        set {
            textLabel.font = newValue ?? .systemFont(ofSize: 16.0)
            invalidateIntrinsicContentSize()
            setNeedsUpdateConstraints()
        }
    }
    
    open var colors: [UIColor]? {
        get { return provider.colors }
        set { provider.colors = newValue }
    }
    
    open var locations: [NSNumber]? {
        get { return provider.locations }
        set { provider.locations = newValue }
    }
    
    open var startPoint: CGPoint {
        get { return provider.startPoint }
        set { provider.startPoint = newValue }
    }
    
    open var endPoint: CGPoint {
        get { return provider.endPoint }
        set { provider.endPoint = newValue }
    }
    
    open var gradientType: CAGradientLayerType {
        get { return provider.gradientType }
        set { provider.gradientType = newValue }
    }
    
    // MARK: =
    
    private let textLabel = UILabel()
    private let provider = FSGradientLabelDataProvider()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: =
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        p_didInitialize()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        p_didInitialize()
    }
    
    // MARK: =
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        let rect = CGRect(origin: .zero, size: frame.size)
        textLabel.frame = rect
        provider.size = rect.size
    }
    
    open override func sizeToFit() {
        var frame = self.frame
        frame.size = sizeThatFits(.init(
            width: CGFloat.greatestFiniteMagnitude,
            height: CGFloat.greatestFiniteMagnitude
        ))
        self.frame = frame
    }
    
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        return textLabel.sizeThatFits(size)
    }
    
    open override var intrinsicContentSize: CGSize {
        return textLabel.intrinsicContentSize
    }
}

// MARK: =

private extension FSGradientLabel {
    
    /// Invoked after initialization.
    func p_didInitialize() {
        addSubview(textLabel)
        provider.colorRelay
            .debounce(for: .milliseconds(100), scheduler: RunLoop.main)
            .sink { [weak self] color in
                guard let self else { return }
                self.textLabel.textColor = color
            }
            .store(in: &cancellables)
    }
}

private final class FSGradientLabelDataProvider {
    
    let colorRelay = CurrentValueSubject<UIColor, Never>(.black)
    private let drawImageQueue = DispatchQueue(label: "com.fs.gradient.label.provider.queue.serial")
    
    var size: CGSize = .zero {
        didSet {
            if !size.fs.isEqual(to: oldValue, tolerance: 0.2) {
                updateColorIfPossible()
            }
        }
    }
    
    var colors: [UIColor]? {
        didSet {
            if !areColorArraysEqualInLightMode(colors, oldValue) {
                updateColorIfPossible()
            }
        }
    }
    
    var locations: [NSNumber]? {
        didSet {
            if !areNSNumberArraysEqual(locations, oldValue) {
                updateColorIfPossible()
            }
        }
    }
    
    var startPoint: CGPoint = .zero {
        didSet {
            if startPoint != oldValue {
                updateColorIfPossible()
            }
        }
    }
    
    var endPoint: CGPoint = .init(x: 1.0, y: 1.0) {
        didSet {
            if endPoint != oldValue {
                updateColorIfPossible()
            }
        }
    }
    
    var gradientType: CAGradientLayerType = .axial {
        didSet {
            if gradientType != oldValue {
                updateColorIfPossible()
            }
        }
    }
    
    private func updateColorIfPossible() {
        guard !size.fs.isEqual(to: .zero, tolerance: 0.2) else {
            return
        }
        let size = size
        let colors = colors ?? [.black]
        let locations = locations
        let startPoint = startPoint
        let endPoint = endPoint
        let type = gradientType
        drawImageQueue.async { [weak self] in
            guard let self else { return }
            if colors.count == 1 {
                self.colorRelay.send(colors[0])
                return
            }
            let image = UIImage.fs.gradientImage(
                size: size,
                colors: colors,
                locations: locations,
                startPoint: startPoint,
                endPoint: endPoint,
                type: type
            )
            let color = UIColor(patternImage: image)
            self.colorRelay.send(color)
        }
    }
}

fileprivate func areColorArraysEqualInLightMode(_ lhs: [UIColor]?, _ rhs: [UIColor]?) -> Bool {
    switch (lhs, rhs) {
    case (nil, nil):
        return true
    case let (l?, r?):
        guard l.count == r.count else {
            return false
        }
        for (color1, color2) in zip(l, r) {
            if !color1.fs.isEqualToColor(color2, for: .light) {
                return false
            }
        }
        return true
    default:
        return false
    }
}

fileprivate func areNSNumberArraysEqual(_ lhs: [NSNumber]?, _ rhs: [NSNumber]?) -> Bool {
    switch (lhs, rhs) {
    case (nil, nil):
        return true
    case let (l?, r?):
        guard l.count == r.count else { return false }
        for (a, b) in zip(l, r) {
            if a != b {
                return false
            }
        }
        return true
    default:
        return false
    }
}

