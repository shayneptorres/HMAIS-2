//
//  BudgetListTableViewDelegate.swift
//  HMAIS
//
//  Created by Shayne Torres on 2/17/18.
//  Copyright © 2018 sptorres. All rights reserved.
//

import Foundation
import UIKit

class BudgetListTableViewDelegate: ListTableViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    override func registerTableViewCells(forTableView tableView: UITableView) {
        super.registerTableViewCells(forTableView: tableView)
        
        var nib = UINib(nibName: "BudgetListSummaryCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: CellID.budgetListSummaryCell.rawValue)
        
        nib = UINib(nibName: "BudgetItemCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: CellID.budgetItemCell.rawValue)
        
        nib = UINib(nibName: "BudgetListSectionHeader", bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: CellID.budgetSectionHeader.rawValue)
        
    }
    
    var rowSelectionCompletion: ((_ item: Item) -> ())?
    var list: ItemList?
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // if the list has sections, return the section count, else return 2 section
        // +1 to account for the summary section
        return sections.isEmpty ? 2 : sections.count + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // if the list has sections, return the count of items for the specified section,
        // else just return the number of items
        
        if section == 0 {
            return 1
        }
        
        if sections.isEmpty {
            return (data.isEmpty) ? 1 : data.count
        }
        
        return sections[section - 1].getItems().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        if indexPath.section == 0 {
            let summaryCell = tableView.dequeueReusableCell(withIdentifier: CellID.budgetListSummaryCell.rawValue) as! BudgetListSummaryCell
            summaryCell.configure(withList: list)
            return summaryCell
        }
        
        if sections.isEmpty {
            // if there aren't any sections, handle the budget item cells
            if data.isEmpty {
                let emptyCell = tableView.dequeueReusableCell(withIdentifier: CellID.emptyCell.rawValue) as! EmptyTableCell
                emptyCell.selectionStyle = .none
                emptyCell.configure(withMessage: EmptyCellMessage.item.message)
                cell = emptyCell
            } else {
                // else return the budget item cell for the item at the specified index path
                let budgetCell = tableView.dequeueReusableCell(withIdentifier: CellID.budgetItemCell.rawValue) as! BudgetItemCell
                budgetCell.configure(withItem: data[indexPath.row])
                cell = budgetCell
            }
        } else {
            // else return the budget item cell for the item at the specified index path
            
            let budgetCell = tableView.dequeueReusableCell(withIdentifier: CellID.budgetItemCell.rawValue) as! BudgetItemCell
            let item = sections[indexPath.section - 1].getItems()[indexPath.row]
            budgetCell.configure(withItem: item)
            cell = budgetCell
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if data.isEmpty && sections.isEmpty { return }
        let item = sections.isEmpty ? data[indexPath.row] : sections[indexPath.section].getItems()[indexPath.row]
        rowSelectionCompletion?(item)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0.001
        }
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard !sections.isEmpty, section != 0 else { return nil }
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: CellID.budgetSectionHeader.rawValue) as! BudgetListSectionHeader
        let section = sections[section - 1]
        header.configure(withSection: section) {
            self.sectionAddBtnCompletion?(section)
        }
        
//        if tableView.isEditing {
//            // if table is editing, completion will delete the section an all its items
//            header.btnStyle = .delete
//            header.configure(withName: sections[section].name) {
//                self.handleDeleteSection(section: self.sections[section])
//            }
//
//        } else {
//            // if the table is not editing, the completion will add an item to the section
//            header.btnStyle = .add
//            header.configure(withName: sections[section].name) {
//                self.sectionAddBtnCompletion?(self.sections[section])
//            }
//        }
        
        return header
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        var item = Item()
        
        if sections.isEmpty {
            item = self.data[indexPath.row]
        } else {
            item = self.sections[indexPath.section - 1].getItems()[indexPath.row]
        }
        
        return [
            UITableViewRowAction.init(style: .destructive, title: "Delete", handler: { _, _ in
                item.delete()
                tableView.deleteRows(at: [indexPath], with: .automatic)
                Timer.after(0.3) {
                    //
                    self.viewController?.reloadTable(animated: false)
                }
            })
        ]
    }
    
}
