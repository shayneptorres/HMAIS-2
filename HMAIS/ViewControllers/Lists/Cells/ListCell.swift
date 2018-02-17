//
//  ListCell.swift
//  HMAIS
//
//  Created by Shayne Torres on 2/17/18.
//  Copyright © 2018 sptorres. All rights reserved.
//

import UIKit

class ListCell: UITableViewCell {
    
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var indicatorTab: UIView!
    @IBOutlet weak var indicatorImageView: UIImageView!
    @IBOutlet weak var listNameLabel: UILabel!
    
    func configure(withList list: ItemList) {
        indicatorTab.backgroundColor = list.listItemType.indicatorColor
        indicatorImageView.image = list.listItemType.indicatorImage
        listNameLabel.text = list.name
        container.layer.cornerRadius = 8
        container.applyShadow(.normal(.bottom))
        self.selectionStyle = .none
    }
    
    
}
