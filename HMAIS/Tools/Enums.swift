//
//  Enums.swift
//  HMAIS
//
//  Created by Shayne Torres on 1/29/18.
//  Copyright © 2018 sptorres. All rights reserved.
//

import Foundation
import UIKit

enum ListItemType: Int {
    case new = 1
    case shopping
    case budget
}

extension ListItemType {
    var description: String {
        switch self {
        case .new:
            return "New"
        case .shopping:
            return "Shopping"
        case .budget:
            return "Budget"
        }
    }
    
    var indicatorImage: UIImage? {
        switch self {
        case .new:
            return #imageLiteral(resourceName: "new_icon.png")
        case .shopping:
            return #imageLiteral(resourceName: "white_check.png")
        case .budget:
            return #imageLiteral(resourceName: "$.png")
        }
    }
    
    var indicatorColor: UIColor {
        switch self {
        case .new:
            return #colorLiteral(red: 0.8745098039, green: 0.2156862745, blue: 0.9019607843, alpha: 1)
        case .shopping:
            return #colorLiteral(red: 0.4830000103, green: 0.8349999785, blue: 0, alpha: 1)
        case .budget:
            return #colorLiteral(red: 0.9679999948, green: 0.6549999714, blue: 0, alpha: 1)
        }
    }
}

enum CellID: String {
    // All
    case emptyCell = "emptyCell"
    // Lists
    case listCell = "listCell"
    // Forms
    case spendingCostCell = "spendingCostCell"
    case formEntryCell = "formEntryCell"
    // Items
    case shoppingItemCell = "shoppingItemCell"
    case shoppingSectionHeader = "shoppingSectionHeader"
    case budgetListSummaryCell = "budgetListSummaryCell"
    case budgetItemCell = "budgetItemCell"
    // Sections
    case budgetSectionHeader = "budgetListSectionHeader"
}

enum EmptyCellMessage {
    case list
    case item
}

extension EmptyCellMessage {
    var message: String {
        switch self {
        case .list:
            return "Looks like you haven't added a list yet. To add one, tap the buttom on the bottom"
        case .item:
            return "This list is empty. To add items tap the button on the bottom"
        }
    }
}

enum CollectionDisplayType {
    case displaying
    case editing
}

enum ShadowType {
    case light(ShadowDirection)
    case normal(ShadowDirection)
    case heavy(ShadowDirection)
}

enum ShadowDirection {
    case top
    case bottom
    case left
    case right
}
