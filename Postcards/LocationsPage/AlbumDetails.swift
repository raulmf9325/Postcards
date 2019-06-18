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
    
//    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        if layoutState == .carousel {return}
//
//        let cell = collectionView.cellForItem(at: indexPath) as! PinterestCell
//        let postcardDetails = PostcardDetails()
//        postcardDetails.pagePostcard = postcards[indexPath.item]
//        postcardDetails.headTitle = headTitle
//
//        let layoutAttributes = collectionView.layoutAttributesForItem(at: indexPath)
//
//        var selectedFrame: CGRect = .zero
//        
//        if let frame = layoutAttributes?.frame{
//            selectedFrame = collectionView.convert(frame, to: collectionView.superview)
//        }
//
//        let rootController = delegate as! RootController
//        postcardDetails.rootController = rootController
//        rootController.pushController(selectedFrame: selectedFrame, vc: postcardDetails)
//    }
    
    func addBackButton(){
        PinterestHeader.addSubview(backButton)
        PinterestHeader.addConstraintsWithFormat(format: "H:[v0(20)]-20-|", views: backButton)
        PinterestHeader.addConstraintsWithFormat(format: "V:[v0(20)]-12-|", views: backButton)
        
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
