//
//  ItemListObserver.swift
//  HMAIS
//
//  Created by Shayne Torres on 1/30/18.
//  Copyright © 2018 sptorres. All rights reserved.
//

import Foundation
import RealmSwift
import Realm
import RxSwift
import RxRealm

protocol ListObserverDelegate {
    func listWasUpdated()
}

class ListObserver {
    
    let trash = DisposeBag()
    var delegate: ListObserverDelegate?
    
    init() {
        let realm = try! Realm()
        let lists = realm.objects(ItemList.self)
        
        Observable.collection(from: lists)
            .subscribe(onNext: { [weak self] item in
                guard let s = self, let delegate = s.delegate else { return }
                DispatchQueue.main.async {
                    delegate.listWasUpdated()
                }
            }).disposed(by: trash)
    }
    
}
