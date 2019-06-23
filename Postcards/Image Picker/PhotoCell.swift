//
//  PhotoCell.swift
//  Postcards
//
//  Created by Raul Mena on 6/23/19.
//  Copyright © 2019 Raul Mena. All rights reserved.
//

import UIKit
import Photos

let photosCache = NSCache<PHAsset, UIImage>()

class PhotoCell: UICollectionViewCell{
    
    var asset: PHAsset?{
        didSet{
           guard let asset = asset else {return}
//            if let cachedImage = photosCache.object(forKey: asset){
//                self.photo.image = cachedImage
//            }
//            else{
//                let options = PHImageRequestOptions()
//                options.version = .original
//                PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 500, height: 500), contentMode: .aspectFit, options: options) { (image, _) in
//                    guard let image = image else {return}
//                    photosCache.setObject(image, forKey: asset)
//                    self.photo.image = image
//                }
                photo.fetchImage(asset: asset, contentMode: .aspectFit, targetSize: CGSize(width: 500, height: 500))
            
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews(){
        addSubview(photo)
        photo.widthAnchor == widthAnchor
        photo.heightAnchor == heightAnchor
    }
    
    let photo: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "picture"))
        imageView.backgroundColor = .lightGray
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
}
