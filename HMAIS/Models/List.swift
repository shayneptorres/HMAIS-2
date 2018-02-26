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
    @objc dynamic var groupID = 0
    var items = List<Item>()
    var sections = List<ListSection>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func add(item: Item){
        var newItem = item
        newItem.autoincrementID()
        newItem.save()
        let realm = try! Realm()
        try! realm.write {
            self.items.append(newItem)
            self.updatedAt = Date()
        }
    }
    
    func addSection(section: ListSection) {
        var newSection = section
        newSection.listID = self.id
        newSection.autoincrementID()
        newSection.save()
        
        let realm = try! Realm()
        
        if self.sections.isEmpty {
            self.items.forEach({ item in
                var updatableItem = item
                updatableItem.update(completion: { updatedItem in
                    updatedItem.sectionID = newSection.id
                })
            })
        }
        
        try! realm.write {
            self.sections.append(newSection)
            self.updatedAt = Date()
        }
        
        
    }
    
    func totalDelete() {
        self.items.forEach({
            $0.delete()
        })
        
        self.sections.forEach({
            $0.delete()
        })
        
        self.delete()
    }
    
    func add(item: Item, toSectionWithID id: Int) {
        var newItem = item
        newItem.sectionID = id
        newItem.autoincrementID()
        newItem.save()
        let realm = try! Realm()
        try! realm.write {
            self.items.append(newItem)
            self.updatedAt = Date()
        }
    }
}
