//
//  AddBtnCell.swift
//  HMAIS
//
//  Created by Shayne Torres on 1/29/18.
//  Copyright © 2018 sptorres. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class AddBtnCell: UITableViewCell {
    
    var completion: (() -> ())?
    let trash = DisposeBag()
    
    @IBOutlet weak var addBtn: UIButton! {
        didSet {
            addBtn.rx.tap.bind(onNext: { [weak self] in
                guard let s = self, let compl = s.completion else { return }
                compl()
            }).disposed(by: trash)
        }
    }
    
    func configure(with name: String, completion: @escaping ()->()) {
        addBtn.setTitle(name, for: .normal)
        self.completion = completion
    }
    
}
