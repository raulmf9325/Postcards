//
//  BasePage.swift
//  Postcards
//
//  Created by Raul Mena on 1/24/19.
//  Copyright © 2019 Raul Mena. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseFirestore
import NVActivityIndicatorView

protocol TabBarDelegate{
    func handleTapHome()
    func handleTapLocations()
    func handleTapFavorites()
}

class BasePage: UICollectionViewController{
    
    // MARK: -Properties
    
    // storage reference
    var storage = Storage.storage()
    
    // Firestore reference
    var db = Firestore.firestore()
    
    // tab bar
    let tabBar = UIView()
    
    // TabBar Delegate
    var delegate: TabBarDelegate?
    
    // Head title
    var headTitle = "The Latest"
    
    // head subtitle
    var headSubtitle = "welcome to postcards"
    
    // Header Label
    let headerLabel: UILabel = {
        let label = UILabel()
        label.attributedText = NSAttributedString(string: "The Latest")
        label.numberOfLines = 2
        return label
    }()
    
    // Header
    let PinterestHeader: UIView = {
        let view = UIView()
        return view
    }()

    
    // background view
    let backgroundView = getWallpaper()
    
    // activity indicator
    var activityIndicator: NVActivityIndicatorView!
    
    // activity indicator container
    let activityIndicatorContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    override func viewDidLoad() {
        setupHeader()
        setupTabBar()
    }
    
    // start activity indicator
    func startActivityIndicator(){
        activityIndicator = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 80, height: 80), type: .ballRotateChase, color: .white, padding: 17)
        view.addSubview(activityIndicatorContainer)
        activityIndicatorContainer.centerXAnchor == view.centerXAnchor
        activityIndicatorContainer.centerYAnchor == view.centerYAnchor
        activityIndicatorContainer.widthAnchor == 80
        activityIndicatorContainer.heightAnchor == 80
        
        activityIndicatorContainer.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    // remove activity indicator
    func removeActivityIndicator(){
        activityIndicator.stopAnimating()
        activityIndicatorContainer.removeFromSuperview()
    }
    
    func setHeaderTitle() {
        // Label
        let attributedText = NSMutableAttributedString(string: "\(headTitle)\n", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font : UIFont(name: "AvenirNext-Heavy", size: 26)])
        attributedText.append(NSAttributedString(string: "\(headSubtitle)", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font : UIFont(name: "AvenirNext-Heavy", size: 15)]))
        headerLabel.attributedText = attributedText
    }
    
    func setupHeader(carouselAvailable: Bool = false){
        setHeaderTitle()
        
        PinterestHeader.addSubview(headerLabel)
        PinterestHeader.addConstraintsWithFormat(format: "H:|-20-[v0]", views: headerLabel)
        PinterestHeader.addConstraintsWithFormat(format: "V:[v0(60)]-2-|", views: headerLabel)
        
        if carouselAvailable{
            PinterestHeader.addSubview(cubeButton)
            cubeButton.bottomAnchor == PinterestHeader.bottomAnchor - 1
            cubeButton.rightAnchor == PinterestHeader.rightAnchor - 60
            cubeButton.widthAnchor == 28
            cubeButton.heightAnchor == 28
            cubeButton.addTarget(self, action: #selector(handleCubeTap), for: .touchUpInside)
        }
        
        view.addSubview(PinterestHeader)
        view.addConstraintsWithFormat(format: "H:|[v0]|", views: PinterestHeader)
        view.addConstraintsWithFormat(format: "V:|[v0(100)]", views: PinterestHeader)
        PinterestHeader.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 100)
        
        PinterestHeader.setBackgroundGradient(colorOne: .darkGray, colorTwo: .black)
        PinterestHeader.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 12)
    }
    
    func setupTabBar(){
        view.addSubview(tabBar)
        view.addConstraintsWithFormat(format: "H:|[v0]|", views: tabBar)
        view.addConstraintsWithFormat(format: "V:[v0(50)]|", views: tabBar)
        tabBar.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        tabBar.alpha = 0.80
        
        tabBar.setBackgroundGradient(colorOne: .darkGray, colorTwo: .black)
        tabBar.roundCorners(corners: [.topLeft, .topRight], radius: 12)
        
        let buttonStack = UIStackView(arrangedSubviews: [homeButton, locationButton, favoritesButton])
        buttonStack.distribution = .fillEqually
        buttonStack.alignment = .center
        tabBar.addSubview(buttonStack)
        
        buttonStack.leftAnchor == tabBar.leftAnchor
        buttonStack.rightAnchor == tabBar.rightAnchor
        buttonStack.topAnchor == tabBar.topAnchor
        buttonStack.heightAnchor == tabBar.frame.height - 10
        
        homeButton.addTarget(self, action: #selector(handleHomeTap), for: .touchUpInside)
        locationButton.addTarget(self, action: #selector(handleLocationTap), for: .touchUpInside)
        favoritesButton.addTarget(self, action: #selector(handleFavoritesTap), for: .touchUpInside)
    }
    
    func addPlusButton(){
        PinterestHeader.addSubview(plusButton)
        plusButton.addTarget(self, action: #selector(handleTapPlusButton), for: .touchUpInside)
        
        plusButton.rightAnchor == PinterestHeader.rightAnchor - 25
        plusButton.bottomAnchor == PinterestHeader.bottomAnchor - 8
        plusButton.widthAnchor == 25
        plusButton.heightAnchor == 25
    }
    
    @objc func handleCubeTap(){}
    
    @objc func handleHomeTap(){
        delegate?.handleTapHome()
    }
    
    @objc func handleLocationTap(){
        delegate?.handleTapLocations()
    }
    
    @objc func handleFavoritesTap(){
        delegate?.handleTapFavorites()
    }
    
    @objc func handleTapPlusButton(){}
    
    let cubeButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "cubeGray")
        button.setImage(image, for: .normal)
        return button
    }()
    
    let homeButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "homeActive")
        button.setImage(image, for: .normal)
        return button
    }()
    
    let locationButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "location")
        button.setImage(image, for: .normal)
        return button
    }()
    
    let favoritesButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "favorites")
        button.setImage(image, for: .normal)
        return button
    }()
    
    let plusButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "plus"), for: .normal)
        return button
    }()
}


// global functions

func getWallpaper() -> UIImageView{
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
    
    return backgroundView
}
    
