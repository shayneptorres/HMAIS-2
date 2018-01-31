//
//  NewListCell.swift
//  HMAIS
//
//  Created by Shayne Torres on 1/29/18.
//  Copyright © 2018 sptorres. All rights reserved.
//

import UIKit

protocol NewListCellDelegate {
    func saveList(name: String)
}

class NewListCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var nameTF: UITextField! {
        didSet {
            nameTF.delegate = self
        }
    }
    
    var delegate: NewListCellDelegate?
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let name = textField.text else { return false }
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let delegate = delegate else { return }
        delegate.saveList(name: textField.text ?? "")
        textField.text = ""
    }
    
    func startEditing() {
        nameTF.becomeFirstResponder()
    }
    
}
