//
//  SwitchView.swift
//  FSUIKit
//
//  Created by VincentLee on 2025/4/9.
//  Copyright © 2025 Sheng. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import FSUIKitSwift

@objc(KTSwitchView)
class SwitchView: FSView {
    
    @objc var isOn: Bool {
        get { p_isOn }
        set {
            if p_isOn != newValue {
                p_setOn(newValue, animated: false)
            }
        }
    }
    
    @objc var onColor: UIColor = .blue {
        didSet {
            p_setOn(p_isOn, animated: false)
        }
    }
    
    @objc var offColor: UIColor = .fs.colorWithHex(0xbbb7b5) {
        didSet {
            p_setOn(p_isOn, animated: false)
        }
    }
    
    /// 调整 SwitchView 的响应范围。
    ///
    /// - Note:
    ///   top/left/bottom/right 为正数时是往内收缩响应范围，为负数时才是往外扩张响应范围，
    ///   所以，**如果你需要扩大响应范围的话应该赋值负数**。
    ///
    @objc var hitInsets: UIEdgeInsets = .zero
    
    /// 提供给外部的 on/off 值改变的回调
    var valueDriver: Driver<Bool> {
        valuePublisher.asDriver(onErrorJustReturn: false)
    }
    
    private let borderLayer = CAShapeLayer()
    private let knobLayer = CAShapeLayer()
    
    private var leftKnobFrame = CGRect.zero
    private var rightKnobFrame = CGRect.zero
    
    private let tap = UITapGestureRecognizer()
    private let rightSwipe = UISwipeGestureRecognizer()
    private let leftSwipe = UISwipeGestureRecognizer()
    
    private let disposeBag = DisposeBag()
    
    private var isAnimating = false
    
    private let delegater = _Delegater()
    
    private var p_isOn = false
    
    private let valuePublisher = PublishSubject<Bool>()
    
    override func didInitialize() {
        super.didInitialize()
        
        delegater.view = self
        
        layer.addSublayer(borderLayer)
        layer.addSublayer(knobLayer)
        
        borderLayer.borderWidth = Consts.borderWidth
        borderLayer.borderColor = offColor.cgColor
        knobLayer.backgroundColor = offColor.cgColor
        
        addGestureRecognizer(tap)
        addGestureRecognizer(rightSwipe)
        addGestureRecognizer(leftSwipe)
        
        tap.delegate = delegater
        tap.rx.event.subscribe(onNext: { [weak self] _ in
            guard let self else { return }
            self.gesture_setOn(!self.p_isOn, animated: true)
        }).disposed(by: disposeBag)
        
        rightSwipe.require(toFail: tap)
        rightSwipe.direction = .right
        rightSwipe.delegate = delegater
        rightSwipe.rx.event.subscribe(onNext: { [weak self] _ in
            guard let self else { return }
            if semanticContentAttribute == .forceRightToLeft {
                if self.p_isOn {
                    self.gesture_setOn(false, animated: true)
                }
            } else {
                if !self.p_isOn {
                    self.gesture_setOn(true, animated: true)
                }
            }
        }).disposed(by: disposeBag)
        
        leftSwipe.require(toFail: tap)
        leftSwipe.direction = .left
        leftSwipe.delegate = delegater
        leftSwipe.rx.event.subscribe(onNext: { [weak self] _ in
            guard let self else { return }
            if semanticContentAttribute == .forceRightToLeft {
                if !self.p_isOn {
                    self.gesture_setOn(true, animated: true)
                }
            } else {
                if self.p_isOn {
                    self.gesture_setOn(false, animated: true)
                }
            }
        }).disposed(by: disposeBag)
    }
    
    override var intrinsicContentSize: CGSize {
        .init(width: 44.0, height: 24.0)
    }
    
    open override var semanticContentAttribute: UISemanticContentAttribute {
        didSet {
            if semanticContentAttribute != oldValue {
                p_setOn(p_isOn, animated: false)
            }
        }
    }
    
    override func viewSizeDidChange() {
        super.viewSizeDidChange()
        let rect = CGRect(origin: .zero, size: viewSize)
        borderLayer.frame = rect
        borderLayer.cornerRadius = borderLayer.frame.height/2
        do {
            let inset = Consts.borderWidth + 2.0
            let knobFrame = borderLayer.frame.insetBy(dx: inset, dy: inset)
            let knobSize = CGSize(width: knobFrame.height, height: knobFrame.height).fs.floorFlatted()
            leftKnobFrame = .init(origin: knobFrame.origin, size: knobSize)
            rightKnobFrame = .init(origin: .init(x: knobFrame.maxX - knobSize.width, y: leftKnobFrame.minY), size: knobSize)
            knobLayer.cornerRadius = knobSize.height / 2
        }
        p_setOn(p_isOn, animated: false)
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard hitInsets != .zero, isUserInteractionEnabled, !isHidden, alpha > 0.1 else {
            return super.point(inside: point, with: event)
        }
        return bounds.inset(by: hitInsets).contains(point)
    }
    
    @objc
    func setOn(_ on: Bool, animated: Bool) {
        guard p_isOn != on else {
            return
        }
        p_setOn(on, animated: animated)
    }
}

private extension SwitchView {
    
    func gesture_setOn(_ on: Bool, animated: Bool) {
        if p_isOn != on {
            FSTapticEngine.impact.feedback(.rigid)
        }
        p_setOn(on, animated: true)
    }
    
    func p_setOn(_ on: Bool, animated: Bool) {
        isAnimating = true
        var animated = animated
        if viewSize.width <= 0.1 || viewSize.height <= 0.1 {
            animated = false
        }
        if p_isOn != on {
            p_isOn = on
            valuePublisher.onNext(on)
        }
        
        let knobToFrame: CGRect
        if semanticContentAttribute == .forceRightToLeft {
            knobToFrame = p_isOn ? leftKnobFrame : rightKnobFrame
        } else {
            knobToFrame = p_isOn ? rightKnobFrame : leftKnobFrame
        }
        
        if !animated {
            let color = p_isOn ? onColor.cgColor : offColor.cgColor
            borderLayer.borderColor = color
            knobLayer.backgroundColor = color
            knobLayer.frame = knobToFrame
            isAnimating = false
        } else {
            let duration = 0.25
            do {
                let background = CABasicAnimation(keyPath: "backgroundColor")
                background.fromValue = knobLayer.backgroundColor
                background.toValue = p_isOn ? onColor.cgColor : offColor.cgColor
                
                let position = CABasicAnimation(keyPath: "position")
                position.fromValue = knobLayer.position
                position.toValue = CGPoint(x: knobToFrame.midX, y: knobToFrame.midY)
                
                let group = CAAnimationGroup()
                group.animations = [background, position]
                group.duration = duration
                group.fillMode = .forwards
                group.timingFunction = .init(name: .easeOut)
                group.isRemovedOnCompletion = false
                group.delegate = delegater
                group.setValue("knob", forKey: "id")
                
                knobLayer.add(group, forKey: "knob")
            }
            do {
                let border = CABasicAnimation(keyPath: "borderColor")
                border.fromValue = borderLayer.borderColor
                border.toValue = p_isOn ? onColor.cgColor : offColor.cgColor
                border.duration = duration
                border.fillMode = .forwards
                border.timingFunction = .init(name: .easeOut)
                border.isRemovedOnCompletion = false
                border.delegate = delegater
                border.setValue("border", forKey: "id")
                
                borderLayer.add(border, forKey: "border")
            }
        }
    }
}

private extension SwitchView {
    
    func p_animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        isAnimating = false
        let color = p_isOn ? onColor.cgColor : offColor.cgColor
        if anim.value(forKey: "id") as? String == "knob" {
            knobLayer.backgroundColor = color
            knobLayer.frame = {
                if semanticContentAttribute == .forceRightToLeft {
                    return p_isOn ? leftKnobFrame : rightKnobFrame
                } else {
                    return p_isOn ? rightKnobFrame : leftKnobFrame
                }
            }()
        }
        if anim.value(forKey: "id") as? String == "border" {
            borderLayer.borderColor = color
        }
    }
    
    func p_gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer === tap || gestureRecognizer === leftSwipe || gestureRecognizer === rightSwipe else {
            return false
        }
        if isAnimating {
            return false
        }
        return true
    }
}

private extension SwitchView {
    struct Consts {
        static let borderWidth = 2.0
    }
}

private final class _Delegater: NSObject, UIGestureRecognizerDelegate, CAAnimationDelegate {
    
    weak var view: SwitchView?
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        view?.p_animationDidStop(anim, finished: flag)
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        view?.p_gestureRecognizerShouldBegin(gestureRecognizer) ?? true
    }
}
