//
//  FavoritesPage.swift
//  Postcards
//
//  Created by Raul Mena on 6/15/19.
//  Copyright © 2019 Raul Mena. All rights reserved.
//

import UIKit


class FavoritesPage: PinterestPage{
    
    override func viewDidLoad() {
        navigationController?.isNavigationBarHidden = true
        collectionView.register(PinterestCell.self, forCellWithReuseIdentifier: "CellId")
        collectionView.register(CarouselCell.self, forCellWithReuseIdentifier: "CarouselCell")
        collectionView.backgroundView = backgroundView
        
        headTitle = "Hearted Stuff"
        setupHeader(carouselAvailable: true)
        homeButton.setImage(UIImage(named: "homeInactive"), for: .normal)
        locationButton.setImage(UIImage(named: "location"), for: .normal)
        favoritesButton.setImage(UIImage(named: "favoritesActive"), for: .normal)
        setupTabBar()
        
        startActivityIndicator()
    }
}

protocol LikeDelegate{
    func handleNewLike(postcard: postcard)
}

extension FavoritesPage: LikeDelegate{
    func handleNewLike(postcard: postcard) {
        self.postcards.append(postcard)
        self.collectionView.reloadData()
    }
}
