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
        guard let list = getList() else { return [] }
        // return all the items sorted by completed or not
        return list.items.filter({ item in item.sectionID == self.id }).sorted(by: { i, _ in !i.completed })
    }
    
    func addItem(_ item: Item) {
        guard var list = getList() else { return }
        var newItem = item
        list.add(item: newItem, toSectionWithID: self.id)
    }
    
    func totalDelete() {
        let items = getItems()
        items.forEach({ $0.delete() })
        self.delete()
    }
    
    func getList() -> ItemList? {
        return ItemList.getOne(withId: "\(listID)")
    }
}
