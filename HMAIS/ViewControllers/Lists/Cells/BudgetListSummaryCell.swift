//
//  BudgetListSummaryCell.swift
//  HMAIS
//
//  Created by Shayne Torres on 2/25/18.
//  Copyright © 2018 sptorres. All rights reserved.
//

import UIKit

class BudgetListSummaryCell: UITableViewCell {
    
    @IBOutlet weak var container: UIView!
    
    @IBOutlet weak var budgetLabel: UILabel!
    @IBOutlet weak var spentLabel: UILabel!
    @IBOutlet weak var remainingLabel: UILabel!
    
    func configure(withList list: ItemList?) {
        guard let list = list else { return }
        budgetLabel.text = "\(list.budget)".toCurrency()
        spentLabel.text = "\(list.spendAmount)".toCurrency()
        remainingLabel.text = "\(list.remainingAmount)".toCurrency()
        
        spentLabel.textColor = #colorLiteral(red: 1, green: 0.2450000048, blue: 0.2259999961, alpha: 1)
        
        if list.remainingAmount <= 0 {
            remainingLabel.textColor = #colorLiteral(red: 1, green: 0.2450000048, blue: 0.2259999961, alpha: 1)
        } else {
            remainingLabel.textColor = #colorLiteral(red: 0.4830000103, green: 0.8349999785, blue: 0, alpha: 1)
        }
        
        container.layer.cornerRadius = 4
        container.applyShadow(.normal(.bottom))
    }
    
}
