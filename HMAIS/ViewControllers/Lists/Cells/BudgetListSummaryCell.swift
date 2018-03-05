//
//  BudgetListSummaryCell.swift
//  HMAIS
//
//  Created by Shayne Torres on 2/25/18.
//  Copyright © 2018 sptorres. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class BudgetListSummaryCell: UITableViewCell {
    
    @IBOutlet weak var container: UIView!
    
    @IBOutlet weak var budgetLabel: UILabel!
    @IBOutlet weak var spentLabel: UILabel!
    @IBOutlet weak var remainingLabel: UILabel!
    
    var trash = DisposeBag()
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        let selectedColorView = UIView()
        selectedColorView.backgroundColor = #colorLiteral(red: 0.9677259326, green: 0.654524982, blue: 0.001560134231, alpha: 0.6016695205)
        self.selectedBackgroundView = selectedColorView
    }
    
    func configure(withList list: ItemList?, completion: (() -> ())? = nil ) {
        guard let list = list else { return }
        
        // Set Budget label appearance
        let currencyBudgetStr = "\(list.budget)".toCurrency()
        budgetLabel.text = "  \(currencyBudgetStr)  "
        budgetLabel.backgroundColor = #colorLiteral(red: 0.4830000103, green: 0.8349999785, blue: 0, alpha: 1)
        budgetLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        budgetLabel.layer.cornerRadius = budgetLabel.bounds.height/2
        budgetLabel.layer.masksToBounds = true
        
        // set spent label appearance
        let currencySpentStr = "\(list.spendAmount)".toCurrency()
        spentLabel.text = "  \(currencySpentStr)  "
        spentLabel.backgroundColor = #colorLiteral(red: 1, green: 0.2450000048, blue: 0.2259999961, alpha: 1)
        spentLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        spentLabel.layer.cornerRadius = spentLabel.bounds.height/2
        spentLabel.layer.masksToBounds = true
        
        // set remaining label appearance
        let currencyRemainingStr = "\(list.remainingAmount)".toCurrency()
        remainingLabel.text = "  \(currencyRemainingStr)  "
        remainingLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        if list.remainingAmount <= 0 {
            remainingLabel.backgroundColor = #colorLiteral(red: 1, green: 0.2450000048, blue: 0.2259999961, alpha: 1)
        } else {
            remainingLabel.backgroundColor = #colorLiteral(red: 0.4830000103, green: 0.8349999785, blue: 0, alpha: 1)
        }
        remainingLabel.layer.cornerRadius = remainingLabel.bounds.height/2
        remainingLabel.layer.masksToBounds = true
        
        container.layer.cornerRadius = 4
        container.applyShadow(.normal(.bottom))
        
        let tap = UITapGestureRecognizer()
        tap.rx.event.bind(onNext: { tap in
            completion?()
        }).disposed(by: trash)
        self.container.addGestureRecognizer(tap)
    }
    
    override func prepareForReuse() {
        trash = DisposeBag()
    }
    
}
