//
//  ListSection.swift
//  HMAIS
//
//  Created by Shayne Torres on 2/17/18.
//  Copyright © 2018 sptorres. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class ListSection: Object, RealmManagable {
    typealias RealmObject = ListSection
    
    @objc dynamic var id = Int()
    @objc dynamic var name = String()
    @objc dynamic var updatedAt = Date()
    @objc dynamic var createdAt = Date()
    @objc dynamic var listID = Int()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func getItems() -> [Item] {
        guard let list = ItemList.getOne(withId: "\(listID)") else { return [] }
        return list.items.filter({ item in item.sectionID == self.id }).sorted(by: { i1, i2 in i1.createdAt > i2.createdAt })
    }
    
    func addItem(_ item: Item) {
        guard var list = ItemList.getOne(withId: "\(listID)") else { return }
        var newItem = item
        list.add(item: newItem, toSectionWithID: self.id)
    }
}
