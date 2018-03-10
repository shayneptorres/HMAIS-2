//
//  AddItemToSectionVC.swift
//  HMAIS
//
//  Created by Shayne Torres on 2/25/18.
//  Copyright © 2018 sptorres. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol AddItemToSectionDelegate {
    func itemWasAdded()
}

class AddItemToSectionVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            var nib = UINib(nibName: "CheckItemCell", bundle: nil)
            tableView.register(nib, forCellReuseIdentifier: CellID.checkItemCell.rawValue)
            
            nib = UINib(nibName: "ListSectionHeader", bundle: nil)
            tableView.register(nib, forHeaderFooterViewReuseIdentifier: CellID.checkListSectionHeader.rawValue)
            
            tableView.delegate = self
            tableView.dataSource = self
            tableView.separatorStyle = .none
            tableView.backgroundColor = #colorLiteral(red: 0.9369999766, green: 0.9369999766, blue: 0.9369999766, alpha: 1)
            
        }
    }
    
    @IBOutlet weak var textFieldContainer: UIView! {
        didSet {
            textFieldContainer.applyShadow(.light(.bottom))
            textFieldContainer.layer.cornerRadius = 4
        }
    }
    
    @IBOutlet weak var textField: InsetTextField! {
        didSet {
            textField.delegate = self
        }
    }
    
    @IBOutlet weak var downArrow: UIButton! {
        didSet {
            downArrow.rx.tap.bind(onNext: {
                self.handleSubmitItemFromTextField(textField: self.textField)
            }).disposed(by: trash)
        }
    }
    
    var list: ItemList!
    var listSection: ListSection!
    var delegate: AddItemToSectionDelegate?
    let trash = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        textField.placeholder = "Add item to \(listSection.name)"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textField.becomeFirstResponder()
    }
    
    func handleSubmitItemFromTextField(textField: UITextField) {
        if let text = textField.text, textField.text != "" {
            let item = Item()
            item.name = text
            list.add(item: item, toSectionWithID: listSection.id)
            tableView.insertRows(at: [IndexPath.init(row: 0, section: 0)], with: .automatic)
            textField.text = ""
            delegate?.itemWasAdded()
        }
    }

}

extension AddItemToSectionVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        handleSubmitItemFromTextField(textField: textField)
        
        return true
    }
    
}

extension AddItemToSectionVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listSection.getItems().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        let itemCell = tableView.dequeueReusableCell(withIdentifier: CellID.checkItemCell.rawValue) as! CheckItemCell
        itemCell.displayType = .displayOnly
        itemCell.configure(withItem: listSection.getItems()[indexPath.row]) {
            print("info button pressed")
        }
        cell = itemCell
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Row was tapped")
        var item = listSection.getItems()[indexPath.row]
        
        item.update { updateItem in
            updateItem.completed = !updateItem.completed
        }
        
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: CellID.checkListSectionHeader.rawValue) as! ListSectionHeader
        
        header.btnStyle = .none
        header.configure(withName: listSection.name) {}
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
}
