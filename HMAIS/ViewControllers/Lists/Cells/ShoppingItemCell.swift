//
//  ShoppingItemCell.swift
//  HMAIS
//
//  Created by Shayne Torres on 2/17/18.
//  Copyright © 2018 sptorres. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class ShoppingItemCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var completedImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    
    @IBOutlet weak var infoBtn: UIButton! {
        didSet {
            infoBtn.rx
                    .tap
                .bind(onNext: {
                    self.infoButtonTapCompletion?()
                })
                .disposed(by: trash)
        }
    }
    
    var item: Item?
    let trash = DisposeBag()
    
    var infoButtonTapCompletion: (() -> ())?
    
    func configure(withItem item: Item, completion: (()->())? = nil) {
        self.item = item
        containerView.layer.cornerRadius = 4
        containerView.applyShadow(.normal(.bottom))
        infoButtonTapCompletion = completion
        
        nameLabel.text = item.name
        quantityLabel.text = "x\(Int(item.quantity))"
        completedImageView.image = (item.completed) ? #imageLiteral(resourceName: "check.png") : #imageLiteral(resourceName: "circle.png")
    }
    
    
}

