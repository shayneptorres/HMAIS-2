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
    var editingSection: ListSection?
    let viewModel = ListDetailVM()
    var list: ItemList?
    let trash = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        listTableDelegate = ShoppingListTableViewDelegate()
        
        listTableDelegate?.sectionAddBtnCompletion = { section in
            self.editingSection = section
            self.miniForm.beginEditing()
        }
        
        guard
            let delegate = listTableDelegate,
            let list = list
        else { return }
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "settings_btn_three_dots.png"), style: .plain, target: self, action: #selector(showListSettingsAlert))
        
        if !list.sections.isEmpty {
            addBtn.isHidden = true
        }
        
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
        
        viewModel.outputs.reloadTableWithSections.subscribe(onNext: { sections in
            delegate.configure(withTable: self.tableView,
                               sections: sections,
                               animated: true,
                               reloadComp: {
                                self.animateReloadTable()
            }, infoBtnComp: { i in
                self.showAlert(forItem: i)
            })
        }).disposed(by: trash)
        
        viewModel.outputs.reloadTableWithAddedSection.subscribe(onNext: { sections in
            delegate.configure(withTable: self.tableView,
                               sections: sections,
                               animated: true,
                               reloadComp: {
                                self.reloadForNewSection()
            }, infoBtnComp: { i in
                self.showAlert(forItem: i)
            })
        }).disposed(by: trash)
        
        viewModel.outputs.reloadSection.subscribe(onNext: { (section, data) in
            delegate.configure(withTable: self.tableView,
                               sections: data,
                               animated: true,
                               reloadComp: {
                                self.animateReloadSection(section: section)
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
    
    func reloadForNewSection() {
        UIView.transition(with: tableView, duration: 0.3, options: .transitionCrossDissolve, animations: { self.tableView.reloadData() }, completion: nil)
    }
    
    func animateReloadTable() {
        guard let list = list else { return }
        UIView.transition(with: tableView, duration: 0.3, options: .transitionCrossDissolve, animations: { self.tableView.reloadData() }, completion: nil)
//        tableView.beginUpdates()
//        if list.sections.isEmpty {
//            tableView.reloadSections(IndexSet(integersIn: 0...list.sections.count), with: .automatic)
//        } else {
//            self.tableView.reloadSections([0], with: .automatic)
//        }
//        tableView.endUpdates()
    }
    
    func animateReloadSection(section: Int) {
        UIView.transition(with: tableView, duration: 0.3, options: .transitionCrossDissolve, animations: { self.tableView.reloadData() }, completion: nil)
//        tableView.beginUpdates()
//        tableView.reloadSections([section], with: .automatic)
//        tableView.endUpdates()
    }
    
    
    func showAlert(forItem item: Item) {
        let alert = UIAlertController(title: "\(item.name)", message: nil, preferredStyle: .actionSheet)
        let editAction = UIAlertAction(title: "Edit", style: .default) { _ in }
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            item.delete()
            self.viewModel.reloadList(withListID: self.list?.id ?? 0)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        alert.addAction(editAction)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    @objc func showListSettingsAlert() {
        guard let list = list else { return }
        let alert = UIAlertController(title: "\(list.name)", message: nil, preferredStyle: .actionSheet)
        let convertAction = UIAlertAction(title: "Convert to budget list", style: .default) { _ in }
        let addSectionAction = UIAlertAction(title: "Add section", style: .default) { _ in
            let formSB = UIStoryboard(name: "Forms", bundle: nil)
            let mainSB = UIStoryboard(name: "Main", bundle: nil)
            guard
                let modal = mainSB.instantiateViewController(withIdentifier: "ModalForm") as? ModalFormNav,
                let addSection = formSB.instantiateViewController(withIdentifier: "AddSectionVC") as? AddSectionFormVC,
                let nav = self.navigationController,
                let tab = nav.parent as? UITabBarController
            else { return }
            modal.modalTransitionStyle = .crossDissolve
            addSection.list = list
            addSection.delegate = self
            modal.present(addSection, from: tab, animated: true)
        }
        let editAction = UIAlertAction(title: "Edit", style: .default) { _ in }
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        alert.addAction(addSectionAction)
        alert.addAction(convertAction)
        alert.addAction(editAction)
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
        
        if editingSection != nil {
            editingSection?.addItem(newItem)
        } else {
            list.add(item: newItem)
        }
        
        viewModel.inputs.itemWasAdded(toList: list)
    }
}

extension ListDetailVC: AddSectionDelegate {
    func sectionWasAdded() {
        guard let list = list else { return }
        self.viewModel.inputs.reloadWithNewSection(withListID: list.id)
    }
}
