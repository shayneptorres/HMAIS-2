//
//  BudgetListCell.swift
//  HMAIS
//
//  Created by Shayne Torres on 2/26/18.
//  Copyright © 2018 sptorres. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class BudgetItemCell: UITableViewCell {

    @IBOutlet weak var container: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    var item: Item!
    let trash = DisposeBag()
    
    func configure(withItem item: Item, completion: (() -> ())?) {
        self.item = item
        nameLabel.text = item.name
        let currency = "\(item.price)".toCurrency()
        priceLabel.text = "  \(currency)  "
        priceLabel.backgroundColor = #colorLiteral(red: 0.4830000103, green: 0.8349999785, blue: 0, alpha: 1)
        priceLabel.textColor = .white
        priceLabel.layer.cornerRadius = priceLabel.frame.height/2
        priceLabel.layer.masksToBounds = true
        
        container.layer.cornerRadius = 4
        container.applyShadow(.normal(.bottom))
        
        let tap = UITapGestureRecognizer()
        
        tap.rx.event.bind(onNext: { gesture in
            self.applyTransform(type: .shrink, animated: true, duration: 0.3)
            completion?()
            Timer.after(0.1.second, {
                self.applyTransform(type: .restore, animated: true, duration: 0.3)
            })
        })
            .disposed(by: trash)
        
        self.container.addGestureRecognizer(tap)
    }
    
    /// https://stackoverflow.com/questions/8603359/change-default-icon-for-moving-cells-in-uitableview
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        if editing {
            if var reorderView = findReorderViewInView(view: self),
                let imageView = reorderView.subviews.filter({ $0 is UIImageView }).first as? UIImageView {
                //                imageView.image = UIImage(named: "yourImage")
                reorderView.backgroundColor = #colorLiteral(red: 0.9369999766, green: 0.9369999766, blue: 0.9369999766, alpha: 1)
            }
        }
    }
    
    func findReorderViewInView(view: UIView) -> UIView? {
        for subview in view.subviews {
            
            if String(describing: subview).range(of: "Reorder") != nil {
                return subview
            }
            else {
                findReorderViewInView(view: subview)
            }
        }
        return nil
    }
    
}
