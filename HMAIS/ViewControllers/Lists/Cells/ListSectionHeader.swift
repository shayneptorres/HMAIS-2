//
//  ListSectionHeader.swift
//  HMAIS
//
//  Created by Shayne Torres on 2/17/18.
//  Copyright © 2018 sptorres. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class ListSectionHeader: UITableViewHeaderFooterView {
    
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addBtn: UIButton! {
        didSet {
            addBtn.rx.tap.bind(onNext: {
                self.addCompletion?()
            }).disposed(by: trash)
        }
    }
    
    let trash = DisposeBag()
    var addCompletion: (() -> ())?
    
    func configure(withName name: String, completion: (() -> ())?) {
        nameLabel.text = name
        self.addCompletion = completion
    }

}
