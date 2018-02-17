//
//  ListsVM.swift
//  HMAIS
//
//  Created by Shayne Torres on 1/29/18.
//  Copyright © 2018 sptorres. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import SwiftDate

protocol ListsVMInputs {
    func viewDidLoad()
    func listWasAdded()
}

protocol ListsVMOutputs {
    var reloadTable: PublishSubject<[ItemList]> { get }
    var addList: PublishSubject<[ItemList]> { get }
}

protocol ListVMType: ListsVMInputs, ListsVMOutputs {
    var inputs: ListsVMInputs { get }
    var outputs: ListsVMOutputs { get }
}

class ListsVM: ListVMType {
    
    var reloadTable = PublishSubject<[ItemList]>()
    var addList = PublishSubject<[ItemList]>()
    var inputs: ListsVMInputs { return self }
    var outputs: ListsVMOutputs { return self }
    
    func viewDidLoad() {
        // fetch lists
        let lists = fetchLists()
        DispatchQueue.main.async { [weak self] in
            guard let s = self else { return }
            s.reloadTable.onNext(lists)
        }
    }
    
    func listWasAdded() {
        let lists = fetchLists()
        DispatchQueue.main.async { [weak self] in
            guard let s = self else { return }
            s.addList.onNext(lists)
        }
    }
    func fetchLists() -> [ItemList] {
        return ItemList.getAll().sorted(by: { l1, l2 in l1.createdAt > l2.createdAt })
    }
}
