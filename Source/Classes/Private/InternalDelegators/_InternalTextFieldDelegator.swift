//
//  _InternalTextFieldDelegator.swift
//  FSUIKitSwift
//
//  Created by Sheng on 2024/1/23.
//  Copyright © 2024 Sheng. All rights reserved.
//

import UIKit

final class _InternalTextFieldDelegator: NSObject, UITextFieldDelegate {
    
    var shouldReturn: ((_ textField: UITextField) -> Bool)?
    var shouldChangeCharacters: ((_ textField: UITextField, _ range: NSRange, _ string: String) -> Bool)?
    
    // MARK: Initialization
    
    override init() {
        super.init()
    }
    
    // MARK: <UITextFieldDelegate>
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return shouldReturn?(textField) ?? true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return shouldChangeCharacters?(textField, range, string) ?? true
    }
}

