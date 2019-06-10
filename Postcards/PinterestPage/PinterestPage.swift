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

struct postcard{
    var albumName: String
    var imageStringURL: String
}

class PinterestPage: BasePage{
    /*
        Pinterest Page is used for both, they entry page with all albums
        and for album details. Therefore, it can have either 'albums' or 'album' (but not both)
     */
    
    // postcards
    var albums: [Album]?{
        didSet{
            guard let albums = albums else {return}
            
            albums.forEach { (album) in
               let items = album.images?.map({ (image) -> postcard in
                    return postcard(albumName: album.name ?? "", imageStringURL: image)
                })
                self.postcards.append(contentsOf: items ?? [])
            }
            
           collectionView.reloadData()
        }
    }
    
    var album: Album?{
        didSet{
            guard let albumName = album?.name else {return}
            self.postcards = album?.images?.map({ (image) -> postcard in
                return postcard(albumName: albumName, imageStringURL: image)
            }) ?? []
        }
    }
    
    var postcards = [postcard]()
    
    override func viewDidLoad() {
        navigationController?.isNavigationBarHidden = true
        collectionView.register(PinterestCell.self, forCellWithReuseIdentifier: "CellId")
        collectionView.backgroundView = backgroundView
        setupHeader()
        setupTabBar()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postcards.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellId", for: indexPath) as! PinterestCell
        cell.postcard = postcards[indexPath.item].imageStringURL
        cell.albumName = postcards[indexPath.item].albumName
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! PinterestCell
        let postcardDetails = PostcardDetails()
        postcardDetails.postcard.image = cell.cellImage.image
        postcardDetails.headTitle = cell.albumName ?? ""
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
