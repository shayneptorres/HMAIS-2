//
//  BudgetItemForm.swift
//  HMAIS
//
//  Created by Shayne Torres on 2/26/18.
//  Copyright © 2018 sptorres. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol BudgetItemFormDelegate {
    func itemWasAdded()
}

class BudgetItemForm: UIViewController {

    @IBOutlet weak var costTextField: CurrencyTextField! {
        didSet {
            costTextField.delegate = costTextField
        }
    }
    
    @IBOutlet weak var nameTextField: InsetTextField! {
        didSet {
            nameTextField.delegate = self
        }
    }
    
    @IBOutlet weak var addBtn: UIButton! {
        didSet {
            
            addBtn.layer.cornerRadius = 4
            
            addBtn.rx.tap.bind(onNext: {
                guard
                    self.nameTextField.text != "",
                    let modal = self.parent as? ModalFormNav
                else { return }
                
                if self.item != nil {
                    // updating an existing item
                    self.updateExistingItem()
                } else {
                    //creating a new item
                    self.createNewItem()
                }
                
                self.delegate?.itemWasAdded()
                modal.tapToDismiss()
                modal.tapToDismiss()
                
            }).disposed(by: trash)
        }
    }
    
    @IBOutlet weak var sectionPicker: UIPickerView! {
        didSet {
            sectionPicker.delegate = self
            sectionPicker.dataSource = self
        }
    }
    
    @IBOutlet weak var costContainer: UIView! {
        didSet {
            
            let tap = UITapGestureRecognizer(target: nil, action: #selector(selectCostField))
            tap.rx.event.bind(onNext: { gesture in
                self.costTextField.becomeFirstResponder()
            })
            costContainer.addGestureRecognizer(tap)
            
        }
    }
    
    
    @IBOutlet weak var pickerHeight: NSLayoutConstraint!
    @IBOutlet weak var addItemToSectionLabel: UILabel!
    
    @IBOutlet weak var nameTFcontainer: UIView! {
        didSet {
            nameTFcontainer.applyShadow(.normal(.bottom))
            nameTFcontainer.layer.cornerRadius = 4
        }
    }
    
    let trash = DisposeBag()
    var delegate: BudgetItemFormDelegate?
    var list: ItemList?
    var item: Item?
    var selectedSection: ListSection?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let list = list else { return }
        
        if let item = item {
            nameTextField.text = item.name
            costTextField.text = "\(item.price)".toCurrency()
        }
        
        if list.sections.isEmpty {
            pickerHeight.constant = 0
            addItemToSectionLabel.text = nil
        }
        
        if let section = selectedSection {
            let sectionIndex = list.sections.index(of: section) ?? 0
            sectionPicker.selectRow(sectionIndex, inComponent: 0, animated: true)
        }
        
        nameTextField.becomeFirstResponder()
    }
    
    func createNewItem() {
        guard let list = self.list else { return }
        
        let newItem = Item()
        newItem.name = self.nameTextField.text ?? ""
        newItem.price = (self.costTextField.text ?? "").fromCurrencyToDouble()
        
        if self.selectedSection != nil {
            list.add(item: newItem, toSectionWithID: self.selectedSection?.id ?? 0)
        } else {
            list.add(item: newItem)
        }
    }
    
    func updateExistingItem() {
        item?.update { updatedItem in
            updatedItem.name = self.nameTextField.text ?? ""
            updatedItem.price = (self.costTextField.text ?? "").fromCurrencyToDouble()
            updatedItem.sectionID = selectedSection?.id ?? 0
        }
    }
    
    @objc func selectCostField() {
        costTextField.becomeFirstResponder()
    }

}

extension BudgetItemForm: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == nameTextField {
            costTextField.becomeFirstResponder()
        }
        
        return true
    }
    
}

extension BudgetItemForm: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let sections = list?.sections else { return 0 }
        return sections.count
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let sections = list?.sections else { return "" }
        return sections[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let sections = list?.sections else { return }
        self.selectedSection = sections[row]
    }
}
