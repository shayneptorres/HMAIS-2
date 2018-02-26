//
//  ShoppingListTableViewDelegate.swift
//  HMAIS
//
//  Created by Shayne Torres on 2/17/18.
//  Copyright © 2018 sptorres. All rights reserved.
//

import Foundation
import UIKit

class ShoppingListTableViewDelegate: ListTableViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var infoButtonCompletion: ((_ item: Item) -> ())?
    var sections: [ListSection] = []
    
    override func configure(withTable table: UITableView, data: [Item] = [], sections: [ListSection] = [], animated: Bool, reloadComp: (() -> ())? = nil, infoBtnComp: ((_ item: Item) -> ())? = nil) {
        self.tableView = table
        self.data = data
        self.sections = sections
        self.reloadCompletion = reloadComp
        self.infoButtonCompletion = infoBtnComp
        if animated {
            reloadComp?()
        } else {
            self.tableView.reloadData()
        }
    }
    
    override func registerTableViewCells(forTableView tableView: UITableView) {
        super.registerTableViewCells(forTableView: tableView)
        
        var nib = UINib(nibName: "ShoppingItemCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: CellID.shoppingItemCell.rawValue)
        
        nib = UINib(nibName: "ListSectionHeader", bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: CellID.shoppingSectionHeader.rawValue)
        
    }
    
    func handleDeleteSection(section: ListSection) {
        let alert = UIAlertController(title: "\(section.name)", message: "Deleting this section will delete all of its items. Do you wish to do this?", preferredStyle: .actionSheet)

        let deleteAction = UIAlertAction(title: "Yes", style: .destructive) { _ in
            section.totalDelete()
            self.viewController?.viewModel.inputs.reloadList(withListID: self.viewController?.list?.id ?? 0)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        self.viewController?.present(alert, animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if sections.isEmpty { return 1 } // if there are no sections show only the items
        
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if sections.isEmpty {
            return (data.isEmpty) ? 1 : data.count
        }
        
        return sections[section].getItems().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        if sections.isEmpty && data.isEmpty { // is empty, show empty cell
            let emptyCell = tableView.dequeueReusableCell(withIdentifier: CellID.emptyCell.rawValue) as! EmptyTableCell
            emptyCell.configure(withMessage: EmptyCellMessage.item.message)
            emptyCell.selectionStyle = .none
            cell = emptyCell
        } else {
            
            let itemCell = tableView.dequeueReusableCell(withIdentifier: CellID.shoppingItemCell.rawValue) as! ShoppingItemCell
            var displayedItem: Item
            
            if sections.isEmpty { // If there are no sections, show all items
                displayedItem = data[indexPath.row]
            } else {
                displayedItem = sections[indexPath.section].getItems()[indexPath.row]
            }
            
            itemCell.configure(withItem: displayedItem) {
                self.infoButtonCompletion?(displayedItem)
            }
            
            cell = itemCell
        }
        
        let v = UIView(frame: CGRect.init(x: 0, y: 0, width: 30, height: 30))
        v.backgroundColor = .red
        
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard !sections.isEmpty else { return nil }
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: CellID.shoppingSectionHeader.rawValue) as! ListSectionHeader
        
        if tableView.isEditing {
            // if table is editing, completion will delete the section an all its items
            header.btnStyle = .delete
            header.configure(withName: sections[section].name) {
                self.handleDeleteSection(section: self.sections[section])
            }
            
        } else {
            // if the table is not editing, the completion will add an item to the section
            header.btnStyle = .add
            header.configure(withName: sections[section].name) {
                self.sectionAddBtnCompletion?(self.sections[section])
            }
        }
        
        
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard !sections.isEmpty else { return 0.001 }
        
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 4
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.9371530414, green: 0.9373135567, blue: 0.9371429086, alpha: 1)
        return view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var item: Item
        
        if !sections.isEmpty {
            item = sections[indexPath.section].getItems()[indexPath.row]
        } else {
            guard !data.isEmpty else { return }
            item = data[indexPath.row]
        }
        
        item.update { updateItem in
            updateItem.completed = !updateItem.completed
        }
        
        reloadCompletion?()
        
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return data.isEmpty
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let item = self.sections[indexPath.section].getItems()[indexPath.row]
        return [
            UITableViewRowAction.init(style: .destructive, title: "Delete", handler: { _, _ in
                item.delete()
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }),
            UITableViewRowAction.init(style: .normal, title: "Edit", handler: { _, I in
                if let listDetailVC = self.viewController {
                    listDetailVC.displayEditItemModal(forItem: item)
                }
            })
        ]
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if sections.isEmpty {
            
        } else {
            var item = sections[sourceIndexPath.section].getItems().sorted(by: {i1, i2 in i1.createdAt > i2.createdAt })[sourceIndexPath.row]
            let sectionID = sections[destinationIndexPath.section].id
            item.update(completion: { updatedItem in
                updatedItem.sectionID = sectionID
            })
        }
        
    }
}
