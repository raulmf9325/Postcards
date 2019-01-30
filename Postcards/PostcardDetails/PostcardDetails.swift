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
    
    var rootController: RootController!
    
    var postcard: UIImageView = {
        let image = UIImage(named: "1")
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
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
    
    override func viewDidLoad() {
        view.addSubview(postcard)
        postcard.fillSuperview()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.setupHeader()
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
        
        addBackButton()
        
        view.addSubview(Header)
        Header.frame = CGRect(x: 0, y: -90, width: view.frame.width, height: 90)
        Header.setBackgroundGradient(colorOne: .darkGray, colorTwo: .black)
        Header.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 12)
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.Header.frame.origin.y += 90
        }) { (_) in
            
        }
    }
    
    func addBackButton(){
        Header.addSubview(backButton)
        Header.addConstraintsWithFormat(format: "H:[v0(20)]-20-|", views: backButton)
        Header.addConstraintsWithFormat(format: "V:[v0(20)]-8-|", views: backButton)
        
        backButton.addTarget(self, action: #selector(handleTapBackButton), for: .touchUpInside)
    }
    
    @objc func handleTapBackButton(){
//        UIView.animate(withDuration: 0.2, animations: {
//            self.Header.frame.origin.y -= 90
//        }) { (_) in
            self.Header.removeFromSuperview()
            self.rootController.pop(animated: true)
//        }
    }
    
    let backButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "backButton")
        button.setImage(image, for: .normal)
        return button
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    let cellImage: UIImageView = {
        let image = UIImage(named: "1")
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        return imageView
    }()
    
    
}
