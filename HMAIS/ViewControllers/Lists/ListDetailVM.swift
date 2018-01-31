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
    func viewDidLoad()
}

protocol ListDetailVMOutputs {
    var reloadTable: PublishSubject<[Item]> { get }
    var reloadInfo: PublishSubject<ItemList?> { get }
    var changeDisplay: PublishSubject<CollectionDisplayType> { get }
}

protocol ListDetailVMType: ListDetailVMInputs, ListDetailVMOutputs {
    var inputs: ListDetailVMInputs { get }
    var outputs: ListDetailVMOutputs { get }
}

class ListDetailVM: ListDetailVMType {
    
    var reloadTable = PublishSubject<[Item]>()
    var reloadInfo = PublishSubject<ItemList?>()
    var changeDisplay = PublishSubject<CollectionDisplayType>()
    var inputs: ListDetailVMInputs { return self }
    var outputs: ListDetailVMOutputs { return self }
    var list: ItemList?
    
    init() {
    }
    
    func viewDidLoad() {
        reloadInfo.onNext(list)
        reloadTable.onNext(list?.items.toArray() ?? [])
    }
    
}
