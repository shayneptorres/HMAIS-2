//
//  Protocol.swift
//  HMAIS
//
//  Created by Shayne Torres on 1/29/18.
//  Copyright © 2018 sptorres. All rights reserved.
//

import Foundation

protocol ListItemTypable {
    var listItemType: ListItemType { get }
}

extension ListItemTypable where Self: ItemList {
    var listItemType: ListItemType {
        return ListItemType(rawValue: self.type) ?? .shopping
    }
}

protocol Totalable {
    var total: Double { get }
}

extension Totalable where Self: Item {
    var total: Double {
        return price + (price*tax)
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
            return "Total: \(total)"
        }
    }
}

import UIKit

typealias TableViewCellConfig = (nibName: String, cellID: CellIds)

protocol TableViewManager {
}

extension TableViewManager where Self: UITableViewDelegate & UITableViewDataSource {
    
    func configure(with table: UITableView, andWith configs: [TableViewCellConfig] = [], autoDimension: Bool = true) {
        table.delegate = self
        table.dataSource = self
        
        table.estimatedRowHeight = 200
        
        if autoDimension {
            table.rowHeight = UITableViewAutomaticDimension
        }
        
        var nib: UINib? = nil
        
        configs.forEach { config in
            nib = UINib(nibName: config.nibName, bundle: nil)
            table.register(nib, forCellReuseIdentifier: config.cellID.rawValue)
        }
    }
    
}
