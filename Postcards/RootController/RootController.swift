//
//  RootController.swift
//  Postcards
//
//  Created by Raul Mena on 1/24/19.
//  Copyright © 2019 Raul Mena. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseUI
import NVActivityIndicatorView

class RootController: UIViewController{
    // database
    var db: Firestore?
    
    enum pageState{
        case home
        case locations
        case favorites
    }
    
    let defaults = UserDefaults.standard
    
    //page state
    var page: pageState!
    
    // Pinterest Page
    var pinterestPage = PinterestPage(collectionViewLayout: PinterestLayout(topInset: 110))
    
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
    
    // collapse animation
    var collapseAnimation = false
    
    // activity indicator
    var activityIndicator: NVActivityIndicatorView!
    
    // activity indicator container
    let activityIndicatorContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
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
        checkAuthenticationStatus()
    }
    
    private func proceedToMainPage(){
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
        
        startActivityIndicator()
    }
    
    private func startActivityIndicator(){
        activityIndicator = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 80, height: 80), type: .ballRotateChase, color: .white, padding: 17)
        view.addSubview(activityIndicatorContainer)
        activityIndicatorContainer.centerXAnchor == view.centerXAnchor
        activityIndicatorContainer.centerYAnchor == view.centerYAnchor
        activityIndicatorContainer.widthAnchor == 80
        activityIndicatorContainer.heightAnchor == 80
        
        activityIndicatorContainer.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    private func removeActivityIndicator(){
        
    }
    
    private func checkAuthenticationStatus(){
        let userIsLoggedin = defaults.bool(forKey: "auth")
        if userIsLoggedin{
            proceedToMainPage()
        }
        else{
            presentWelcomePage()
        }
    }
    
    private func presentWelcomePage(){
        let welcomePage = WelcomePage()
        welcomePage.delegate = self
        navigationController?.pushViewController(welcomePage, animated: false)
    }
    
    func handleSignUpFinished(){
        
    }
    
    // fetch albums
    private func fetchAlbums(completion: @escaping (QuerySnapshot) -> ()) {
        db = Firestore.firestore()
        guard let db = db else {return}
        
        db.collection("postcards").getDocuments { (snapshot, error) in
            if error != nil {return}
            guard let snapshot = snapshot else {return}
            completion(snapshot)
        }
    }
    
    private func didFinishFetchingContent(snapshot: QuerySnapshot){
        var albums = [Album]()
        
        for album in snapshot.documents{
            guard let data = album.data() as? [String:String] else {return}
            let images = Array(data.values.map{$0})
            let newAlbum = Album(name: album.documentID, images: images)
            albums.append(newAlbum)
        }
        
        let storageRef = Storage.storage().reference()
        var urlsDownloaded = 0
        var totalNumberOfImageURL = 0
        let map = albums.map { (album) -> Int in
            return album.images?.count ?? 0
        }
        
        map.forEach { (set) in
            totalNumberOfImageURL += set
        }
        
        for (i, album) in albums.enumerated(){
            let numberOfImagesInAlbum = album.images?.count ?? 0
            var urlsDownloadedInAlbum = 0
            if var images = albums[i].images{
                for (j, imageString) in images.enumerated(){
                    let reference = storageRef.child("postcards/\(imageString)")
                    reference.downloadURL { (url, error) in
                        urlsDownloadedInAlbum += 1
                        urlsDownloaded += 1
                        if error == nil{
                            images[j] = url?.absoluteString ?? ""
                        }
                        if urlsDownloadedInAlbum == numberOfImagesInAlbum{
                            albums[i].images = images
                        }
                        if urlsDownloaded == totalNumberOfImageURL{
                            UIView.animate(withDuration: 0.3, animations: {
                                self.activityIndicator.alpha = 0
                            }, completion: { (_) in
                                self.activityIndicator.stopAnimating()
                                self.activityIndicatorContainer.removeFromSuperview()
                                self.pinterestPage.albums = albums
                                self.locationsPage.albums = albums
                            })
                        }
                    }
                }
            }
        }
  
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

extension RootController: AuthenticationDelegate{
    func handleLoginWasSuccessful() {
        defaults.set(true, forKey: "auth")
        navigationController?.popToRootViewController(animated: false)
        proceedToMainPage()
    }
}

extension RootController: UINavigationControllerDelegate{
    
    func pushController(selectedFrame: CGRect, vc: UIViewController){
        self.selectedFrame = selectedFrame
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func pop(originFrame: CGRect?, animated: Bool, collapse: Bool = false){
        if originFrame != nil{
            self.selectedFrame = originFrame!
        }
        self.collapseAnimation = collapse
        navigationController?.popViewController(animated: animated)
    }
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        guard let frame = selectedFrame else {return nil}
        
        switch operation{
        case .push:
            return TransitionAnimator(duration: 0.5, isPresenting: true, originFrame: frame)
        default:
            return TransitionAnimator(duration: collapseAnimation ? 1: 0.6, isPresenting: false, originFrame: frame)
        }
    }

}
