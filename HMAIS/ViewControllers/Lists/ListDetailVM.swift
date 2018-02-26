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
    func reloadSection(section: Int, toListWithID id: Int)
    func reloadList(withListID: Int)
}

protocol ListDetailVMOutputs {
    var reloadTable: PublishSubject<[Item]> { get }
    var reloadTableWithSections: PublishSubject<[ListSection]> { get }
    var reloadSection: PublishSubject<(section: Int, data: [ListSection])> { get }
}

protocol ListDetailVMType: ListDetailVMInputs, ListDetailVMOutputs {
    var inputs: ListDetailVMInputs { get }
    var outputs: ListDetailVMOutputs { get }
}

class ListDetailVM: ListDetailVMType {
    
    var reloadTable = PublishSubject<[Item]>()
    var reloadTableWithSections = PublishSubject<[ListSection]>()
    var reloadSection = PublishSubject<(section: Int, data: [ListSection])>()

    var inputs: ListDetailVMInputs { return self }
    var outputs: ListDetailVMOutputs { return self }
    
    init() {
    }
    
    private func fetchList(withListID id: Int) -> ItemList? {
        return ItemList.getOne(withId: "\(id)")
    }
    
    private func fetchItems(withID id: Int) -> [Item] {
        let list = ItemList.getOne(withId: "\(id)")
        return list?.items.toArray().sorted(by: { i1, i2 in i1.createdAt > i2.createdAt }) ?? []
    }
    
    func viewDidLoad(list: ItemList?) {
        if (list?.sections.isEmpty) ?? false {
            reloadTable.onNext(list?.items.toArray() ?? [])
        } else {
            reloadTableWithSections.onNext(list?.sections.toArray() ?? [])
        }
    }
    
    func reloadList(withListID id: Int) {
        guard let list = ItemList.getOne(withId: "\(id)") else { return }
        
        if (list.sections.isEmpty) {
            reloadTable.onNext(list.items.toArray())
        } else {
            reloadTableWithSections.onNext(list.sections.toArray())
        }

    }
    
    func itemWasAdded(toList list: ItemList) {
        let items = fetchItems(withID: list.id)
        
        if (list.sections.isEmpty) {
            reloadTable.onNext(list.items.toArray())
        } else {
            reloadTableWithSections.onNext(list.sections.toArray())
        }
    }
    
    func reloadSection(section: Int, toListWithID id: Int) {
        guard let list = ItemList.getOne(withId: "\(id)") else { return }
        reloadSection.onNext((section: section, data: list.sections.toArray()))
    }
    
}
