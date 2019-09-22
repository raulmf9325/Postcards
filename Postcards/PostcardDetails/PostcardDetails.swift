//
//  PostcardDetails.swift
//  Postcards
//
//  Created by Raul Mena on 1/29/19.
//  Copyright © 2019 Raul Mena. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class PostcardDetails: UIViewController{
    // database
    let db: Firestore = Firestore.firestore()
    
    // like delegate
    var likeDelegate: LikeDelegate?
    
    // delete delegate
    var deleteDelegate: ModifiedAlbumDelegate!
    
    // remove delegate
    var locationsPage: LocationsPage!
    
    var rootController: RootController!
    
    var pagePostcard: postcard?{
        didSet{
            guard let imageStringURL = pagePostcard?.imageStringURL else {return}
            let imageURL = URL(string: imageStringURL)
            self.postcardImage.sd_setImage(with: imageURL) { (image, error, cache, url) in}
            self.headTitle = pagePostcard?.albumName ?? ""
            self.determineLikeStatus()
        }
    }
    
    // Header
    let Header = UIView()
    
    // Head title
    var headTitle = "The Latest"
    
    // Header Label
    let headerLabel: UILabel = {
        let label = UILabel()
        label.attributedText = NSAttributedString(string: "The Latest")
        label.numberOfLines = 2
        return label
    }()
    
    // header state
    enum HeaderState{
        case visible
        case hidden
    }
    
    // like state
    enum LikeState{
        case like
        case notLike
    }
    
    var likeState: LikeState = .notLike
    
    var headerState: HeaderState = .hidden
    
    override func viewDidLoad() {
        view.backgroundColor = .white
        view.addSubview(postcardImage)
        postcardImage.fillSuperview()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.setupHeader()
        }
    }
    
    private func determineLikeStatus(){
        guard let imageName = pagePostcard?.imageName else {return}
        getFavorites { (dictionary) in
            if dictionary[imageName] != nil{
                self.likeState = .like
                self.likeButton.setImage(UIImage(named: "like"), for: .normal)
            }
        }
    }
    
    private func presentHeader() {
        headerState = .visible
        UIView.animate(withDuration: 0.35) {
            self.Header.frame.origin.y += 100
        }
    }
    
    private func hideHeader(){
        headerState = .hidden
        UIView.animate(withDuration: 0.35) {
            self.Header.frame.origin.y -= 100
        }
    }
    
    func setupHeader(){
        // Label
        let attributedText = NSMutableAttributedString(string: "\(headTitle)\n", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font : UIFont(name: "AvenirNext-Heavy", size: 26)])
        attributedText.append(NSAttributedString(string: "welcome to postcards", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font : UIFont(name: "AvenirNext-Medium", size: 17)]))
        headerLabel.attributedText = attributedText
        
        Header.addSubview(headerLabel)
        Header.addConstraintsWithFormat(format: "H:|-20-[v0]", views: headerLabel)
        Header.addConstraintsWithFormat(format: "V:[v0(60)]-2-|", views: headerLabel)
        view.addSubview(Header)
      
        addBackButton()
        
        addLikeButton()
        
        addTrashButton()
        
        Header.frame = CGRect(x: 0, y: -100, width: view.frame.width, height: 100)
        Header.setBackgroundGradient(colorOne: .darkGray, colorTwo: .black)
        Header.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 12)
        
        presentHeader()
        
        postcardImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapImage)))
    }
    
    @objc private func handleTapImage(){
        if headerState == .hidden{
            presentHeader()
        }
        else{
            hideHeader()
        }
    }
    
    private func addTrashButton(){
//        if pagePostcard?.albumName == "Alaska" || pagePostcard?.albumName == "Camaguey" {return}
        Header.addSubview(trashButton)
        trashButton.rightAnchor == likeButton.leftAnchor - 25
        trashButton.bottomAnchor == likeButton.bottomAnchor
        trashButton.widthAnchor == 25
        trashButton.heightAnchor == 25
        trashButton.addTarget(self, action: #selector(handleTapTrashButton), for: .touchUpInside)
    }
    
    private func addLikeButton(){
        Header.addSubview(likeButton)
        likeButton.rightAnchor == backButton.leftAnchor - 28
        likeButton.bottomAnchor == backButton.bottomAnchor + 1
        likeButton.widthAnchor == 25
        likeButton.heightAnchor == 25
        likeButton.addTarget(self, action: #selector(handleTapLikeButton), for: .touchUpInside)
    }
    
    private func addBackButton(){
        Header.addSubview(backButton)
        Header.addConstraintsWithFormat(format: "H:[v0(20)]-20-|", views: backButton)
        Header.addConstraintsWithFormat(format: "V:[v0(15)]-15-|", views: backButton)
        backButton.addTarget(self, action: #selector(handleTapBackButton), for: .touchUpInside)
    }
    
    @objc private func handleTapTrashButton(){
        let alert = UIAlertController(title: "Are you sure you want to delete the postcard?", message: "The postcard will be permanently deleted", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Delete Postcard", style: .destructive, handler: { (_) in
            guard let postcard = self.pagePostcard else {return}
            self.locationsPage.imageWasDeleted(imageName: postcard.imageName, albumName: postcard.albumName)
            self.deleteDelegate.postcardWasDeleted(postcards: [self.pagePostcard!])
            self.handleTapBackButton()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
            return
        }))
        self.present(alert, animated: true)
    }
    
    @objc private func handleTapLikeButton(){
        if likeState == .notLike{
            likeState = .like
            likeButton.setImage(UIImage(named: "like"), for: .normal)
            registerNewFavorite()
            guard let postcard = pagePostcard else {return}
            likeDelegate?.handleNewLike(postcard: postcard)
            presentAnimation()
        }
        else{
            likeState = .notLike
            likeButton.setImage(UIImage(named: "likeEmpty"), for: .normal)
            removeFavorite()
            guard let postcard = pagePostcard else {return}
            likeDelegate?.removeFavorite(postcard: postcard)
        }
    }
    
    @objc private func handleTapBackButton(){
        self.Header.removeFromSuperview()
        self.rootController.pop(originFrame: nil, animated: true)
    }
    
    // register new favorite
    private func registerNewFavorite(){
        guard let user = Auth.auth().currentUser?.email else {return}
        let doc = db.collection("users").document(user).collection("albums").document("Favorites")
       
        getFavorites { (dictionary) in
            var dictionary = dictionary
            guard let albumName = self.pagePostcard?.albumName else {return}
            guard let imageName = self.pagePostcard?.imageName else {return}
            let path = (albumName == "Alaska" || albumName == "Camaguey") ? "postcards/\(imageName)" : "users/\(user)/\(imageName)"
            let newEntry = ["album": albumName, "name": imageName, "path": path]
            dictionary[imageName] = newEntry
            doc.setData(dictionary)
        }
    }
    
    // remove favorite
    private func removeFavorite(){
        guard let user = Auth.auth().currentUser?.email else {return}
        let doc = db.collection("users").document(user).collection("albums").document("Favorites")
        
        getFavorites { (dictionary) in
            var dictionary = dictionary
            guard let imageName = self.pagePostcard?.imageName else {return}
            dictionary.removeValue(forKey: imageName)
            doc.setData(dictionary)
        }
    }
    
    private func getFavorites(completion: @escaping ([String: [String:String]]) -> ()){
        guard let user = Auth.auth().currentUser?.email else {return}
        let doc = db.collection("users").document(user).collection("albums").document("Favorites")
        doc.getDocument { (snapshot, error) in
            guard let dictionary = snapshot?.data() as? [String: [String:String]] else {return}
            completion(dictionary)
        }
    }
    
    // present animation
    private func presentAnimation(){
        let imageView = UIImageView(image: UIImage(named: "redHeart"))
        view.addSubview(imageView)
        imageView.centerXAnchor == view.centerXAnchor
        imageView.centerYAnchor == view.centerYAnchor
        imageView.widthAnchor == view.widthAnchor - 60
        imageView.heightAnchor == imageView.widthAnchor + 10
        

        imageView.transform = CGAffineTransform(scaleX: 0, y: 0)
        UIView.animate(withDuration: 0.4, animations: {
            imageView.transform = .identity
        }) { (_) in
            UIView.animate(withDuration: 0.4, animations: {
                imageView.alpha = 0
            }, completion: { (_) in
                imageView.removeFromSuperview()
            })
        }
    }
    
    let backButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "backButton")
        button.setImage(image, for: .normal)
        return button
    }()
    
    let likeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "likeEmpty"), for: .normal)
        return button
    }()
    
    let trashButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "garbage"), for: .normal)
        return button
    }()
    
    var postcardImage: UIImageView = {
        let image = UIImage(named: "picture")
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
}
