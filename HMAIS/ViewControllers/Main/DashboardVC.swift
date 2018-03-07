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

enum DashboardTableSection: Int {
    case recent = 0
    case favorite = 1
}

extension DashboardTableSection {
    var sectionTitle: String {
        switch self {
        case .recent:
            return "Recently used:"
        case .favorite:
            return "Favorites:"
        }
    }
}

class DashboardVC: UIViewController, ListObserverDelegate {
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            
            tableView.estimatedRowHeight = 216
            tableView.rowHeight = UITableViewAutomaticDimension
            
            tableView.separatorStyle = .none
            
            var nib = UINib(nibName: "ListCollectionTableCell", bundle: nil)
            tableView.register(nib, forCellReuseIdentifier: CellID.listCollectionTableCell.rawValue)
            
            nib = UINib(nibName: "DashSectionHeader", bundle: nil)
            tableView.register(nib, forHeaderFooterViewReuseIdentifier: CellID.dashSectionHeader.rawValue)
            
        }
    }
    
    func listsWereUpdated() {
        viewModel.inputs.viewDidLoad()
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
        
        viewModel.inputs.viewDidLoad()
        
        ListObserver.instance.addDelegate(observer: self)
        
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)]
        self.navigationController?.navigationBar.isHidden = true
    }
    
    func goToLists() {
        guard
            let tab = self.tabBarController,
            let vcs = tab.viewControllers,
            let animatedNav = vcs[1] as? AnimatedNavController,
            let lists = animatedNav.viewControllers[0] as? ListsVC
        else { return }
        
        tab.selectedIndex = 1
        Timer.after(0.3.second) {
            lists.miniForm.beginEditing()
        }
    }
    
    func goToListDetail(list: ItemList) {
        let listsSB = UIStoryboard(name: "Lists", bundle: nil)
        let listDetail = listsSB.instantiateViewController(withIdentifier: "ListDetail") as! ListDetailVC
        listDetail.list = list
        self.navigationController?.pushViewController(listDetail, animated: true)
    }
    
    func animateSelectListTypeAndShoDetails(typeRaw: Int, list: ItemList) {
        var l = list
        l.update { updatedList in
            updatedList.type = typeRaw
        }
        tableView.reloadSections([0,1], with: .automatic)
        Timer.after(0.4.seconds) {
            self.goToListDetail(list: list)
        }
    }

}

extension DashboardVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let listCollectionTableCell = tableView.dequeueReusableCell(withIdentifier: CellID.listCollectionTableCell.rawValue) as! ListCollectionTableCell
        
        let section = DashboardTableSection(rawValue: indexPath.section) ?? .recent
        
        switch section {
        case .recent:
            listCollectionTableCell.configure(withData: recents)
            
            
        case .favorite:
            listCollectionTableCell.configure(withData: favorites)
        }
        
        let actionCreator = ActionSheetCreator(viewController: self)
        
        
        
        listCollectionTableCell.cellTapCompletion = { list in
            if list.listItemType == .new {
                actionCreator.createActionSheet(withTitle: "Categorize '\(list.name)'", message: "This list does not have a category set one now to use it.", withActions: [
                        UIAlertAction(title: "Make Shopping list", style: .default, handler: { _ in
                            self.animateSelectListTypeAndShoDetails(typeRaw: 2, list: list)
                        }),
                        UIAlertAction(title: "Make Budget list", style: .default, handler: { _ in
                            self.animateSelectListTypeAndShoDetails(typeRaw: 3, list: list)
                        }),
                        UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in })
                    ])
            } else {
                self.goToListDetail(list: list)
            }
        }
        
        listCollectionTableCell.selectionStyle = .none
        
        
        return listCollectionTableCell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: CellID.dashSectionHeader.rawValue) as! DashSectionHeader
        
        let sectionType = DashboardTableSection(rawValue: section) ?? .recent
        
        header.configure(withName: sectionType.sectionTitle)
        
        if section == 0 {
            print("Set")
            header.addCompletion = {
                self.goToLists()
            }
        } else {
            print("Nilled")
            header.addCompletion = nil
        }
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
}
