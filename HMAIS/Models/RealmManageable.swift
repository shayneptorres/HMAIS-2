//
//  RealmManageable.swift
//  HMAIS
//
//  Created by Shayne Torres on 1/28/18.
//  Copyright © 2018 sptorres. All rights reserved.
//

import RealmSwift
import Realm

protocol RealmManagable {
    
    var id : Int { get set }
    var createdAt : Date { get set }
    var updatedAt : Date { get set }
    
    associatedtype RealmObject
    
    //    func save()
    //    func update(completion: ()->())
    //    func getAll() -> [Object]?
    //    func getOne() -> Object?
    //    func getOne(withId id: Int) -> Object?
}

extension RealmManagable where Self : Object {
    
    mutating func autoincrementID(){
        let realm = try! Realm()
        realm.refresh()
        self.id = (realm.objects(RealmObject.self as! Object.Type).max(ofProperty: "id") as Int? ?? 0) + 1
    }
    
    mutating func save(){
        let realm = try! Realm()
        realm.refresh()
        try! realm.write {
            self.createdAt = Date()
            self.updatedAt = Date()
            realm.add(self)
        }
    }
    
    mutating func update(completion: (RealmObject) -> ()){
        let realm = try! Realm()
        realm.refresh()
        try! realm.write {
            completion(self as! RealmObject)
            self.updatedAt = Date()
            realm.add(self, update: true)
        }
    }
    
    func delete(){
        let realm = try! Realm()
        realm.refresh()
        try! realm.write {
            realm.delete(self)
        }
    }
    
    static func getAll() -> [RealmObject] {
        let realm = try! Realm()
        realm.refresh()
        return realm.objects(RealmObject.self as! Object.Type).map({ obj in (obj as? RealmObject)! })
    }
    
    static func getOne(withId id: String) -> RealmObject? {
        let realm = try! Realm()
        realm.refresh()
        return realm.objects(RealmObject.self as! Object.Type).filter("id == \(id)").first as? RealmObject
    }
    
    func getOne() -> Object? {
        return nil
    }
}

