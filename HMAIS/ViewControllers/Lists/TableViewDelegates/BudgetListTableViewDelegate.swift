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
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            summaryCell.configure(withList: list) {
                generator.notificationOccurred(.success)
                self.viewController?.showEditBudgetVC()
            }
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
                budgetCell.configure(withItem: data[indexPath.row]) {
                    self.viewController?.showBudgetItemForm(forItem: self.data[indexPath.row], inSection: nil)
                }
                cell = budgetCell
            }
        } else {
            // else return the budget item cell for the item at the specified index path
            let budgetCell = tableView.dequeueReusableCell(withIdentifier: CellID.budgetItemCell.rawValue) as! BudgetItemCell
            let item = sections[indexPath.section - 1].getItems()[indexPath.row]
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            budgetCell.configure(withItem: item) {
                generator.notificationOccurred(.success)
                self.viewController?.showBudgetItemForm(forItem: item, inSection: self.sections[indexPath.section - 1])
            }
            cell = budgetCell
        }
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if data.isEmpty && sections.isEmpty { return }
        
        let item = sections.isEmpty ? data[indexPath.row] : sections[indexPath.section - 1].getItems()[indexPath.row]
        
        if sections.isEmpty {
            viewController?.showBudgetItemForm(forItem: item, inSection: nil)
        } else {
            viewController?.showBudgetItemForm(forItem: item, inSection: sections[indexPath.section - 1])
        }   
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 || sections.isEmpty {
            return 0.001
        }
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.9371530414, green: 0.9373135567, blue: 0.9371429086, alpha: 1)
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 4
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        guard indexPath.section != 0 else { return false } // do no edit summary cell
        
        if data.isEmpty && sections.isEmpty { return false } // do not edit empty cell
        
        return true
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard !sections.isEmpty, section != 0 else { return nil }
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: CellID.budgetSectionHeader.rawValue) as! BudgetListSectionHeader
        let chosenSection = sections[section - 1]
        header.configure(withSection: chosenSection) {
            self.sectionAddBtnCompletion?(chosenSection)
        }
        if tableView.isEditing {
            // if table is editing, completion will delete the section an all its items
            header.btnStyle = .delete
            header.configure(withSection: chosenSection) {
                self.handleDeleteSection(section: chosenSection)
            }
        } else {
            // if the table is not editing, the completion will add an item to the section
            header.btnStyle = .add
            header.configure(withSection: chosenSection) {
                self.sectionAddBtnCompletion?(chosenSection)
            }
        }
        return header
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
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

                if !self.sections.isEmpty {
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                    Timer.after(0.3) {
                        self.viewController?.signalVMReloadTable()
                    }
                } else {
                    self.viewController?.signalVMReloadTable()
                }
            })
        ]
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if sections.isEmpty {
            
        } else {
            var item = sections[sourceIndexPath.section - 1].getItems().sorted(by: {i1, i2 in i1.createdAt > i2.createdAt })[sourceIndexPath.row]
            let sectionID = sections[destinationIndexPath.section - 1].id
            item.update(completion: { updatedItem in
                updatedItem.sectionID = sectionID
            })
        }
    }
    
}
