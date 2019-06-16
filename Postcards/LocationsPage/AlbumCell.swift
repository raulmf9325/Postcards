//
//  AlbumCell.swift
//  Postcards
//
//  Created by Raul Mena on 1/26/19.
//  Copyright © 2019 Raul Mena. All rights reserved.
//

import UIKit
import Firebase

class AlbumCell: UICollectionViewCell{
    
    var album: Album?{
        didSet{
            guard let album = album, let stringURL = album.postcards?[0].imageStringURL, let albumName = album.name else {return}
        
            let imageURL = URL(string: stringURL)
            albumImageView.sd_setImage(with: imageURL) { (image, error, cache, url) in
                if  error != nil {return}
                self.addSubview(self.albumImageView)
                self.albumImageView.fillSuperview()
                    
                let attributedText = NSMutableAttributedString(string: "\(albumName)\n", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font : UIFont(name: "AvenirNext-Heavy", size: 26)])
                    attributedText.append(NSAttributedString(string: "\(album.postcards?.count ?? 0) images", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font : UIFont(name: "AvenirNext-Heavy", size: 17)]))
                    
                self.albumNameLabel.attributedText = attributedText
                self.addSubview(self.albumNameLabel)
                self.addConstraintsWithFormat(format: "H:|-16-[v0]|", views: self.albumNameLabel)
                self.addConstraintsWithFormat(format: "V:[v0(60)]-8-|", views: self.albumNameLabel)
                self.imagePlaceholder.stopAnimating()
                }
            }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupViews(){
        addSubview(imagePlaceholder)
        imagePlaceholder.fillSuperview()
        imagePlaceholder.frame = self.bounds
        imagePlaceholder.startAnimating()
    }
    
    let imagePlaceholder = GradientView()
    
    let albumImageView: UIImageView = {
        let image = UIImage(named: "home")
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    let albumNameLabel: UILabel = {
        let label = UILabel()
        
        let attributedText = NSMutableAttributedString(string: "Album\n", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font : UIFont(name: "AvenirNext-Heavy", size: 26)])
        attributedText.append(NSAttributedString(string: "12 images", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font : UIFont(name: "AvenirNext-Heavy", size: 17)]))
        
        label.attributedText = attributedText
        label.numberOfLines = 2
        
        return label
    }()
    
}
