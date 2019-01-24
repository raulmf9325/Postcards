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

class PinterestPage: UICollectionViewController{
    
    // MARK: -Properties
    
    // storage reference
    var storage = Storage.storage()
    
    // Firestore reference
    var db = Firestore.firestore()
    
    //page state
    enum pageState{
        case home
        case locations
        case favorites
    }
    
   
    var page: pageState!
    
     // tab bar
    let tabBar = UIView()
    
    // background view
    let backgroundView: UIImageView = {
        let image = UIImage(named: "wallpaper")
        let imageView = UIImageView(image: image)
        
        let blackOverlay = UIView()
        blackOverlay.backgroundColor = .black
        blackOverlay.alpha = 0.7
        imageView.addSubview(blackOverlay)
        blackOverlay.fillSuperview()
        return imageView
    }()
    
    // locations layout
    let locationsLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        return layout
    }()
    
    // home layout
    var homeLayout = PinterestLayout()
    
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
        page = .home
        homeLayout = self.collectionView.collectionViewLayout as! PinterestLayout
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postcards?.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellId", for: indexPath) as! PinterestCell
        cell.postcard = postcards?[indexPath.item]
        return cell
    }
    
    fileprivate func setupHeader(){
        view.addSubview(PinterestHeader)
        view.addConstraintsWithFormat(format: "H:|[v0]|", views: PinterestHeader)
        view.addConstraintsWithFormat(format: "V:|[v0(100)]", views: PinterestHeader)
        PinterestHeader.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 100)
        
        PinterestHeader.setBackgroundGradient(colorOne: .darkGray, colorTwo: .black)
        PinterestHeader.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 12)
    }
    
    fileprivate func setupTabBar(){
        view.addSubview(tabBar)
        view.addConstraintsWithFormat(format: "H:|[v0]|", views: tabBar)
        view.addConstraintsWithFormat(format: "V:[v0(40)]|", views: tabBar)
        tabBar.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 40)
        
        tabBar.setBackgroundGradient(colorOne: .darkGray, colorTwo: .black)
        tabBar.roundCorners(corners: [.topLeft, .topRight], radius: 12)
        
        let buttonStack = UIStackView(arrangedSubviews: [homeButton, locationButton, favoritesButton])
        buttonStack.distribution = .fillEqually
        tabBar.addSubview(buttonStack)
        buttonStack.fillSuperview()
        
        homeButton.addTarget(self, action: #selector(handleHomeTap), for: .touchUpInside)
        locationButton.addTarget(self, action: #selector(handleLocationTap), for: .touchUpInside)
        favoritesButton.addTarget(self, action: #selector(handleFavoritesTap), for: .touchUpInside)
    }
    
    @objc func handleHomeTap(){
        if page == .home {return}
        homeButton.setImage(UIImage(named: "homeActive"), for: .normal)
        locationButton.setImage(UIImage(named: "location"), for: .normal)
        favoritesButton.setImage(UIImage(named: "favorites"), for: .normal)
        
        collectionView.setCollectionViewLayout(homeLayout, animated: false)
        page = .home
    }
    
    @objc func handleLocationTap(){
        if page == .locations {return}
        locationButton.setImage(UIImage(named: "locationsActive"), for: .normal)
        homeButton.setImage(UIImage(named: "homeInactive"), for: .normal)
        favoritesButton.setImage(UIImage(named: "favorites"), for: .normal)
        
        collectionView.setCollectionViewLayout(locationsLayout, animated: false)
        
        page = .locations
    }
    
    @objc func handleFavoritesTap(){
        if page == .favorites {return}
        favoritesButton.setImage(UIImage(named: "favoritesActive"), for: .normal)
        homeButton.setImage(UIImage(named: "homeInactive"), for: .normal)
        locationButton.setImage(UIImage(named: "location"), for: .normal)
        
        page = .favorites
    }
    
    let homeButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "homeActive")
        button.setImage(image, for: .normal)
        return button
    }()
    
    let locationButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "location")
        button.setImage(image, for: .normal)
        return button
    }()
    
    let favoritesButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "favorites")
        button.setImage(image, for: .normal)
        return button
    }()
    
    
    func printFonts() {
        let fontFamilyNames = UIFont.familyNames
        for familyName in fontFamilyNames {
            print("------------------------------")
            print("Font Family Name = [\(familyName)]")
            let names = UIFont.fontNames(forFamilyName: familyName)
            print("Font Names = [\(names)]")
        }
    }
    
}

// MARK: - Favorites Layout
extension PinterestPage: UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let horizontalPadding: CGFloat = 50
        let verticalPadding: CGFloat = 60
        return CGSize(width: view.frame.width - (2 * horizontalPadding), height: view.frame.height - (PinterestHeader.frame.height + tabBar.frame.height + 2 * verticalPadding))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: PinterestHeader.frame.height, left: 16, bottom: tabBar.frame.height, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
}
