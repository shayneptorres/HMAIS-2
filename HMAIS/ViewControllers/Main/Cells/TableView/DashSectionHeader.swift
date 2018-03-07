//
//  DashSectionHeader.swift
//  HMAIS
//
//  Created by Shayne Torres on 3/4/18.
//  Copyright © 2018 sptorres. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift

class DashSectionHeader: UITableViewHeaderFooterView {
    
    @IBOutlet weak var sectionName: UILabel!
    
    @IBOutlet weak var addBtn: UIButton! {
        didSet {
            
            addBtn.isHidden = true
            
            addBtn.rx.tap.bind(onNext: {
                self.addCompletion?()
            })
            .disposed(by: trash)
        }
    }
    
    var addCompletion: (() -> ())? = nil {
        willSet(comp) {
            addBtn.isHidden = (comp == nil)
        }
    }
    
    let trash = DisposeBag()
    
    func configure(withName name: String) {
        sectionName.text = name
    }
    
}
