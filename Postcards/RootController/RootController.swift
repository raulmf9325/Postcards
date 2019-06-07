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
    // database
    var db: Firestore?
    
    enum pageState{
        case home
        case locations
        case favorites
    }
    
    //page state
    var page: pageState!
    
    // Pinterest Page
    var pinterestPage = PinterestPage(collectionViewLayout: PinterestLayout())
    
    // Pinterest Controller View
    var pinterestView: UIView!
    
    // Locations Page
    var locationsPage = LocationsPage(collectionViewLayout: UICollectionViewFlowLayout())
    
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
    
    init(){
        super.init(nibName: nil, bundle: nil)
        fetchAlbums { (snapshot) in
            self.didFinishFetchingContent(snapshot: snapshot)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        navigationController?.isNavigationBarHidden = true
        navigationController?.delegate = self
        view.addSubview(backgroundView)
        backgroundView.fillSuperview()
        
        pinterestPage.delegate = self
        pinterestView = pinterestPage.view
        
        locationsPage.delegate = self
        locationsView = locationsPage.view
        
        view.addSubview(pinterestView)
        view.addSubview(locationsView)
        
        handleTapHome()
    }
    
    // fetch albums
    private func fetchAlbums(completion: @escaping (QuerySnapshot) -> ()) {
        db = Firestore.firestore()
        guard let db = db else {return}
        
        db.collection("postcards").getDocuments { (snapshot, error) in
            if let error = error{
                print("ERROR!: \(error)")
                return
            }
            guard let snapshot = snapshot else {return}
            completion(snapshot)
        }
    }
    
    private func didFinishFetchingContent(snapshot: QuerySnapshot){
        var albums = [Album]()
        var grandAlbum = Album(name: "The Latest", images: [String]())
        
        for album in snapshot.documents{
            guard let data = album.data() as? [String:String] else {return}
            var images = Array(data.values.map{$0})
            grandAlbum.images?.append(contentsOf: images)
            let newAlbum = Album(name: album.documentID, images: images)
            albums.append(newAlbum)
        }
        pinterestPage.album = grandAlbum
        locationsPage.albums = albums
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
    
    func pop(originFrame: CGRect?, animated: Bool){
        if originFrame != nil{
            self.selectedFrame = originFrame!
        }
        
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
