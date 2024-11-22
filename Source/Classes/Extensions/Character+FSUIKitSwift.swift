//
//  Character+FSUIKitSwift.swift
//  FSUIKitSwift
//
//  Created by VincentLee on 2024/11/22.
//

import Foundation
import CryptoKit
import CommonCrypto

public extension FSUIKitWrapper where Base == Character {
    
    /// A simple emoji is one scalar and presented to the user as an Emoji
    var isSimpleEmoji: Bool {
        guard let firstScalar = base.unicodeScalars.first else { return false }
        return firstScalar.properties.isEmoji && firstScalar.value > 0x238C
    }

    /// Checks if the scalars will be merged into an emoji
    var isCombinedIntoEmoji: Bool {
        base.unicodeScalars.count > 1 && base.unicodeScalars.first?.properties.isEmoji ?? false
    }

    var isEmoji: Bool {
        isSimpleEmoji || isCombinedIntoEmoji
    }
}
