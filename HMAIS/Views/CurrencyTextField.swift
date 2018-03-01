//
//  CurrencyTextField.swift
//  HMAIS
//
//  Created by Shayne Torres on 2/26/18.
//  Copyright © 2018 sptorres. All rights reserved.
//

import Foundation
import UIKit

class CurrencyTextField: UITextField, UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let costStringOp = textField.text?
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
