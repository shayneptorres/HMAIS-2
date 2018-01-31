//
//  ListDetailVC.swift
//  HMAIS
//
//  Created by Shayne Torres on 1/30/18.
//  Copyright © 2018 sptorres. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ListDetailVC: UIViewController, TableViewManager {
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            let tableViewConfigs: [TableViewCellConfig] = [
                (nibName: "AddBtnCell", cellID: .addBtnCell)
            ]
            configure(with: tableView, andWith: tableViewConfigs)
            tableView.separatorStyle = .none
            tableView.backgroundColor = #colorLiteral(red: 0.6862745098, green: 0.6862745098, blue: 0.6862745098, alpha: 1)
        }
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var listTypeLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    
    
    let viewModel = ListDetailVM()
    let trash = DisposeBag()
    
    var items: [Item] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.outputs.reloadTable.subscribe(onNext: {[weak self] listItems in
            guard let s = self else { return }
            s.items = listItems
        }).disposed(by: trash)
        
        viewModel.outputs.reloadInfo.subscribe(onNext: {[weak self] list in
            guard let s = self, let l = list else { return }
            s.configureInfo(with: l)
        }).disposed(by: trash)
        
        viewModel.inputs.viewDidLoad()
    }
    
    func configureInfo(with list: ItemList) {
        nameLabel.text = list.name
        listTypeLabel.text = "(\(list.listItemType.description) list)"
        summaryLabel.text = list.summary
    }
}

extension ListDetailVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        if indexPath.row < self.items.count {
            // show the item cells
        } else if indexPath.row == self.items.count {
            // the cell being shown is the add list cell
            guard let addBtnCell = tableView.dequeueReusableCell(withIdentifier: CellIds.addBtnCell.rawValue) as? AddBtnCell
                else {
                    return cell
            }
            addBtnCell.configure(with: "Add item") { [weak self] in
                guard let s = self else { return }
            }
            cell = addBtnCell
        }
        return cell
    }
}
