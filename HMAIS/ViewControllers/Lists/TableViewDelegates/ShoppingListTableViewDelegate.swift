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
    
    override func configure(withTable table: UITableView, data: [Item], animated: Bool, reloadComp: (() -> ())? = nil, infoBtnComp: ((_ item: Item) -> ())? = nil) {
        self.tableView = table
        self.data = data
        self.reloadCompletion = reloadComp
        self.infoButtonCompletion = infoBtnComp
        if animated {
            self.tableView.reloadSections([0], with: .automatic)
        } else {
            self.tableView.reloadData()
        }
    }
    
    override func registerTableViewCells(forTableView tableView: UITableView) {
        super.registerTableViewCells(forTableView: tableView)
        
        let nib = UINib(nibName: "ShoppingItemCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: CellID.shoppingItemCell.rawValue)
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (data.isEmpty) ? 1 : data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        if data.isEmpty { // is empty, show empty cell
            let emptyCell = tableView.dequeueReusableCell(withIdentifier: CellID.emptyCell.rawValue) as! EmptyTableCell
            emptyCell.configure(withMessage: EmptyCellMessage.item.message)
            cell = emptyCell
        } else {
            let itemCell = tableView.dequeueReusableCell(withIdentifier: CellID.shoppingItemCell.rawValue) as! ShoppingItemCell
            itemCell.configure(withItem: data[indexPath.row]) {
                print("Show info")
                self.infoButtonCompletion?(self.data[indexPath.row])
            }
            cell = itemCell
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !data.isEmpty else { return }
        var item = data[indexPath.row]
        item.update { updateItem in
            updateItem.completed = !updateItem.completed
        }
        reloadCompletion?()
    }
}
