//
//  SpendingCostCell.swift
//  HMAIS
//
//  Created by Shayne Torres on 2/1/18.
//  Copyright © 2018 sptorres. All rights reserved.
//

import UIKit

class SpendingCostCell: UITableViewCell {

    @IBOutlet weak var costTF: UITextField! {
        didSet {
            costTF.delegate = self
        }
    }
    
    func configure(with cost: Double) {
        self.selectionStyle = .none
        costTF.text = String(cost).toCurrency()
    }
    
}

extension SpendingCostCell: UITextFieldDelegate {
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var costStringOp = textField.text?
                                .replacingOccurrences(of: "$", with: "")
                                .replacingOccurrences(of: ",", with: "")
                                .replacingOccurrences(of: ".", with: "")
        
        var cost = 0.0
        
        if string == "" {
            // the user is deleting a number
            guard
                let costString = costStringOp,
                let newCostString = ("\(costString.dropLast())") as? String,
                let doubleCost = Double(newCostString)
            else { return false }
            cost = doubleCost
        } else {
            guard
                let costString = costStringOp,
                let newCostString = (costString + string) as? String,
                let doubleCost = Double(newCostString)
            else { return false }
            cost = doubleCost
        }
        
        cost /= 100
        textField.text = String(cost).toCurrency()
        
        return false
    }
}
