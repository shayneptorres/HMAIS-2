//
//  ItemFormVC.swift
//  HMAIS
//
//  Created by Shayne Torres on 2/21/18.
//  Copyright © 2018 sptorres. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

protocol CheckItemFormDelegate {
    func itemWasUpdated()
}

class CheckItemFormVC: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var countLabel: UILabel!
    
    @IBOutlet weak var saveBtn: UIButton! {
        didSet {
            saveBtn.rx.tap.bind(onNext: {
                guard
                    var item = self.editingItem,
                    self.editingItem?.name != "",
                    let delegate = self.delegate,
                    let modal = self.parent as? ModalFormNav
                else { return }
                
                item.update { updatedItem in
                    updatedItem.name = self.textField.text ?? ""
                    updatedItem.quantity = Double(self.count)
                }
                
                delegate.itemWasUpdated()
                
                modal.tapToDismiss()
                modal.tapToDismiss()
            }).disposed(by: trash)
        }
    }
    
    @IBOutlet weak var decrementBtn: UIButton! {
        didSet {
            decrementBtn.rx.tap.bind(onNext: {
                guard var item = self.editingItem else { return }
                self.count > 0 ? (self.count -= 1) : ()
                self.countLabel.text = "\(self.count)"
            }).disposed(by: trash)
        }
    }
    
    
    @IBOutlet weak var incrementBtn: UIButton! {
        didSet {
            incrementBtn.rx.tap.bind(onNext: {
                guard var item = self.editingItem else { return }
                self.count += 1
                self.countLabel.text = "\(self.count)"
            }).disposed(by: trash)
        }
    }
    
    let trash = DisposeBag()
    var editingItem: Item?
    var delegate: CheckItemFormDelegate?
    
    var count = 0
    var name = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure(withItem: editingItem)
        self.textField.becomeFirstResponder()
    }
    
    func configure(withItem item: Item?) {
        guard let item = item else { return }
        
        textField.text = item.name
        countLabel.text = "\(Int(item.quantity))"
        
        count = Int(item.quantity)
        name = item.name
        
        self.editingItem = item
    }
    
    

}
