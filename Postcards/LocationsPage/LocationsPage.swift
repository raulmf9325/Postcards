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
    
    var albums: [Album]?{
        didSet{
            guard let count = albums?.count else {return}
            headSubtitle = "\(count) albums"
            setHeaderTitle()
            collectionView.reloadData()
        }
    }
    
    var popUp: PopUp!
    
    override func viewDidLoad() {
        navigationController?.isNavigationBarHidden = true
        collectionView.backgroundView = backgroundView
        collectionView.register(AlbumCell.self, forCellWithReuseIdentifier: "CellId")
        let layout = self.collectionViewLayout as! UICollectionViewFlowLayout
        layout.scrollDirection = .horizontal
        
        headerSetup()
        addPlusButton()
        
        homeButton.setImage(UIImage(named: "homeInactive"), for: .normal)
        locationButton.setImage(UIImage(named: "locationsActive"), for: .normal)
        favoritesButton.setImage(UIImage(named: "favorites"), for: .normal)
        setupTabBar()
        
        startActivityIndicator()
        
        popUp = PopUp(frame: view.frame)
        popUp.delegate = self
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albums?.count ?? 0
    }
    
    private func headerSetup(){
        headTitle = "Collections"
        setupHeader()
    }
    
    override func handleTapPlusButton() {
        view.addSubview(popUp)
        popUp.present()
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let albumDetails = AlbumDetails(collectionViewLayout: PinterestLayout(topInset: 80))
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
        let horizontalPadding: CGFloat = 50
        let width: CGFloat = view.frame.width - (2 * horizontalPadding)
        let verticalPadding: CGFloat = (view.frame.height - 150) / 7
        let height: CGFloat = view.frame.height - (100 + 50 + 2 * verticalPadding)
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
}

extension LocationsPage: PopupDelegate{
    func handleUserEntry(albumName: String) {
        guard let user = Auth.auth().currentUser?.email else {return}
        albums?.append(Album(name: albumName, storageDirectory: "users/\(user)", postcards: nil))
        collectionView.reloadData()
        
        let albumDoc = db.collection("users").document(user).collection("albums").document("\(albumName)")
        albumDoc.setData([:])
    }
}


// MARK: Album class
struct Album{
    var name: String?
    var storageDirectory: String? // directory in cloud storage
    var postcards: [postcard]?
}
