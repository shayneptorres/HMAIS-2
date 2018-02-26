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
    
    enum DisplayType {
        case editable
        case displayOnly
    }

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var completedImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var rightSpace: NSLayoutConstraint!
    @IBOutlet weak var leftSpace: NSLayoutConstraint!
    @IBOutlet weak var completionImageHeight: NSLayoutConstraint!
    
    @IBOutlet weak var infoBtnWidth: NSLayoutConstraint!
    
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
    var displayType: DisplayType = .editable
    
    var infoButtonTapCompletion: (() -> ())?
    
    func configure(withItem item: Item, completion: (()->())? = nil) {
        self.item = item
        containerView.layer.cornerRadius = 4
        containerView.applyShadow(.normal(.bottom))
        infoButtonTapCompletion = completion
        
        nameLabel.text = item.name
        quantityLabel.text = "x\(Int(item.quantity))"
        
        if displayType == .displayOnly {
            // if the cell is only displaying, hide the interaction buttons
            completedImageView.isHidden = true
            infoBtn.isHidden = true
            
            // shrink the left and right spaces so the cell doesnt look awkward
            leftSpace.constant = 0
            rightSpace.constant = 0
            completionImageHeight.constant = 0
            infoBtnWidth.constant = 0
        } else {
            // else show the interation buttons
            completedImageView.image = (item.completed) ? #imageLiteral(resourceName: "check.png") : #imageLiteral(resourceName: "circle.png")
        }
        
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

