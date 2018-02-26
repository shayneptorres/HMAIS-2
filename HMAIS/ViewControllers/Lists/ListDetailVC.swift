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
import IHKeyboardAvoiding
import AssistantKit

class ListDetailVC: UIViewController, TableViewManager, KeyboardObserver {
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.separatorStyle = .none
            tableView.backgroundColor = #colorLiteral(red: 0.9371530414, green: 0.9373135567, blue: 0.9371429086, alpha: 1)
        }
    }
    
    @IBOutlet weak var addBtn: UIButton! {
        didSet {
            
            addBtn.layer.cornerRadius = 4
            
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
    var initialTVHeight: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        listTableDelegate = ShoppingListTableViewDelegate()
        
        listTableDelegate?.sectionAddBtnCompletion = { section in
            let mainSB = UIStoryboard(name: "Main", bundle: nil)
            let itemsSB = UIStoryboard(name: "Items", bundle: nil)
            guard
                let list = self.list,
                let sectionIndex = list.sections.map({ $0.id }).index(where: { id in id == section.id }),
                let modal = mainSB.instantiateViewController(withIdentifier: "ModalForm") as? ModalFormNav,
                let addItem = itemsSB.instantiateViewController(withIdentifier: "AddItemToSection") as? AddItemToSectionVC,
                let nav = self.navigationController,
                let tab = nav.parent as? UITabBarController
            else { return }
            
            addItem.list = list
            addItem.listSection = section
            addItem.delegate = self
            
            
            modal.modalTransitionStyle = .crossDissolve
            modal.formType = .addItemToSection
            
            
            modal.present(addItem, from: tab, animated: true)
        }
        
        guard
            let delegate = listTableDelegate,
            let list = list
        else { return }
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "settings_btn_three_dots.png"), style: .plain, target: self, action: #selector(showListSettingsAlert))
        
        self.navigationItem.title = "\(list.name)"
        
        delegate.viewController = self
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
            // hide the add btn if there are sections
            self.addBtn.isHidden = !list.sections.isEmpty
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
            // hide the add btn if there are sections
            self.addBtn.isHidden = !list.sections.isEmpty
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
            // hide the add btn if there are sections
            self.addBtn.isHidden = !list.sections.isEmpty
        }).disposed(by: trash)
        
        viewModel.inputs.viewDidLoad(list: list)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        observeKeyboard()
    }
    
    func animateReloadTable() {
        guard let list = list else { return }
        UIView.transition(with: tableView, duration: 0.1, options: .transitionCrossDissolve, animations: { self.tableView.reloadData() }, completion: nil)
    }
    
    func animateReloadSection(section: Int) {
        tableView.beginUpdates()
        tableView.reloadSections([section], with: .automatic)
        tableView.endUpdates()
    }

    func displayEditItemModal(forItem item: Item) {
        let formSB = UIStoryboard(name: "Forms", bundle: nil)
        let mainSB = UIStoryboard(name: "Main", bundle: nil)
        guard
            let modal = mainSB.instantiateViewController(withIdentifier: "ModalForm") as? ModalFormNav,
            let shoppingItemForm = formSB.instantiateViewController(withIdentifier: "ShoppingItemForm") as? ShoppingItemFormVC,
            let nav = self.navigationController,
            let tab = nav.parent as? UITabBarController
            else { return }
        modal.modalTransitionStyle = .crossDissolve
        
        shoppingItemForm.editingItem = item
        shoppingItemForm.delegate = self
        modal.formType = .editItem
        modal.present(shoppingItemForm, from: tab, animated: true)
    }
    
    func showAlert(forItem item: Item) {
        
        let alert = UIAlertController(title: "\(item.name)", message: nil, preferredStyle: .actionSheet)
        let editAction = UIAlertAction(title: "Edit", style: .default) { _ in
            self.displayEditItemModal(forItem: item)
        }
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
        
        let formSB = UIStoryboard(name: "Forms", bundle: nil)
        let mainSB = UIStoryboard(name: "Main", bundle: nil)
        guard
            let modal = mainSB.instantiateViewController(withIdentifier: "ModalForm") as? ModalFormNav,
            let addSection = formSB.instantiateViewController(withIdentifier: "AddSectionVC") as? AddSectionFormVC,
            let shoppingItemForm = formSB.instantiateViewController(withIdentifier: "ShoppingItemForm") as? ShoppingItemFormVC,
            let nav = self.navigationController,
            let tab = nav.parent as? UITabBarController
        else { return }
        modal.modalTransitionStyle = .crossDissolve
        
        
        let alert = UIAlertController(title: "\(list.name)", message: nil, preferredStyle: .actionSheet)

        let addSectionAction = UIAlertAction(title: "Add section", style: .default) { _ in
            addSection.list = list
            addSection.delegate = self
            modal.present(addSection, from: tab, animated: true)
        }
        let editAction = UIAlertAction(title: "Edit", style: .default) { _ in
            self.beginEditingTableView()
        }
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            // show an alert to make sure the user wants to delete this list
            let alert = UIAlertController(title: "Delete list '\(self.list?.name ?? "")'", message: "Are you sure you want to delete this list?", preferredStyle: .actionSheet)
            let deleteAction = UIAlertAction(title: "Yes", style: .destructive) { _ in
                self.navigationController?.popViewController(animated: true)
                list.totalDelete()
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
            
            alert.addAction(deleteAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        
        if !list.items.isEmpty || !list.sections.isEmpty {

            alert.addAction(editAction)
        }
        
        alert.addAction(addSectionAction)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    func beginEditingTableView() {
        tableView.beginUpdates()
        self.tableView.isEditing = true
        tableView.endUpdates()
        // stall animation so the editing animation can happen
        Timer.after(0.5.seconds, {
            self.tableView.reloadData()
        })
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(endEditingTableView))
        
    }
    
    @objc func endEditingTableView() {
        tableView.beginUpdates()
        self.tableView.isEditing = false
        tableView.endUpdates()
        // stall animation so the editing animation can happen
        Timer.after(0.5.seconds, {
            self.tableView.reloadData()
        })
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "settings_btn_three_dots.png"), style: .plain, target: self, action: #selector(showListSettingsAlert))
    }
    
    @objc func endEditingMiniForm() {
        miniForm.endEditing(true)
    }
    
}

extension ListDetailVC: MiniFormDelegate {
    
    func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            // adjust the table view frame so it can scroll when keyboard shows

            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            
            guard
                let nav = self.navigationController,
                let tab = nav.parent as? UITabBarController
            else { return }
            
            if tab.presentedViewController is ModalFormNav {
                // if there is a modal being presented, dont do anything
            } else {
                // else show the miniform
                showMiniForm(atHeight: keyboardHeight)
            }
            
            
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            hideMiniForm()
        }
    }
    
    func showMiniForm(atHeight height: CGFloat) {
        miniForm.alpha = 1
        
        var translationY = -height + miniForm.frame.height + 5
        if Device.isPhoneX {
            translationY -= 20
        }
        
        // move the mini form up
        let transform = CGAffineTransform(translationX: 0, y: translationY)
        miniForm.transform = transform
        
        if let section = editingSection, let list = list {
            let index = list.sections.index(of: section)
            tableView.scrollRectToVisible(tableView.rect(forSection: index ?? 0), animated: true)
            
        }
        
        // change the bar button item to the done button
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(endEditingMiniForm))
    }
    
    func hideMiniForm() {
        miniForm.alpha = 0
        // transform the miniform back to its origin
        let transform = CGAffineTransform(translationX: 0, y: 0)
        miniForm.transform = transform
        
        // change the bar button item back to the list menu
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "settings_btn_three_dots.png"), style: .plain, target: self, action: #selector(showListSettingsAlert))
    }
    
    func miniFormDidSubmit(text: String) {
        guard text.trimmingCharacters(in: CharacterSet(charactersIn: " ")) != "", let list = list else { return }
        
        var newItem = Item()
        newItem.name = text
        
        if editingSection != nil {
            guard let sectionIndex = list.sections.map({ $0.id }).index(where: { id in id == editingSection?.id }) else { return }
            
            editingSection?.addItem(newItem)
            viewModel.inputs.reloadSection(section: sectionIndex, toListWithID: list.id)
        } else {
            list.add(item: newItem)
            viewModel.inputs.itemWasAdded(toList: list)
        }

    }
}

extension ListDetailVC: AddSectionDelegate {
    func sectionWasAdded() {
        guard let list = list else { return }
        self.viewModel.inputs.reloadList(withListID: list.id)
    }
}

extension ListDetailVC: ShoppingItemFormDelegate {
    func itemWasUpdated() {
        guard let list = list else { return }
        self.viewModel.inputs.reloadList(withListID: list.id)
    }
}

extension ListDetailVC: AddItemToSectionDelegate {
    func itemWasAdded() {
        guard let list = list else { return }
        self.viewModel.inputs.reloadList(withListID: list.id)
    }
}
