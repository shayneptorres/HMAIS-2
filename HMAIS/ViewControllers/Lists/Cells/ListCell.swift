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
        print(list.favorite)
        var name = list.favorite ? list.name : "\(list.name) ⭐️"
        if list.favorite == false {
           name = list.name
        } else {
            name = "\(list.name) ⭐️"
        }
        
        listNameLabel.text = name
        container.layer.cornerRadius = 8
        container.applyShadow(.normal(.bottom))
        indicatorTab.roundCorners(corners: [.topLeft, .bottomLeft], radii: 8)
        self.selectionStyle = .none
    }
    
    
}
