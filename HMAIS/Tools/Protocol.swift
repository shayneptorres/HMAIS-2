//
//  Protocol.swift
//  HMAIS
//
//  Created by Shayne Torres on 1/29/18.
//  Copyright © 2018 sptorres. All rights reserved.
//

import Foundation

protocol Identifiable {
}

extension Identifiable {
    static var id: String {
        return String.init(describing: Self.self)
    }
}

protocol ListItemTypable {
    var listItemType: ListItemType { get }
}

extension ListItemTypable where Self: ItemList {
    var listItemType: ListItemType {
        return ListItemType(rawValue: self.type) ?? .shopping
    }
}

protocol Budgetable {
}

extension Budgetable where Self: ItemList {
    var remainingAmount: Double {
        return self.items.reduce(self.budget, { result, item in
            result - item.price
        })
    }
    
    var spendAmount: Double {
        return self.items.reduce(0, { result, item in
            result + item.price
        })
    }
}

protocol Totalable {
    var total: Double { get }
}

extension Totalable where Self: Item {
    var total: Double {
        return price
    }
}

extension Totalable where Self: ItemList {
    var total: Double {
        let itemsTotal = items.reduce(0.0, { result,item in
            return result + item.total
        })
        
        return itemsTotal
    }
}

protocol Summarizable {}

extension Summarizable where Self: ItemList {
    var summary: String {
        if self.listItemType == .shopping {
            let completed = items.filter({ item in
                item.completed == true
            })
            return "\(completed.count) out of \(items.count) completed"
        } else {
            var totalCurrency = "\(total)".toCurrency()
            return "Total: \(totalCurrency)"
        }
    }
}

import UIKit

typealias TableViewCellConfig = (nibName: String, cellID: CellID)

struct CellConfig {
    var nibName: String
    var cellID: CellID
    var isHeaderFooter: Bool
    
    init(nibName: String, cellID: CellID, isHeaderFooter: Bool = false) {
        self.nibName = nibName
        self.cellID = cellID
        self.isHeaderFooter = isHeaderFooter
    }
}

protocol TableViewManager {
}

extension TableViewManager where Self: UITableViewDelegate & UITableViewDataSource {
    
    func configure(with table: UITableView, andWith configs: [CellConfig] = [], autoDimension: Bool = true) {
        table.delegate = self
        table.dataSource = self
        
        table.estimatedRowHeight = 200
        
        if autoDimension {
            table.rowHeight = UITableViewAutomaticDimension
        }
        
        var nib: UINib? = nil
        
        configs.forEach { config in
            nib = UINib(nibName: config.nibName, bundle: nil)
            if config.isHeaderFooter {
                table.register(nib, forHeaderFooterViewReuseIdentifier: config.cellID.rawValue)
            } else {
                table.register(nib, forCellReuseIdentifier: config.cellID.rawValue)
            }
        }
    }
    
}

@objc protocol KeyboardObserver {
    @objc func keyboardWillShow(_ notification: Notification)
    @objc func keyboardWillHide(_ notification: Notification)
}

extension KeyboardObserver where Self: UIViewController {
    
    func observeKeyboard() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: NSNotification.Name.UIKeyboardWillShow,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: NSNotification.Name.UIKeyboardWillHide,
            object: nil
        )
    }
}

protocol MiniFormDelegate {
    func miniFormDidSubmit(text: String)
}



protocol ModalPresentable {}

extension ModalPresentable where Self: UIViewController {
    
    func presentModal(modalType: ModalFormType, completion: (_ viewController: UIViewController) -> ()) {
        
        let mainSB = UIStoryboard(name: "Main", bundle: nil)
        
        guard
            let modal = mainSB.instantiateViewController(withIdentifier: "ModalForm") as? ModalFormNav,
            let nav = self.navigationController,
            let tab = nav.parent as? UITabBarController
        else { return }
        
        var viewController: UIViewController
        
        switch modalType {
        case .addSection(let list):
            let addSection = modalType.sourceViewController as! AddSectionFormVC
            addSection.list = list
            viewController = addSection
        case .addItemToSection(let list, let section):
            let addItem = modalType.sourceViewController as! AddItemToSectionVC
            addItem.list = list
            addItem.listSection = section
            viewController = addItem
        case .editItem(let item):
            let shoppingItemForm = modalType.sourceViewController as! ShoppingItemFormVC
            shoppingItemForm.editingItem = item
            viewController = shoppingItemForm
        case .addBudgetItem(let list, let section, _):
            let budgetItemForm = modalType.sourceViewController as! BudgetItemForm
            budgetItemForm.list = list
            budgetItemForm.selectedSection = section
            viewController = budgetItemForm
        case .setBudet(let list):
            let setBudget = modalType.sourceViewController as! BudgetListBudgetFormVC
            setBudget.list = list
            viewController = setBudget
        }
        
        modal.modalTransitionStyle = .crossDissolve
        modal.formType = modalType
        completion(viewController)
        modal.present(viewController, from: tab, animated: true)
    }
}

