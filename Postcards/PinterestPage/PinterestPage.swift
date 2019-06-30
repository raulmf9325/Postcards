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
    var imageName: String       // for cloud storage reference
}

class PinterestPage: BasePage{
    /*
        Pinterest Page is used for both, the entry page with all albums
        and for album details. Therefore, it can have either 'albums' or 'album' (but not both)
     */
    
    // postcards
    var albums: [Album]?{
        didSet{
            guard let albums = albums else {return}
            
            albums.forEach { (album) in
                self.postcards.append(contentsOf: album.postcards ?? [])
            }
            collectionView.reloadData()
        }
    }
    
    var album: Album?{
        didSet{
            guard let postcards = album?.postcards else {return}
            self.postcards = postcards
            let count = postcards.count
            headSubtitle = "\(count) postcards"
            setHeaderTitle()
            collectionView.reloadData()
        }
    }
    
    var postcards = [postcard]()
    
    enum layout{
        case pinterest
        case carousel
    }
    
    var layoutState: layout = .pinterest
    
    var topInset: CGFloat = 110
    
    override func viewDidLoad() {
        navigationController?.isNavigationBarHidden = true
        collectionView.register(PinterestCell.self, forCellWithReuseIdentifier: "CellId")
        collectionView.register(CarouselCell.self, forCellWithReuseIdentifier: "CarouselCell")
        collectionView.backgroundView = backgroundView
        setupHeader(carouselAvailable: true)
        setupTabBar()
        startActivityIndicator()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if layoutState == .carousel{
            let count = CGFloat(postcards.count)
            let ceiling = ceil(count / CGFloat(6))
            return Int(ceiling)
        }
        else{
            return postcards.count
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if layoutState == .carousel{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CarouselCell", for: indexPath) as! CarouselCell
            
            cell.removeLayers()
            cell.addImages()
            let carouselPostcards = postcardsForCarousellCellAt(indexPath: indexPath)
            cell.postcards = carouselPostcards
            return cell
        }
        else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellId", for: indexPath) as! PinterestCell
            cell.postcard = postcards[indexPath.item].imageStringURL
            cell.albumName = postcards[indexPath.item].albumName
            return cell
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if layoutState == .carousel {return}
        
        let cell = collectionView.cellForItem(at: indexPath) as! PinterestCell
        let postcardDetails = PostcardDetails()
        postcardDetails.pagePostcard = postcards[indexPath.item]
        let rootController = delegate as! RootController
        postcardDetails.rootController = rootController
        postcardDetails.likeDelegate = rootController.favoritesPage
        postcardDetails.locationsPage = rootController.locationsPage
        
        let layoutAttributes = collectionView.layoutAttributesForItem(at: indexPath)
       
        var selectedFrame: CGRect = .zero
        
        if let frame = layoutAttributes?.frame{
            selectedFrame = collectionView.convert(frame, to: collectionView.superview)
        }

        rootController.pushController(selectedFrame: selectedFrame, vc: postcardDetails)
    }
    
    func postcardsForCarousellCellAt(indexPath: IndexPath) -> [postcard]{
        
        var postcardsForCell = [postcard]()
        var index = indexPath.item * 6
        let endIndex = index + 6
        while(index < endIndex && index < postcards.count){
            postcardsForCell.append(postcards[index])
            index += 1
        }
        
        return postcardsForCell
    }
    
    override func handleCubeTap() {
        if layoutState == .pinterest{
            cubeButton.setImage(UIImage(named: "cubeWhite"), for: .normal)
            layoutState = .carousel
            collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        }
        else{
            cubeButton.setImage(UIImage(named: "cubeGray"), for: .normal)
            layoutState = .pinterest
            collectionView.setCollectionViewLayout(PinterestLayout(topInset: topInset), animated: false)
        }
        
        collectionView.reloadData()
        if collectionView.numberOfItems(inSection: 0) > 0{
            collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .bottom, animated: false)
        }
    }
}


extension PinterestPage: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = view.frame.width
        let height: CGFloat = (view.frame.height - (230)) / 2
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 120, left: 0, bottom: 90, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 50
    }
    
}
