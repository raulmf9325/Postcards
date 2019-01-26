//
//  PinterestPage.swift
//  Postcards
//
//  Created by Raul Mena on 1/18/19.
//  Copyright © 2019 Raul Mena. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseFirestore

class PinterestPage: BasePage{
    
    // MARK: -Properties
   
    // postcards
    var postcards: [String]?{
        didSet{
            self.collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        collectionView.register(PinterestCell.self, forCellWithReuseIdentifier: "CellId")
        collectionView.backgroundView = backgroundView
        setupHeader()
        setupTabBar()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postcards?.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellId", for: indexPath) as! PinterestCell
       
        if postcards != nil{
            cell.postcard = postcards?[indexPath.item]
        }
        
        return cell
    }
    
}
