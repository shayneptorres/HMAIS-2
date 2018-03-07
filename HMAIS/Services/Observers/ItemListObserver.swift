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
    func listsWereUpdated()
}

class ListObserver {
    
    static let instance = ListObserver()
    
    let trash = DisposeBag()
    var delegates: [ListObserverDelegate] = []
    
    init() {
        let realm = try! Realm()
        let lists = realm.objects(ItemList.self)
        
        Observable.collection(from: lists)
            .subscribe(onNext: { [weak self] item in
                guard let s = self else { return }
                DispatchQueue.main.async {
                    s.delegates.forEach({ delegate in
                        delegate.listsWereUpdated()
                    })
                }
            }).disposed(by: trash)
    }
    
    func addDelegate(observer: ListObserverDelegate) {
        if delegates.contains(where: { type(of: $0) == type(of: observer) }) {
            // prevent duplicates
            guard let index = delegates.index(where: { delegate in
                type(of: delegate) == type(of: observer)
            })
            else { return }
            
            delegates[index] = observer
            
        } else {
            delegates.append(observer)
        }
    }
    
}
