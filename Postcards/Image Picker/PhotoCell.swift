//
//  PhotoCell.swift
//  Postcards
//
//  Created by Raul Mena on 6/23/19.
//  Copyright © 2019 Raul Mena. All rights reserved.
//

import UIKit
import Photos

class PhotoCell: UICollectionViewCell{
    
    var asset: PHAsset?{
        didSet{
           guard let asset = asset else {return}
           photo.fetchImage(asset: asset, contentMode: .aspectFit, targetSize: CGSize(width: 300, height: 300))
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
    
    func cellWasSelected(){
        addSubview(whiteOverlay)
        whiteOverlay.widthAnchor == widthAnchor
        whiteOverlay.heightAnchor == heightAnchor
        
        addSubview(checkMark)
        checkMark.topAnchor == topAnchor + 8
        checkMark.leftAnchor == leftAnchor + 8
        checkMark.widthAnchor == 25
        checkMark.heightAnchor == 25
    }
    
    func cellWasDeselected(){
        [checkMark, whiteOverlay].forEach{$0.removeFromSuperview()}
    }
    
    let checkMark: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "checkmark"))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let whiteOverlay: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 1, alpha: 0.2)
        return view
    }()
    
    let photo: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "picture"))
        imageView.backgroundColor = .lightGray
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
}
