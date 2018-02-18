//
//  Item.swift
//  HMAIS
//
//  Created by Shayne Torres on 1/29/18.
//  Copyright © 2018 sptorres. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class Item : Object, RealmManagable, Totalable {
    typealias RealmObject = Item
    
    @objc dynamic var id = Int()
    @objc dynamic var name = String()
    @objc dynamic var desc = String()
    @objc dynamic var updatedAt = Date()
    @objc dynamic var createdAt = Date()
    @objc dynamic var quantity: Double = 1
    @objc dynamic var price = Double()
    @objc dynamic var completed = Bool()
    @objc dynamic var sectionID = Int()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
}
