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
    // postcards
    var album: Album?{
        didSet{
           collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        navigationController?.isNavigationBarHidden = true
        collectionView.register(PinterestCell.self, forCellWithReuseIdentifier: "CellId")
        collectionView.backgroundView = backgroundView
        setupHeader()
        setupTabBar()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return album?.images?.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellId", for: indexPath) as! PinterestCell
        cell.postcard = album?.images?[indexPath.item]
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! PinterestCell
        let postcardDetails = PostcardDetails()
        postcardDetails.postcard.image = cell.cellImage.image
        let rootController = delegate as! RootController
        postcardDetails.rootController = rootController
        
        let layoutAttributes = collectionView.layoutAttributesForItem(at: indexPath)
       
        var selectedFrame: CGRect = .zero
        
        if let frame = layoutAttributes?.frame{
            selectedFrame = collectionView.convert(frame, to: collectionView.superview)
        }

        rootController.pushController(selectedFrame: selectedFrame, vc: postcardDetails)
    }
    
}
