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

class ListDetailVC: UIViewController, TableViewManager, KeyboardObserver {
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.separatorStyle = .none
            tableView.backgroundColor = #colorLiteral(red: 0.9371530414, green: 0.9373135567, blue: 0.9371429086, alpha: 1)
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
    
    @IBOutlet weak var miniForm: MiniForm! {
        didSet {
            miniForm.alpha = 0
            miniForm.delegate = self
            miniForm.layer.cornerRadius = 8
            miniForm.contentView.layer.cornerRadius = 8
            miniForm.formTextField.placeholder = " Add new item"
        }
    }
    
    var listTableDelegate: ListTableViewDelegate?
    let viewModel = ListDetailVM()
    var list: ItemList?
    let trash = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        listTableDelegate = ShoppingListTableViewDelegate()
        
        guard
            let delegate = listTableDelegate,
            let list = list
        else { return }
        
        delegate.registerTableViewCells(forTableView: tableView)
        
        viewModel.outputs.reloadTable.subscribe(onNext: { items in
            delegate.configure(withTable: self.tableView,
                               data: items,
                               animated: false,
                               reloadComp: {
                                    self.animateReloadTable()
                                }, infoBtnComp: { i in
                                    self.showAlert(forItem: i)
                                })
        }).disposed(by: trash)
        
        viewModel.outputs.addItemReload.subscribe(onNext: { items in
            delegate.configure(withTable: self.tableView,
                               data: items,
                               animated: true,
                               reloadComp: {
                                self.animateReloadTable()
                            }, infoBtnComp: { i in
                                self.showAlert(forItem: i)
                            })
        }).disposed(by: trash)
        
        viewModel.inputs.viewDidLoad(list: list)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        observeKeyboard()
    }
    
    func animateReloadTable() {
        tableView.beginUpdates()
        tableView.reloadSections([0], with: .automatic)
        tableView.endUpdates()
    }
    
    func showAlert(forItem item: Item) {
        let alert = UIAlertController(title: "\(item.name)", message: "Actions for \(item.name)", preferredStyle: .actionSheet)
        let editAction = UIAlertAction(title: "Edit", style: .default) { _ in }
        let convertAction = UIAlertAction(title: "Convert to budget list", style: .default) { _ in }
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        alert.addAction(editAction)
        alert.addAction(convertAction)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
}

extension ListDetailVC: MiniFormDelegate {
    
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
    
    func miniFormDidSubmit(text: String) {
        guard text.trimmingCharacters(in: CharacterSet(charactersIn: " ")) != "", let list = list else { return }
        var newItem = Item()
        newItem.name = text
        newItem.autoincrementID()
        newItem.save()
        list.add(item: newItem)
        viewModel.inputs.itemWasAdded(toList: list)
    }
}
