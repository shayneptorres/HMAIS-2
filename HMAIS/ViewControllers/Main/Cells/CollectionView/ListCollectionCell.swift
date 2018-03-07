//
//  ListCollectionCell.swift
//  HMAIS
//
//  Created by Shayne Torres on 3/4/18.
//  Copyright © 2018 sptorres. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class ListCollectionCell: UICollectionViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    var list: ItemList?
    let trash = DisposeBag()
    var tapCompletion: ((_ item: ItemList) -> ())?
    
    func configure(withList list: ItemList) {
        self.list = list
        
        indicatorView.backgroundColor = list.listItemType.indicatorColor
        indicatorView.roundCorners(corners: [.topLeft, .bottomLeft], radii: 8)
        
        containerView.layer.cornerRadius = 8
        containerView.applyShadow(.normal(.bottom))
        
        nameLabel.text = list.name
        
        switch list.listItemType {
        case .shopping:
            infoLabel.text = "Status:"
            let complete = list.items.filter({ $0.completed })
            valueLabel.text = "\(complete.count)/\(list.items.count) completed"
            valueLabel.textColor = #colorLiteral(red: 0.4830000103, green: 0.8349999785, blue: 0, alpha: 1)
        case .budget:
            infoLabel.text = "Money remaining:"
            let total = list.budget - list.total
            valueLabel.text = "\(total)".toCurrency()
            valueLabel.textColor = total > 0 ? #colorLiteral(red: 0.4830000103, green: 0.8349999785, blue: 0, alpha: 1) : #colorLiteral(red: 1, green: 0.2450000048, blue: 0.2259999961, alpha: 1)
        case .new:
            infoLabel.text = "New list"
            valueLabel.text = "Tap to assign this list a category"
        }
        
        let tap = UITapGestureRecognizer()
        
        tap.rx.event.bind(onNext: { event in
            self.shrinkCell()
            self.tapCompletion?(list)
            Timer.after(0.3.seconds) {
                self.restoreCell()
            }
        })
        .disposed(by: trash)
        
        containerView.addGestureRecognizer(tap)
        
    }
    
    func shrinkCell() {
        transformCell(transform: CGAffineTransform(scaleX: 0.95, y: 0.95))
    }
    
    func restoreCell() {
        transformCell(transform: CGAffineTransform.identity)
    }
    
    func transformCell(transform: CGAffineTransform) {
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
            self.containerView.transform = transform
        }, completion: nil)
    }

}
