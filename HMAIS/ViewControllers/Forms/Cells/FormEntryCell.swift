//
//  FormEntryCell.swift
//  HMAIS
//
//  Created by Shayne Torres on 2/2/18.
//  Copyright © 2018 sptorres. All rights reserved.
//

import UIKit

class FormEntryCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    
    func configure(withName name: String, value val: String) {
        nameLabel.text = name
        textField.text = val
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
}
