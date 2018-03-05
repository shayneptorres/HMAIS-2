//
//  DashboardVC.swift
//  HMAIS
//
//  Created by Shayne Torres on 3/4/18.
//  Copyright © 2018 sptorres. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class DashboardVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            
        }
    }
    
    let viewModel = DashboardVM()
    let trash = DisposeBag()
    
    var recents: [ItemList] = []
    var favorites: [ItemList] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel
            .outputs
            .reloadTable
            .bind(onNext: { (recentLists, favoriteLists) in
                self.recents = recentLists
                self.favorites = favoriteLists
                self.tableView.reloadData()
            })
            .disposed(by: trash)
        
        
    }

}

extension DashboardVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        return cell
    }
    
}
