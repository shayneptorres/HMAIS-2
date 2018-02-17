//
//  ListDetailVM.swift
//  HMAIS
//
//  Created by Shayne Torres on 1/30/18.
//  Copyright © 2018 sptorres. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol ListDetailVMInputs {
    func viewDidLoad(list: ItemList?)
    func itemWasAdded(toList list: ItemList)
    func listWasConverted(id: Int)
    func reloadList(id: Int)
}

protocol ListDetailVMOutputs {
    var reloadTable: PublishSubject<[Item]> { get }
    var addItemReload: PublishSubject<[Item]> { get }
}

protocol ListDetailVMType: ListDetailVMInputs, ListDetailVMOutputs {
    var inputs: ListDetailVMInputs { get }
    var outputs: ListDetailVMOutputs { get }
}

class ListDetailVM: ListDetailVMType {
    
    var reloadTable = PublishSubject<[Item]>()
    var addItemReload =  PublishSubject<[Item]>()
    var changeDisplay = PublishSubject<CollectionDisplayType>()
    var inputs: ListDetailVMInputs { return self }
    var outputs: ListDetailVMOutputs { return self }
    
    init() {
    }
    
    private func fetchList(withID id: Int) -> ItemList? {
        return ItemList.getOne(withId: "\(id)")
    }
    
    private func fetchItems(withID id: Int) -> [Item] {
        let list = ItemList.getOne(withId: "\(id)")
        return list?.items.toArray().sorted(by: { i1, i2 in i1.createdAt > i2.createdAt }) ?? []
    }
    
    func viewDidLoad(list: ItemList?) {
        reloadTable.onNext(list?.items.toArray() ?? [])
    }
    
    func reloadList(id: Int) {
        let items = fetchItems(withID: id)
        reloadTable.onNext(items)
    }
    
    func itemWasAdded(toList list: ItemList) {
        let items = fetchItems(withID: list.id)
        addItemReload.onNext(items)
    }
    
    func listWasConverted(id: Int) {
        let items = fetchItems(withID: id)
        reloadTable.onNext(items)
    }
    
}
