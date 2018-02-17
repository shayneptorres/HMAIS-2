//
//  ItemForm.swift
//  HMAIS
//
//  Created by Shayne Torres on 1/30/18.
//  Copyright © 2018 sptorres. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SpendingItemFormVC: UIViewController, TableViewManager {
    
    let trash = DisposeBag()
    var item: Item?
    var listID: Int?
    
    var cost : Double = 0.0
    var name = String()
    var quantity : Double = 1
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            let cellConfigs: [TableViewCellConfig] = [
                (nibName: "SpendingCostCell", cellID: CellID.spendingCostCell),
                (nibName: "FormEntryCell", cellID: CellID.formEntryCell)
            ]
            
//            configure(with: tableView, andWith: cellConfigs, autoDimension: true)
            
            tableView.separatorStyle = .none
            tableView.backgroundColor = #colorLiteral(red: 0.9371530414, green: 0.9373135567, blue: 0.9371429086, alpha: 1)
        }
    }
    
    @IBOutlet weak var submitBtn: UIButton! {
        didSet {
            submitBtn.rx
                        .tap
                        .bind(onNext:{ [weak self] in
                            guard let s = self else { return }
                            s.submit()
                        }).disposed(by: trash)
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
        
        let tapGesture = UITapGestureRecognizer()
        self.view.addGestureRecognizer(tapGesture)
        
        if let item = item {
            submitBtn.setTitle("Update item", for: .normal)
            self.name = item.name
            self.cost = item.price
            self.quantity = item.quantity
        } else {
            submitBtn.setTitle("Add item", for: .normal)
        }
        
        tapGesture.rx.event.bind(onNext: { [weak self] _ in
            self?.view.endEditing(true)
        }).disposed(by: trash)
    }
    
}

extension SpendingItemFormVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        switch indexPath.row {
        case 0: // Cost cell
            guard let costCell = tableView.dequeueReusableCell(withIdentifier: CellID.spendingCostCell.rawValue) as? SpendingCostCell else {
                return cell
            }
            costCell.costTF.becomeFirstResponder()
            observe(textField: costCell.costTF, entryType: .price)
            cell = costCell
        case 1: // Name cell
            guard let nameCell = tableView.dequeueReusableCell(withIdentifier: CellID.formEntryCell.rawValue) as? FormEntryCell else {
                return cell
            }
            nameCell.configure(withName: "Item name:", value: "")
            observe(textField: nameCell.textField, entryType: .name)
            cell = nameCell
        case 2: // Quantity cell
            guard let quantityCell = tableView.dequeueReusableCell(withIdentifier: CellID.formEntryCell.rawValue) as? FormEntryCell else {
                return cell
            }
            quantityCell.configure(withName: "Quantity:", value: "")
            observe(textField: quantityCell.textField, entryType: .quantity)
            quantityCell.textField.keyboardType = .numberPad
            cell = quantityCell
        default:
            return cell
        }
    
        return cell
    }
}

extension SpendingItemFormVC {
    
    func submit() {
        if self.name == "" {
            // If there was no name given, give a default
            self.name = "Unnamed"
        }
        
        if item?.id == -1 {
            guard
                var item = item,
                var list = ItemList.getOne(withId: "\(listID ?? -1)")
            else { return }
            // If the id is -1 then it is a new item
            // Save it
            item.autoincrementID()
            item.name = name
            item.price = cost
            item.quantity = quantity
            list.add(item: item)
        } else {
            // else the item is already existing
            // update it
            item?.update { updatedItem in
                updatedItem.name = name
                updatedItem.price = cost
                updatedItem.quantity = quantity
            }
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    private enum SpendingItemFormEntryType {
        case name
        case quantity
        case price
    }
    
    private func observe(textField tf: UITextField, entryType: SpendingItemFormEntryType) {
        tf.rx
            .text
            .bind(onNext: { [weak self] text in
                guard let s = self, let text = text else { return }
                s.valueWasChanged(value: text, entryType: entryType)
            })
            .disposed(by: trash)
    }
    
    private func valueWasChanged(value: String, entryType: SpendingItemFormEntryType) {
        if item == nil {
            item = Item()
            item?.id = -1
        }
        
        switch entryType {
        case .name:
            self.name = value
        case .quantity:
            self.quantity = Double(value) ?? 1
        case .price:
            self.cost = Double(value.fromCurrencyToDouble()) ?? 0.0
        }
    }
    
    
}
