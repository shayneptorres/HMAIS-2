//
//  BudgetListCell.swift
//  HMAIS
//
//  Created by Shayne Torres on 2/26/18.
//  Copyright © 2018 sptorres. All rights reserved.
//

import UIKit

class BudgetItemCell: UITableViewCell {

    @IBOutlet weak var container: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    var item: Item!
    
    func configure(withItem item: Item) {
        self.item = item
        nameLabel.text = item.name
        let currency = "\(item.price)".toCurrency()
        priceLabel.text = "  \(currency)  "
        priceLabel.backgroundColor = #colorLiteral(red: 0.4830000103, green: 0.8349999785, blue: 0, alpha: 1)
        priceLabel.textColor = .white
        priceLabel.layer.cornerRadius = priceLabel.frame.height/2
        priceLabel.layer.masksToBounds = true
        
        container.layer.cornerRadius = 4
        container.applyShadow(.normal(.bottom))
    }
    
}
