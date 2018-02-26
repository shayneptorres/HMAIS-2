//
//  InsetTextField.swift
//  HMAIS
//
//  Created by Shayne Torres on 2/25/18.
//  Copyright © 2018 sptorres. All rights reserved.
//

import Foundation
import UIKit

class InsetTextField: UITextField {
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 16, dy: 0)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 16, dy: 0)
    }
}
