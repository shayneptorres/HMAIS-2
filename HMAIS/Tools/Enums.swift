//
//  Enums.swift
//  HMAIS
//
//  Created by Shayne Torres on 1/29/18.
//  Copyright © 2018 sptorres. All rights reserved.
//

import Foundation

enum ListItemType: Int {
    case shopping = 1
    case spending
}

extension ListItemType {
    var description: String {
        switch self {
        case .shopping:
            return "Shopping"
        case .spending:
            return "Spending"
        }
    }
}

enum CellIds: String {
    case listCell = "listCell"
    case newListCell = "newListCell"
    case addBtnCell = "addBtnCell"
}

enum CollectionDisplayType {
    case displaying
    case editing
}
