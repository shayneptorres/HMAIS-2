
//
//  DashboardVM.swift
//  HMAIS
//
//  Created by Shayne Torres on 3/4/18.
//  Copyright © 2018 sptorres. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol DashboardVMInputs {
    func viewDidLoad()
}

typealias DashboardListPacket = (recent: [ItemList], favorite: [ItemList])

protocol DashboardVMOutputs {
    var reloadTable: PublishSubject<DashboardListPacket> { get }
}

protocol DashboardVMType: DashboardVMInputs, DashboardVMOutputs {
    var inputs: DashboardVMInputs { get }
    var outputs: DashboardVMOutputs { get }
}

class DashboardVM: DashboardVMType {
    
    let trash = DisposeBag()
    var inputs: DashboardVMInputs { return self }
    var outputs: DashboardVMOutputs { return self }
    var reloadTable = PublishSubject<DashboardListPacket>()
    
    func viewDidLoad() {
        let recents = getRecentlyUsedLists()
        let favorites = getFavoriteLists()
        reloadTable.onNext((recent: recents, favorite: favorites))
    }
    
    func getRecentlyUsedLists() -> [ItemList] {
        return ItemList.getRecentlyUsed()
    }
    
    func getFavoriteLists() -> [ItemList] {
        return ItemList.getFavoriteLists()
    }
    
}
