//
//  AlbumDetails.swift
//  Postcards
//
//  Created by Raul Mena on 1/26/19.
//  Copyright © 2019 Raul Mena. All rights reserved.
//

import UIKit

class AlbumDetails: PinterestPage{
    
    override func viewDidLoad() {
        navigationController?.isNavigationBarHidden = true
        collectionView.register(PinterestCell.self, forCellWithReuseIdentifier: "CellId")
        collectionView.backgroundView = backgroundView
        setupHeader()
        addBackButton()
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! PinterestCell
        let postcardDetails = PostcardDetails()
        postcardDetails.postcard.image = cell.cellImage.image
        postcardDetails.headTitle = headTitle
        
        let layoutAttributes = collectionView.layoutAttributesForItem(at: indexPath)
        
        var selectedFrame: CGRect = .zero
        
        if let frame = layoutAttributes?.frame{
            selectedFrame = collectionView.convert(frame, to: collectionView.superview)
        }
        
        let rootController = delegate as! RootController
        postcardDetails.rootController = rootController
        rootController.pushController(selectedFrame: selectedFrame, vc: postcardDetails)
    }
    
    func addBackButton(){
        PinterestHeader.addSubview(backButton)
        PinterestHeader.addConstraintsWithFormat(format: "H:[v0(20)]-20-|", views: backButton)
        PinterestHeader.addConstraintsWithFormat(format: "V:[v0(20)]-8-|", views: backButton)
        
        backButton.addTarget(self, action: #selector(handleTapBackButton), for: .touchUpInside)
    }
    
    @objc func handleTapBackButton(){
        let rootController = delegate as! RootController
        rootController.pop(animated: true)
    }
    
    let backButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "backButton")
        button.setImage(image, for: .normal)
        return button
    }()
    
}
