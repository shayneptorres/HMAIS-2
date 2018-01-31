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

protocol ListsVMInputs {
    func viewDidLoad()
    func listWasUpdated()
    func beginEditing()
    func endEditing()
}

protocol ListsVMOutputs {
    var reloadTable: PublishSubject<[ItemList]> { get }
    var changeDisplay: PublishSubject<CollectionDisplayType> { get }
}

protocol ListVMType: ListsVMInputs, ListsVMOutputs {
    var inputs: ListsVMInputs { get }
    var outputs: ListsVMOutputs { get }
}

class ListsVM: ListVMType {
    
    var reloadTable = PublishSubject<[ItemList]>()
    var changeDisplay = PublishSubject<CollectionDisplayType>()
    var inputs: ListsVMInputs { return self }
    var outputs: ListsVMOutputs { return self }
    
    func viewDidLoad() {
        // fetch lists
        let lists = ItemList.getAll()
        DispatchQueue.main.async { [weak self] in
            guard let s = self else { return }
            s.reloadTable.onNext(lists)
        }
    }
    
    func listWasUpdated() {
        // fetch lists
        let lists = ItemList.getAll()
        DispatchQueue.main.async { [weak self] in
            guard let s = self else { return }
            s.reloadTable.onNext(lists)
        }
    }
    
    func beginEditing() {
        DispatchQueue.main.async { [weak self] in
            guard let s = self else { return }
            s.changeDisplay.onNext(.editing)
        }
    }
    
    func endEditing() {
        DispatchQueue.main.async { [weak self] in
            guard let s = self else { return }
            s.changeDisplay.onNext(.displaying)
        }
    }
}
