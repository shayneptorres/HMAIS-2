//
//  BudgetListBudgetFormVC.swift
//  HMAIS
//
//  Created by Shayne Torres on 2/28/18.
//  Copyright © 2018 sptorres. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

enum BudgetType {
    case budget(amount: Double)
    case freeSpend
}

protocol BudgetFormDelegate {
    func budgetWasSet()
}

class BudgetListBudgetFormVC: UIViewController {
    
    
    @IBOutlet weak var budgetTextField: CurrencyTextField! {
        didSet {
            budgetTextField.delegate = budgetTextField
        }
    }
    
    @IBOutlet weak var btn: UIButton! {
        didSet {
            btn.layer.cornerRadius = 4
            
            btn.rx.tap.bind(onNext: {
                let amount = self.budgetTextField.text?.fromCurrencyToDouble() ?? 0.0
                self.setBudget(type: .budget(amount: amount))
                
                if let modal = self.parent as? ModalFormNav {
                    modal.tapToDismiss()
                    modal.tapToDismiss()
                }
            }).disposed(by: trash)

        }
    }
    
    let trash = DisposeBag()
    
    var list: ItemList?
    var delegate: BudgetFormDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        budgetTextField.becomeFirstResponder()
    }
    
    func setBudget(type: BudgetType) {
        guard var list = list else { return }
        switch type {
        case .budget(let amount):
            list.update { updatedList in
                updatedList.budget = amount
            }
            delegate?.budgetWasSet()
        case .freeSpend:
            break
        }
    }

}
