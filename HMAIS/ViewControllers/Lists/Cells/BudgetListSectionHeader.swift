//
//  BudgetListSectionHeader.swift
//  HMAIS
//
//  Created by Shayne Torres on 2/27/18.
//  Copyright © 2018 sptorres. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift

class BudgetListSectionHeader: UITableViewHeaderFooterView {
    
    @IBOutlet weak var sectionNameLabel: UILabel!
    @IBOutlet weak var sectionCostLabel: UILabel!
    @IBOutlet weak var container: UIView!
    
    
    @IBOutlet weak var btn: UIButton! {
        didSet {
            btn.rx.tap.bind(onNext: {
                self.btnPressCompletion?()
            }).disposed(by: trash)
        }
    }
    
    
    let trash = DisposeBag()
    var btnPressCompletion: (() -> ())?
    
    func configure(withSection section: ListSection, completion: (() -> ())? ) {
        container.applyShadow(.light(.bottom))
        self.btnPressCompletion = completion
        sectionNameLabel.text = section.name
        let total = section.getSectionTotal()
        sectionCostLabel.text = "\(total)".toCurrency()
    }
    
    
}
