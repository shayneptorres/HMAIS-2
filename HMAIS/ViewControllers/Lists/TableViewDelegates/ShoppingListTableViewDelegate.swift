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
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard !sections.isEmpty else { return nil }
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: CellID.shoppingSectionHeader.rawValue) as! ListSectionHeader
        header.configure(withName: sections[section].name) {
            self.sectionAddBtnCompletion?(self.sections[section])
        }
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard !sections.isEmpty else { return 0.001 }
        
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if sections.isEmpty || section == sections.count - 1 {
            return 55
        }
        
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
}
