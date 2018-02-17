//
//  ListTableViewDelegate.swift
//  HMAIS
//
//  Created by Shayne Torres on 2/17/18.
//  Copyright © 2018 sptorres. All rights reserved.
//

import Foundation
import UIKit

class ListTableViewDelegate: NSObject {
    
    var data: [Item] = []
    var tableView: UITableView! {
        didSet {
            tableView.delegate = self as! UITableViewDelegate
            tableView.dataSource = self as! UITableViewDataSource
        }
    }
    
    var reloadCompletion: (() -> ())?
    
    func configure(withTable table: UITableView, data: [Item], animated: Bool, reloadComp: (() -> ())? = nil, infoBtnComp: ((_ item: Item) -> ())? = nil) {
    }
    
    func registerTableViewCells(forTableView tableView: UITableView) {
        let nib = UINib(nibName: "EmptyTableCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: CellID.emptyCell.rawValue)
    }
}
