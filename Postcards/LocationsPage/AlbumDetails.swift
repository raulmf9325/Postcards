//
//  AlbumDetails.swift
//  Postcards
//
//  Created by Raul Mena on 1/26/19.
//  Copyright © 2019 Raul Mena. All rights reserved.
//

import UIKit

class AlbumDetails: PinterestPage{
    
    override var topInset: CGFloat {
        get{
            return 70
        }
        set {}
    }
    
    override func viewDidLoad() {
        navigationController?.isNavigationBarHidden = true
        collectionView.register(PinterestCell.self, forCellWithReuseIdentifier: "CellId")
        collectionView.register(CarouselCell.self, forCellWithReuseIdentifier: "CarouselCell")
        collectionView.backgroundView = backgroundView
        setupHeader(carouselAvailable: true)
        addBackButton()
    }
        
    func addBackButton(){
        PinterestHeader.addSubview(backButton)
        PinterestHeader.addConstraintsWithFormat(format: "H:[v0(20)]-25-|", views: backButton)
        PinterestHeader.addConstraintsWithFormat(format: "V:[v0(15)]-16-|", views: backButton)
        
        backButton.addTarget(self, action: #selector(handleTapBackButton), for: .touchUpInside)
    }
    
    @objc func handleTapBackButton(){
        let rootController = delegate as! RootController
        rootController.pop(originFrame: CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: view.frame.height), animated: true, collapse: true)
    }
    
    let backButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "backButton")
        button.setImage(image, for: .normal)
        return button
    }()
    
}
