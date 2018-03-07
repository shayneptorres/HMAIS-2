//
//  ListCollectionTableCell.swift
//  HMAIS
//
//  Created by Shayne Torres on 3/4/18.
//  Copyright © 2018 sptorres. All rights reserved.
//

import UIKit

class ListCollectionTableCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
            
            var nib = UINib(nibName: "ListCollectionCell", bundle: nil)
            collectionView.register(nib, forCellWithReuseIdentifier: CellID.listCollectionCell.rawValue)
            
            nib = UINib(nibName: "EmptyCollectionCell", bundle: nil)
            collectionView.register(nib, forCellWithReuseIdentifier: CellID.emptyCollectionCell.rawValue)
            
            let layout = UICollectionViewFlowLayout()
            
            
            layout.itemSize = CGSize(width: 275, height: 200)
            
            layout.minimumInteritemSpacing = 4
            
            layout.scrollDirection = .horizontal
            
            collectionView.collectionViewLayout = layout
        }
    }
    
    var data: [ItemList] = []
    
    var cellTapCompletion: ((_ list: ItemList) -> ())?
    
    func configure(withData lists: [ItemList]) {
        self.data = lists
        
        collectionView.reloadData()
    }
    
}

extension ListCollectionTableCell: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell = UICollectionViewCell()
        
        let listCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: CellID.listCollectionCell.rawValue, for: indexPath) as! ListCollectionCell
        listCollectionCell.configure(withList: data[indexPath.row])
        listCollectionCell.tapCompletion = { list in
            self.cellTapCompletion?(list)
        }
        cell = listCollectionCell
        
        return cell
    }
    
}
