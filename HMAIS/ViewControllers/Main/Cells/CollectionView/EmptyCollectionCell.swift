//
//  EmptyCollectionCell.swift
//  HMAIS
//
//  Created by Shayne Torres on 3/5/18.
//  Copyright © 2018 sptorres. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class EmptyCollectionCell: UICollectionViewCell {

    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var addBtn: UIButton! {
        didSet{
            addBtn.rx.tap.bind(onNext: {
                self.btnTapCompletion?()
            })
            .disposed(by: trash)
        }
    }
    
    let trash = DisposeBag()
    var btnTapCompletion: (() -> ())?
    
    func configure(completion: (() -> ())?) {
        self.btnTapCompletion = completion
        
        containerView.layer.cornerRadius = 8
        containerView.applyShadow(.normal(.bottom))
    }
    
}
