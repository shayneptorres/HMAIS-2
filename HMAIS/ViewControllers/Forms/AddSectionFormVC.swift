//
//  AddSectionFormVC.swift
//  HMAIS
//
//  Created by Shayne Torres on 2/17/18.
//  Copyright © 2018 sptorres. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol AddSectionDelegate {
    func sectionWasAdded()
}

class AddSectionFormVC: UIViewController {
    
    let trash = DisposeBag()
    var list: ItemList?
    var delegate: AddSectionDelegate?

    @IBOutlet weak var textField: UITextField! {
        didSet {
            textField.placeholder = "Add new section"
        }
    }
    
    @IBOutlet weak var addBtn: UIButton! {
        didSet {
            
            addBtn.layer.cornerRadius = 4
            
            addBtn.rx.tap.bind(onNext:{
                guard
                    let text = self.textField.text,
                    text != "",
                    let list = self.list,
                    let modal = self.parent as? ModalFormNav
                else { return }
                
                let newSection = ListSection()
                newSection.name = text
                list.addSection(section: newSection)
                self.delegate?.sectionWasAdded()
                
                modal.tapToDismiss()
                modal.tapToDismiss()
            }).disposed(by: trash)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textField.becomeFirstResponder()
    }
    
    

}
