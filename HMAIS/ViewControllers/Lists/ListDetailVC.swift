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

class ListDetailVC: UIViewController, TableViewManager, KeyboardObserver, ModalPresentable {
    
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
                    guard let s = self, let list = s.list else { return }
                    if list.listItemType == .shopping {
                        s.miniForm.beginEditing()
                    } else {
                        self?.presentModal(modalType: ModalFormType.addBudgetItem(list: list, section: nil, item: nil)) { vc in
                            guard let budgetItemForm = vc as? BudgetItemForm else { return }
                            budgetItemForm.delegate = self
                        }
                    }
                    
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
        
        // set up the table view delegate based on the list type
        listTableDelegate = (list?.type == 2) ? ShoppingListTableViewDelegate() : BudgetListTableViewDelegate()
        
        configureUI(withListType: list?.listItemType ?? .shopping)
        
        listTableDelegate?.sectionAddBtnCompletion = { section in
            guard
                let list = self.list
            else { return }

            if list.listItemType == .shopping {
                self.presentModal(modalType: ModalFormType.addItemToSection(list: list, section: section)) { viewController in
                    guard let addItemToSection = viewController as? AddItemToSectionVC else { return }
                    addItemToSection.delegate = self
                }
            } else {
                self.presentModal(modalType: ModalFormType.addBudgetItem(list: list, section: section, item: nil)) { viewController in
                    guard let budgetItemForm = viewController as? BudgetItemForm else { return }
                    budgetItemForm.delegate = self
                }
            }

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
            
            list.sections.isEmpty ? (delegate.data = list.items.toArray()) : (delegate.sections = list.sections.toArray())
            
            if let budgetDelegate = delegate as? BudgetListTableViewDelegate {
                budgetDelegate.rowSelectionCompletion = { i in
                    
                }
                
                budgetDelegate.list = list
                
                self.animateReloadTable()
            } else if let shoppingDelegate = delegate as? ShoppingListTableViewDelegate {
                shoppingDelegate.infoButtonCompletion = { i in
                    // when the info button is tapped, display the info settings alert
                    self.showAlert(forItem: i)
                }
                
                shoppingDelegate.reloadCompletion = {
                    self.animateReloadTable()
                }
                
                shoppingDelegate.reloadCompletion?()
            }
            
            
            // hide the add btn if there are sections
            self.addBtn.isHidden = !list.sections.isEmpty
        }).disposed(by: trash)
        
        viewModel.outputs.reloadTableWithSections.subscribe(onNext: { sections in
            list.sections.isEmpty ? (delegate.data = list.items.toArray()) : (delegate.sections = sections)
            
            if let budgetDelegate = delegate as? BudgetListTableViewDelegate {
                budgetDelegate.rowSelectionCompletion = { i in
                    
                }
                
                budgetDelegate.list = list
                
                budgetDelegate.sectionAddBtnCompletion = { section in
                    self.presentModal(modalType: .addBudgetItem(list: list, section: section, item: nil)) { vc in
                        guard let budgetItemForm = vc as? BudgetItemForm else { return }
                        budgetItemForm.delegate = self
                    }
                }
                
                self.reloadTable(animated: true)
                
            } else if let shoppingDelegate = delegate as? ShoppingListTableViewDelegate {
                shoppingDelegate.infoButtonCompletion = { i in
                    // when the info button is tapped, display the info settings alert
                    self.showAlert(forItem: i)
                }
                
                shoppingDelegate.reloadCompletion = {
                    self.animateReloadTable()
                }
                
                shoppingDelegate.reloadCompletion?()
            }
            
            
            // hide the add btn if there are sections
            self.addBtn.isHidden = !list.sections.isEmpty
        }).disposed(by: trash)
        
        viewModel.outputs.reloadSection.subscribe(onNext: { (section, data) in
            
            delegate.sections = data
            
            if let budgetDelegate = delegate as? BudgetListTableViewDelegate {
                budgetDelegate.rowSelectionCompletion = { i in
                    
                }
                
                budgetDelegate.list = list
            } else if let shoppingDelegate = delegate as? ShoppingListTableViewDelegate {
                shoppingDelegate.infoButtonCompletion = { i in
                    // when the info button is tapped, display the info settings alert
                    self.showAlert(forItem: i)
                }
                
                shoppingDelegate.reloadCompletion = {
                    self.animateReloadSection(section: section)
                }
                
                shoppingDelegate.reloadCompletion?()
            }
            
            
            // hide the add btn if there are sections
            self.addBtn.isHidden = !list.sections.isEmpty
            
        }).disposed(by: trash)
        
        viewModel.inputs.viewDidLoad(list: list)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        observeKeyboard()
    }
    
    func configureUI(withListType type: ListItemType) {
        switch type {
        case .shopping:
            self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.4830000103, green: 0.8349999785, blue: 0, alpha: 1)
            self.addBtn.backgroundColor = #colorLiteral(red: 0.4830000103, green: 0.8349999785, blue: 0, alpha: 1)
        case .budget:
            self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.9679999948, green: 0.6549999714, blue: 0, alpha: 1)
            self.addBtn.backgroundColor = #colorLiteral(red: 0.9679999948, green: 0.6549999714, blue: 0, alpha: 1)
        default:
            break
        }
        
    }
    
    func animateReloadTable() {
        guard let list = list else { return }
        UIView.transition(with: tableView, duration: 0.2, options: .transitionCrossDissolve, animations: { self.tableView.reloadData() }, completion: nil)
    }
    
    func reloadTable(animated: Bool) {
        guard let list = list else { return }
        let duration = animated ? 0.2 : 0.0
        UIView.transition(with: tableView, duration: duration, options: .transitionCrossDissolve, animations: { self.tableView.reloadData() }, completion: nil)
    }
    
    func animateReloadSection(section: Int) {
        tableView.beginUpdates()
        tableView.reloadSections([section], with: .automatic)
        tableView.endUpdates()
    }

    func displayEditItemModal(forItem item: Item) {
        presentModal(modalType: .editItem(item: item)) { viewController in
            guard let shoppingItemForm = viewController as? ShoppingItemFormVC else { return }
            shoppingItemForm.delegate = self
        }
    }
    
    func showAlert(forItem item: Item) {
        let actionSheet = ActionSheetCreator(viewController: self)
            actionSheet.createActionSheet(withTitle: "\(item.name)", withActions: [
                UIAlertAction(title: "Edit", style: .default) { _ in self.displayEditItemModal(forItem: item) },
                UIAlertAction(title: "Delete", style: .destructive) { _ in
                    item.delete()
                    self.viewModel.reloadList(withListID: self.list?.id ?? 0)
                },
                UIAlertAction(title: "Cancel", style: .cancel) { _ in }
            ]
        )
    }
    
    @objc func showListSettingsAlert() {
        guard let list = list else { return }
        
        let actionSheet = ActionSheetCreator(viewController: self)
        
        var actions: [UIAlertAction] = [
            UIAlertAction(title: "Add section", style: .default) { _ in
                // present a modal with the add section form
                self.presentModal(modalType: ModalFormType.addSection(list: list)) { viewController in
                    guard let addSectionVC = viewController as? AddSectionFormVC else { return }
                    addSectionVC.delegate = self
                }
            },
            UIAlertAction(title: "Delete", style: .destructive) { _ in
                // show an alert to make sure the user wants to delete this list
                actionSheet.createActionSheet(withTitle: "Delete list '\(list.name)'", message: "Are you sure you want to delete this list?", withActions: [
                    UIAlertAction(title: "Yes", style: .destructive) { _ in
                        self.navigationController?.popViewController(animated: true)
                        list.totalDelete()
                    },
                    UIAlertAction(title: "Cancel", style: .cancel) { _ in }
                ])
            },
            UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        ]
        
        if !list.items.isEmpty || !list.sections.isEmpty {
            // if there are any items or sections, show the edit action
            actions.insert(UIAlertAction(title: "Edit", style: .default) { _ in
                self.beginEditingTableView()
            }, at: 0)
        }
        
        if let budgetDelegate = self.listTableDelegate as? BudgetListTableViewDelegate {
            actions.insert(UIAlertAction(title: "Set Budget", style: .default) { _ in
                self.presentModal(modalType: .setBudet(list: list)) { vc in
                    guard let setBudgetVC = vc as? BudgetListBudgetFormVC else { return }
                    setBudgetVC.delegate = self
                }
            }, at: 0)
        }
        
        actionSheet.createActionSheet(withTitle: "\(list.name)", withActions: actions)
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

extension ListDetailVC: AddItemToSectionDelegate, BudgetItemFormDelegate {
    func itemWasAdded() {
        guard let list = list else { return }
        self.viewModel.inputs.reloadList(withListID: list.id)
    }
}

extension ListDetailVC: BudgetFormDelegate {
    func budgetWasSet() {
        reloadTable(animated: true)
    }
}
