//
//  EmtpyTableCell.swift
//  HMAIS
//
//  Created by Shayne Torres on 2/17/18.
//  Copyright © 2018 sptorres. All rights reserved.
//

import UIKit

class EmptyTableCell: UITableViewCell {

    @IBOutlet weak var container: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    
    func configure(withMessage message: String) {
        messageLabel.text = message
        container.layer.cornerRadius = 4
        container.applyShadow(.normal(.bottom))
    }
}
