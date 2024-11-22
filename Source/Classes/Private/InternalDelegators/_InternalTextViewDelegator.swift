//
//  _InternalTextViewDelegator.swift
//  FSUIKitSwift
//
//  Created by Sheng on 2024/1/23.
//  Copyright © 2024 Sheng. All rights reserved.
//

import UIKit

final class _InternalTextViewDelegator: NSObject, FSTextViewDelegate {
    
    var textDidChange: ((_ textView: UITextView) -> Void)?
    var shouldChangeText: ((_ textView: UITextView, _ range: NSRange, _ text: String) -> Bool)?
    
    // MARK: Initialization
    
    override init() {
        super.init()
    }
    
    // MARK: <UITextFieldDelegate>
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return shouldChangeText?(textView, range, text) ?? true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        textDidChange?(textView)
    }
}
