//
//  PinterestCell.swift
//  Postcards
//
//  Created by Raul Mena on 1/18/19.
//  Copyright © 2019 Raul Mena. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseUI

class PinterestCell: UICollectionViewCell{
    var albumName: String?
    var postcard: String?{
        didSet{
            guard let postcard = postcard else{return}
            // reference to storage
            let storageRef = Storage.storage().reference()
            
            // Reference to an image file in Firebase Storage
            let reference = storageRef.child("postcards/\(postcard)")
            var imageURL: URL?
           
            reference.downloadURL { (url, error) in
                imageURL = url
                self.cellImage.sd_setImage(with: imageURL) { (image, error, cache, url) in
                    if let error = error{
                        print("ERROR!: \(error)")
                        return
                    }
                    self.addSubview(self.cellImage)
                    self.cellImage.fillSuperview()
                    self.imagePlaceholder.stopAnimating()
                }
            }
        }
    }
    
    let imagePlaceholder = GradientView()
    
    let cellImage: UIImageView = {
        let image = UIImage(named: "1")
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    fileprivate func setupViews(){
        // image placeholder
        addSubview(imagePlaceholder)
        imagePlaceholder.fillSuperview()
        imagePlaceholder.frame = self.bounds
        imagePlaceholder.startAnimating()
    }
    
    deinit {}
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
