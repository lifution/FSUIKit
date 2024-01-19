//
//  FSTapticEngine.swift
//  FSUIKit
//
//  Created by Sheng on 2024/1/19.
//  Copyright © 2024 Sheng. All rights reserved.
//

import UIKit

/// 线性马达震动效果(Taptic Engine)，用于增加用户交互体验。
public final class FSTapticEngine {
    
    /// 单击
    public static let impact = Impact()
    /// 选中
    public static let selection = Selection()
    /// 通知
    public static let notification = Notification()
    
    /// 单击
    public final class Impact {
        
        public enum Style {
            case light
            case medium
            case heavy
            @available(iOS 13.0, *)
            case soft
            @available(iOS 13.0, *)
            case rigid
        }
        
        // MARK: Properties/Private
        
        private var style = FSTapticEngine.Impact.Style.light
        private var generator: UIImpactFeedbackGenerator?
        
        // MARK: Initialization
        
        init() {
            generator = p_makeGenerator(style)
        }
        
        // MARK: Private
        
        private func p_makeGenerator(_ style: FSTapticEngine.Impact.Style) -> UIImpactFeedbackGenerator? {
            let feedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle
            switch style {
            case .light:
                feedbackStyle = .light
            case .medium:
                feedbackStyle = .medium
            case .heavy:
                feedbackStyle = .heavy
            case .soft:
                if #available(iOS 13.0, *) {
                    feedbackStyle = .soft
                } else {
                    feedbackStyle = .light
                }
            case .rigid:
                if #available(iOS 13.0, *) {
                    feedbackStyle = .rigid
                } else {
                    feedbackStyle = .light
                }
            }
            return UIImpactFeedbackGenerator(style: feedbackStyle)
        }
        
        private func p_updateGeneratorIfNeeded(_ style: FSTapticEngine.Impact.Style) {
            guard self.style != style else { return }
            generator = p_makeGenerator(style)
            self.style = style
        }
        
        // MARK: Public
        
        public func feedback(_ style: FSTapticEngine.Impact.Style) {
            p_updateGeneratorIfNeeded(style)
            generator?.prepare()
            generator?.impactOccurred()
        }
        
        public func prepare(_ style: FSTapticEngine.Impact.Style) {
            p_updateGeneratorIfNeeded(style)
            generator?.prepare()
        }
    }
    
    /// 选中
    public final class Selection {
        
        // MARK: Properties/Private
        
        private let generator = UISelectionFeedbackGenerator()
        
        // MARK: Public
        
        public func feedback() {
            generator.prepare()
            generator.selectionChanged()
        }
        
        public func prepare() {
            generator.prepare()
        }
    }
    
    /// 通知
    public final class Notification {
        
        public enum Style {
            case success
            case warning
            case error
        }
        
        // MARK: Properties/Private
        
        private let generator = UINotificationFeedbackGenerator()
        
        // MARK: Public
        
        public func feedback(_ style: FSTapticEngine.Notification.Style) {
            let feedbackType: UINotificationFeedbackGenerator.FeedbackType
            switch style {
            case .success:
                feedbackType = .success
            case .warning:
                feedbackType = .warning
            case .error:
                feedbackType = .error
            }
            generator.prepare()
            generator.notificationOccurred(feedbackType)
        }
        
        public func prepare() {
            generator.prepare()
        }
    }
}
