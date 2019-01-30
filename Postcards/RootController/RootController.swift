//
//  RootController.swift
//  Postcards
//
//  Created by Raul Mena on 1/24/19.
//  Copyright © 2019 Raul Mena. All rights reserved.
//

import UIKit
import Firebase

class RootController: UIViewController{
    
    // MARK: Properties
    
    // postcards
    var snapshot: QuerySnapshot?{
        didSet{
            guard let pinterestPage = self.pinterestPage else {return}
            guard let snapshot = snapshot else {return}
            
            var postcards = [String]()
            
            for document in snapshot.documents{
                guard let data = document.data() as? [String:String] else {
                    print("ERROR!")
                    return
                }
                let names = Array(data.values.map{$0})
                postcards.append(contentsOf: names)
            }
            
            pinterestPage.postcards = postcards
            
            guard let locationsPage = self.locationsPage else {return}
            locationsPage.snapshot = snapshot
        }
        
    }
    
    enum pageState{
        case home
        case locations
        case favorites
    }
    
    //page state
    var page: pageState!
    
    // Pinterest Page
    var pinterestPage: PinterestPage!
    
    // Pinterest Controller View
    var pinterestView: UIView!
    
    // Locations Page
    var locationsPage: LocationsPage!
    
    // Locations Controller View
    var locationsView: UIView!
    
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
    
    // selected frame
    var selectedFrame: CGRect?
    
    override func viewDidLoad() {
        navigationController?.isNavigationBarHidden = true
        navigationController?.delegate = self
        view.addSubview(backgroundView)
        backgroundView.fillSuperview()
        
        pinterestPage = PinterestPage(collectionViewLayout: PinterestLayout())
        pinterestPage.delegate = self
        pinterestView = pinterestPage.view
        
        locationsPage = LocationsPage(collectionViewLayout: UICollectionViewFlowLayout())
        locationsPage.delegate = self
        locationsView = locationsPage.view
        
        view.addSubview(pinterestView)
        view.addSubview(locationsView)
        
        handleTapHome()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
}

extension RootController: TabBarDelegate{
    
    func handleTapHome() {
       view.bringSubviewToFront(pinterestView)
       
    }
    
    func handleTapLocations() {
        view.bringSubviewToFront(locationsView)
    }
    
    func handleTapFavorites() {
        
    }
    
    
}

extension RootController: UINavigationControllerDelegate{
    
    func pushController(selectedFrame: CGRect, vc: UIViewController){
        self.selectedFrame = selectedFrame
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func pop(animated: Bool){
        navigationController?.popViewController(animated: animated)
    }
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        guard let frame = selectedFrame else {return nil}
        
        switch operation{
        case .push:
            return TransitionAnimator(duration: 0.5, isPresenting: true, originFrame: frame)
        default:
            return TransitionAnimator(duration: 0.5, isPresenting: false, originFrame: frame)
        }
    }

}
