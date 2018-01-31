//
//  ListCell.swift
//  HMAIS
//
//  Created by Shayne Torres on 1/29/18.
//  Copyright © 2018 sptorres. All rights reserved.
//

import UIKit

class ListCell: UITableViewCell {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var count: UILabel!
    
    func configure(with itemList: ItemList?) {
        guard let list = itemList else { return }
        name.text = list.name
        count.text = "\(list.items.count) items"
    }
    
}
