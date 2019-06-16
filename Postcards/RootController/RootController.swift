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

class RootController: UIViewController{
    // database
    let db: Firestore = Firestore.firestore()
    
    // storage reference
    let storageRef = Storage.storage().reference()
    
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
    
    // favorites page
    var favoritesPage = FavoritesPage(collectionViewLayout: PinterestLayout(topInset: 110))
    
    // favorites controller view
    var favoritesView: UIView!
    
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
        
        favoritesPage.delegate = self
        favoritesView = favoritesPage.view
        
        view.addSubview(pinterestView)
        view.addSubview(locationsView)
        view.addSubview(favoritesView)
        
        handleTapHome()
        
        fetchAlbums()
        
        fetchFavorites { (postcards) in
            
        }
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
    
    // fetch default albums
    private func fetchDefaultAlbums(_ completion: @escaping (QuerySnapshot) -> ()) {
        db.collection("postcards").getDocuments { (snapshot, error) in
            if error != nil {return}
            guard let snapshot = snapshot else {return}
            completion(snapshot)
        }
    }
    
    // fetch user albums
    private func fetchUserAlbums(_ completion: @escaping (QuerySnapshot) -> ()){
        guard let user = Auth.auth().currentUser?.email else {return}
        let albumsCollection = db.collection("users").document(user).collection("albums")
        albumsCollection.getDocuments { (snapshot, error) in
            if error != nil {return}
            guard let snapshot = snapshot else {return}
            completion(snapshot)
        }
    }
    
    // parse snapshot
    private func parseSnapshot(snapshot: QuerySnapshot, storageDirectory: String) -> [Album]{
        var albums = [Album]()
        
        for album in snapshot.documents{
            if album.documentID == "Favorites" {continue}
            guard let data = album.data() as? [String:String] else {return []}
            
            let albumName = album.documentID
            let imagesNames = Array(data.values.map{$0})
            var postcards = [postcard]()
            
            imagesNames.forEach({ (imageName) in
                postcards.append(postcard(albumName: albumName, imageStringURL: "", imageName: imageName))
            })
            
            let newAlbum = Album(name: albumName, storageDirectory: storageDirectory, postcards: postcards)
            albums.append(newAlbum)
        }
        
        return albums
    }
    
    // fetch all albums
    private func fetchAlbums() {
        var allAlbums = [Album]()
        var didFinishFetchingDefaultAlbums = false
        var didFinishFetchingUserAlbums = false
        
        // default albums
        fetchDefaultAlbums { (snapshot) in
            didFinishFetchingDefaultAlbums = true
           
            let defaultAlbums = self.parseSnapshot(snapshot: snapshot, storageDirectory: "postcards")
            allAlbums.append(contentsOf: defaultAlbums)
            
            if didFinishFetchingUserAlbums{
                self.downloadImagesURLForAlbums(albums: allAlbums)
            }
        }
        
        // user albums
        fetchUserAlbums { (snapshot) in
            didFinishFetchingUserAlbums = true
            
            guard let user = Auth.auth().currentUser?.email else {return}
            let rootDirectory = "users" + "/" + user
            let userAlbums = self.parseSnapshot(snapshot: snapshot, storageDirectory: rootDirectory)
            allAlbums.append(contentsOf: userAlbums)
        }
        
        if didFinishFetchingDefaultAlbums{
            self.downloadImagesURLForAlbums(albums: allAlbums)
        }
    }
    
    
    
    private func downloadImagesURLForAlbums(albums: [Album]){
        var albums = albums
        var urlsDownloaded = 0
        var totalNumberOfImageURL = 0
        
        let map = albums.map { (album) -> Int in
            return album.postcards?.count ?? 0
        }
        
        map.forEach { (set) in
            totalNumberOfImageURL += set
        }
        
        for (i, album) in albums.enumerated(){
            let numberOfImagesInAlbum = album.postcards?.count ?? 0
            var urlsDownloadedInAlbum = 0
            
            if var postcards = albums[i].postcards, let rootDirectory = albums[i].storageDirectory{
                
                for (j, postcard) in postcards.enumerated(){
                    let reference = storageRef.child("\(rootDirectory)/\(postcard.imageName)")
                    reference.downloadURL { (url, error) in
                        urlsDownloadedInAlbum += 1
                        urlsDownloaded += 1
                       
                        if error == nil{
                           postcards[j].imageStringURL = url?.absoluteString ?? ""
                        }
                        
                        if urlsDownloadedInAlbum == numberOfImagesInAlbum{
                            albums[i].postcards = postcards
                        }
                        
                        if urlsDownloaded == totalNumberOfImageURL{
                            self.pinterestPage.albums = albums
                            self.locationsPage.albums = albums
                            self.pinterestPage.removeActivityIndicator()
                            self.locationsPage.removeActivityIndicator()
                        }
                    }
                
                }
            }
        }
    }
    
  //   fetch favorites
    private func fetchFavorites(completion: @escaping ([postcard]) -> ()){
        guard let user = Auth.auth().currentUser?.email else {return}

        let favoritesDocument = db.collection("users").document(user).collection("albums").document("Favorites")
        
        favoritesDocument.getDocument { (snapshot, error) in
            if error != nil {return}
            guard let snapshot = snapshot else {return}
            guard let data = snapshot.data() as? [String:[String:String]] else {return}

            let favorites = Array(data.values.map{$0})
            var postcards = [postcard]()

            favorites.forEach({ (favorite) in
                guard let albumName = favorite["album"] else {return}
                guard let imageName = favorite["name"] else {return}
                guard let imageStringURL = favorite["path"] else {return}
                postcards.append(postcard(albumName: albumName, imageStringURL: imageStringURL, imageName: imageName))
            })
            
            var urlsDownloaded = 0
            
            for (i, postcard) in postcards.enumerated(){
                let reference = self.storageRef.child(postcard.imageStringURL)
                reference.downloadURL(completion: { (url, error) in
                    urlsDownloaded += 1
                    
                    if let url = url?.absoluteString{
                        postcards[i].imageStringURL = url
                    }
                    
                    if urlsDownloaded == postcards.count{
                        self.favoritesPage.postcards = postcards
                        self.favoritesPage.collectionView.reloadData()
                        self.favoritesPage.removeActivityIndicator()
                    }
                })
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
        view.bringSubviewToFront(favoritesView)
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
