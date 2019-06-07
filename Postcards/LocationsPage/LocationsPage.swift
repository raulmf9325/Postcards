//
//  LocationsPage.swift
//  Postcards
//
//  Created by Raul Mena on 1/25/19.
//  Copyright © 2019 Raul Mena. All rights reserved.
//

import UIKit
import Firebase

class LocationsPage: BasePage{
    
//    var snapshot: QuerySnapshot?{
//        didSet{
//            guard let snapshot = snapshot else {return}
//
//            for album in snapshot.documents{
//                guard let data = album.data() as? [String:String] else {return}
//                var images = Array(data.values.map{$0})
//                images.insert(album.documentID, at: 0)
//                albums.append(images)
//            }
//
//            self.collectionView.reloadData()
//        }
//    }
//
//    var albums = [[String]]()
    
    var albums: [Album]?{
        didSet{
            collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        navigationController?.isNavigationBarHidden = true
        collectionView.backgroundView = backgroundView
        collectionView.register(AlbumCell.self, forCellWithReuseIdentifier: "CellId")
        let layout = self.collectionViewLayout as! UICollectionViewFlowLayout
        layout.scrollDirection = .horizontal
        
        headerSetup()
        
        homeButton.setImage(UIImage(named: "homeInactive"), for: .normal)
        locationButton.setImage(UIImage(named: "locationsActive"), for: .normal)
        setupTabBar()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albums?.count ?? 0
    }
    
    fileprivate func headerSetup(){
        headTitle = "Albums"
        setupHeader()
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let albumDetails = AlbumDetails(collectionViewLayout: PinterestLayout())
        albumDetails.delegate = self.delegate
        albumDetails.headTitle = albums?[indexPath.item].name ?? ""
        albumDetails.album = albums?[indexPath.item]
        
        let selectedFrame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: view.frame.height)
        
        let rootController = delegate as! RootController
        rootController.pushController(selectedFrame: selectedFrame, vc: albumDetails)
    }
    
}

extension LocationsPage: UICollectionViewDelegateFlowLayout{
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellId", for: indexPath) as! AlbumCell
        cell.album = albums?[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let horizontalPadding: CGFloat = 55
        let verticalPadding: CGFloat = 50
        return CGSize(width: view.frame.width - (2 * horizontalPadding), height: view.frame.height - (PinterestHeader.frame.height + tabBar.frame.height + 2 * verticalPadding))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
}

// MARK: Album class
struct Album{
    var name: String?
    var images: [String]?
}
