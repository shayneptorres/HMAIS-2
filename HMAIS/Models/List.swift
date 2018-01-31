//
//  List.swift
//  HMAIS
//
//  Created by Shayne Torres on 1/29/18.
//  Copyright © 2018 sptorres. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class ItemList : Object, RealmManagable, ListItemTypable, Totalable, Summarizable {
    typealias RealmObject = ItemList
    
    @objc dynamic var id = Int()
    @objc dynamic var name = String()
    @objc dynamic var desc = String()
    @objc dynamic var updatedAt = Date()
    @objc dynamic var createdAt = Date()
    @objc dynamic var type = 1
    var items = List<Item>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
}
