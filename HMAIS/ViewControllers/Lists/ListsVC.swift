//
//  ListsVC.swift
//  HMAIS
//
//  Created by Shayne Torres on 1/29/18.
//  Copyright © 2018 sptorres. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ListsVC: UIViewController, TableViewManager {
    
    @IBOutlet weak var table: UITableView! {
        didSet {
            let tableViewConfigs: [TableViewCellConfig] = [
                (nibName: "NewListCell", cellID: .newListCell),
                (nibName: "ListCell", cellID: .listCell),
                (nibName: "AddBtnCell", cellID: .addBtnCell)
            ]
            
            configure(with: table, andWith: tableViewConfigs, autoDimension: true)
            table.separatorStyle = .none
            table.backgroundColor = #colorLiteral(red: 0.8430451751, green: 0.843190372, blue: 0.843035996, alpha: 1)
        }
    }
    
    let viewModel = ListsVM()
    let trash = DisposeBag()
    let listObserver = ListObserver()
    
    var displayType: CollectionDisplayType = .displaying {
        didSet {
            table.reloadData()
        }
    }
    
    var lists: [ItemList] = [] {
        didSet {
            table.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.outputs.reloadTable.subscribe(onNext: { [weak self] lists in
            guard let s = self else { return }
            s.lists = lists
        }).disposed(by: trash)
        
        viewModel.outputs.changeDisplay.subscribe(onNext: { [weak self] type in
            guard let s = self else { return }
            s.displayType = type
        }).disposed(by: trash)
        
        viewModel.inputs.viewDidLoad()
        
        listObserver.delegate = self
        
        self.navigationItem.title = "Your Lists"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToListDetail" {
            guard let detailVC = segue.destination as? ListDetailVC else { return }
            detailVC.viewModel.list = sender as? ItemList
        }
    }

}

extension ListsVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayType == .displaying ? self.lists.count + 1 : self.lists.count + 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        
        if indexPath.row < self.lists.count {
            // If the cell being shown is one of the lists
            guard
                let listCell = table.dequeueReusableCell(withIdentifier: CellIds.listCell.rawValue) as? ListCell
            else {
                return cell
            }
            listCell.configure(with: self.lists[indexPath.row])
            cell = listCell
        } else if indexPath.row == self.lists.count {
            if displayType == .displaying {
                // The cell being shown is the add list cell
                guard
                    let addBtnCell = table.dequeueReusableCell(withIdentifier: CellIds.addBtnCell.rawValue) as? AddBtnCell
                    else {
                        return cell
                }
                addBtnCell.configure(with: "Add list") { [weak self] in
                    guard let s = self else { return }
                    s.viewModel.inputs.beginEditing()
                }
                cell = addBtnCell
            } else {
                // the cell being shown is the new list cell
                guard
                    let newListCell = table.dequeueReusableCell(withIdentifier: CellIds.newListCell.rawValue) as? NewListCell
                    else {
                        return cell
                }
                newListCell.delegate = self
                newListCell.startEditing()
                cell = newListCell
            }
        } else {
            // the cell being shown is the add list cell
            guard let addBtnCell = table.dequeueReusableCell(withIdentifier: CellIds.addBtnCell.rawValue) as? AddBtnCell
            else {
                return cell
            }
            addBtnCell.configure(with: "Add list") { [weak self] in
                guard let s = self else { return }
                s.viewModel.inputs.endEditing()
                s.viewModel.inputs.beginEditing()
            }
            cell = addBtnCell
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < self.lists.count {
            performSegue(withIdentifier: "ToListDetail", sender: self.lists[indexPath.row])
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row < self.lists.count
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if indexPath.row < self.lists.count {
                // One of the item cells is being deleted
                lists[indexPath.row].delete()
            }
        }
    }
}

extension ListsVC: ListObserverDelegate {
    func listWasUpdated() {
        viewModel.inputs.listWasUpdated()
    }
}

extension ListsVC: NewListCellDelegate {
    func saveList(name: String) {
        print(name)
        var list = ItemList()
        list.name = name
        list.autoincrementID()
        list.save()
        self.viewModel.inputs.endEditing()
    }
}
