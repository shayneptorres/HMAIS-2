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
import SwiftyTimer

class ListsVC: UIViewController, TableViewManager, KeyboardObserver {
    
    @IBOutlet weak var miniForm: MiniForm! {
        didSet {
            miniForm.alpha = 0
            miniForm.delegate = self
            miniForm.layer.cornerRadius = 8
            miniForm.contentView.layer.cornerRadius = 8
            miniForm.formTextField.placeholder = " Add new list"
        }
    }
    
    @IBOutlet weak var addBtn: UIButton! {
        didSet {
            addBtn.rx
                .tap
                .bind(onNext: { [weak self] in
                    guard let s = self else { return }
                    s.miniForm.beginEditing()
                })
                .disposed(by: trash)
        }
    }
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            
            let cellConfigs: [CellConfig] = [
                CellConfig(nibName: "ListCell", cellID: CellID.listCell),
                CellConfig(nibName: "EmptyTableCell", cellID: CellID.emptyCell)
            ]
            
            configure(with: tableView, andWith: cellConfigs, autoDimension: true)

            tableView.separatorStyle = .none
            tableView.backgroundColor = #colorLiteral(red: 0.9371530414, green: 0.9373135567, blue: 0.9371429086, alpha: 1)
        }
    }
    
    let viewModel = ListsVM()
    let trash = DisposeBag()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        observeKeyboard()
    }
    
    var displayType: CollectionDisplayType = .displaying
    
    var lists: [ItemList] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.outputs.reloadTable.subscribe(onNext: { [weak self] lists in
            guard let s = self else { return }
            s.lists = lists
            s.tableView.reloadData()
        }).disposed(by: trash)
        
        viewModel.outputs.addList.subscribe(onNext: { [weak self] lists in
            guard let s = self else { return }
            s.lists = lists
            
            s.tableView.beginUpdates()
            s.tableView.reloadSections([0], with: .automatic)
            s.tableView.endUpdates()
        }).disposed(by: trash)
        
        viewModel.inputs.viewDidLoad()
        
        self.navigationItem.title = "Your Lists"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToListDetail" {
            guard let list = sender as? ItemList else { return }
            let detail = segue.destination as! ListDetailVC
            detail.list = list
        }
    }
    
    func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            showMiniForm(atHeight: keyboardHeight)
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            hideMiniForm()
        }
    }
    
    func showMiniForm(atHeight height: CGFloat) {
        miniForm.alpha = 1
        let translationY = -height + miniForm.frame.height + 5
        let transform = CGAffineTransform(translationX: 0, y: translationY)
        miniForm.transform = transform
    }
    
    func hideMiniForm() {
        miniForm.alpha = 0
        let transform = CGAffineTransform(translationX: 0, y: 0)
        miniForm.transform = transform
    }
    
    func assignListType(list: ItemList, newType: Int) {
        guard newType != -1 else { return }
        var editableList = list
        editableList.update(completion: { updateList in
            updateList.type = newType
        })
        UIView.animate(withDuration: 0.7, animations: {
            self.viewModel.inputs.listWasAdded()
        }, completion: { _ in
            Timer.after(1.second) {
                self.performSegue(withIdentifier: "ToListDetail", sender: list)
            }
        })
    }

}

extension ListsVC: MiniFormDelegate {
    func miniFormDidSubmit(text: String) {
        guard text.trimmingCharacters(in: CharacterSet(charactersIn: " ")) != "" else { return }
        var newList = ItemList()
        newList.name = text
        newList.autoincrementID()
        newList.save()
        viewModel.inputs.listWasAdded()
    }
}

extension ListsVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (lists.isEmpty) ? 1 : lists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        if lists.isEmpty {
            let emptyCell = tableView.dequeueReusableCell(withIdentifier: CellID.emptyCell.rawValue) as! EmptyTableCell
            emptyCell.configure(withMessage: EmptyCellMessage.list.message)
            cell = emptyCell
        } else {
            let listCell = tableView.dequeueReusableCell(withIdentifier: CellID.listCell.rawValue) as! ListCell
            
            listCell.configure(withList: lists[indexPath.row])
            
            cell = listCell
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !lists.isEmpty else { return } // if there are no lists, dont allow cell selection
        
        let list = lists[indexPath.row]
        
        if list.type == 1 { // is a new list
            // assign a list type
            let alert = UIAlertController(title: "\(list.name)", message: "\(list.name) is a new list, assign it a type.", preferredStyle: .actionSheet)
            let budgetOption = UIAlertAction(title: "Make Budget list", style: .default) { _ in self.assignListType(list: list, newType: 3) }
            let shoppingOption = UIAlertAction(title: "Make Shopping list", style: .default) { _ in self.assignListType(list: list, newType: 2) }
            let cancelOption = UIAlertAction(title: "Cancel", style: .cancel) { _ in  }
            alert.addAction(shoppingOption)
            alert.addAction(budgetOption)
            alert.addAction(cancelOption)
            present(alert, animated: true)
        } else {
            performSegue(withIdentifier: "ToListDetail", sender: list)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 55
    }
}
