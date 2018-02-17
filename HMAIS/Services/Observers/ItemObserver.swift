//
//  ItemObserver.swift
//  HMAIS
//
//  Created by Shayne Torres on 2/3/18.
//  Copyright © 2018 sptorres. All rights reserved.
//

import Foundation
import RealmSwift
import Realm
import RxSwift
import RxRealm

protocol ItemObserverDelegate {
    func itemWasUpdated()
}

class ItemObserver {
    
    let trash = DisposeBag()
    var delegate: ItemObserverDelegate?
    
    init() {
        let realm = try! Realm()
        let items = realm.objects(Item.self)
        
        Observable.collection(from: items)
            .subscribe(onNext: { [weak self] p in
                guard let s = self, let delegate = s.delegate else { return }
                DispatchQueue.main.async {
                    delegate.itemWasUpdated()
                }

            }).disposed(by: trash)
    }
    
}
