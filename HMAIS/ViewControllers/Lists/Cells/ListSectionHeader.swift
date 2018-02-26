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

enum SectionHeaderButtonStyle {
    case none
    case add
    case delete
}

class ListSectionHeader: UITableViewHeaderFooterView {
    
    
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addBtn: UIButton! {
        didSet {
            addBtn.rx.tap.bind(onNext: {
                self.btnCompletion?()
            }).disposed(by: trash)
        }
    }
    
    let trash = DisposeBag()
    var btnCompletion: (() -> ())?
    var btnStyle: SectionHeaderButtonStyle = .add
    
    func configure(withName name: String, completion: (() -> ())?) {
        nameLabel.text = name
        self.btnCompletion = completion
        container.applyShadow(.light(.bottom))
        var btnImage: UIImage?
        switch btnStyle {
        case .none:
            btnImage = nil
        case .add:
            btnImage = #imageLiteral(resourceName: "add_circle.png")
        case .delete:
            btnImage = #imageLiteral(resourceName: "delete_circle.png")
        }
        
        self.addBtn.setImage(btnImage, for: .normal)
    }

}
