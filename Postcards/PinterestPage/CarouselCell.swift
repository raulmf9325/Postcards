//
//  CarouselCell.swift
//  Postcards
//
//  Created by Raul Mena on 6/10/19.
//  Copyright © 2019 Raul Mena. All rights reserved.
//

import UIKit

class CarouselCell: UICollectionViewCell{
    
    var imageSet = [UIImageView]()
    var imagesURL: [String]?{
        didSet{
            guard let URLs = imagesURL else {return}
            for url in URLs{
                let imageView = UIImageView(image: nil)
                imageView.backgroundColor = .darkGray
                let imageURL = URL(string: url)
                imageView.sd_setImage(with: imageURL) { (image, error, cache, url) in
                    
                }
                imageSet.append(imageView)
            }
            addImages()
        }
    }
    
    let transformLayer = CATransformLayer()
    var currentAngle: CGFloat = 0
    var currentOffset: CGFloat = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        backgroundColor = .black
        setupPanGesture()
        
        //addImages()
        
        transformLayer.frame = bounds
        layer.addSublayer(transformLayer)
        
        turnCarousel()
    }
    
    fileprivate func addImages(){
        imageSet.forEach { (imageView) in
            if let image = imageView.image{
                addImageCard(image: image)
            }
        }
    }
    
    fileprivate func setupPanGesture(){
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(performPanAction(recognizer:)))
        addGestureRecognizer(panGesture)
    }
    
    @objc func performPanAction(recognizer: UIPanGestureRecognizer){
        
        let xOffset = recognizer.translation(in: self).x
        
        if recognizer.state == .began{
            currentOffset = 0
        }
        
        let xDifference = xOffset * 0.6 - currentOffset
        currentOffset += xDifference
        currentAngle += xDifference
        
        turnCarousel()
    }
    
    fileprivate func addImageCard(image: UIImage){
        
        let imageCardSize = CGSize(width: 200, height: 300)
        
        let imageLayer = CALayer()
        imageLayer.frame = CGRect(x: frame.width / 2 - imageCardSize.width / 2, y: frame.height / 2 - imageCardSize.height / 2, width: imageCardSize.width, height: imageCardSize.height)
        
        imageLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        guard let imageCardImage = image.cgImage else {return}
        
        imageLayer.contents = imageCardImage
        imageLayer.contentsGravity = .resizeAspectFill
        imageLayer.masksToBounds = true
        imageLayer.isDoubleSided = true
        
        imageLayer.borderColor = UIColor(white: 1, alpha: 0.5).cgColor
        imageLayer.borderWidth = 5
        imageLayer.cornerRadius = 10
        
        transformLayer.addSublayer(imageLayer)
        
    }
    
    fileprivate func turnCarousel(){
        
        guard let transformSublayers = transformLayer.sublayers else {return}
        
        let segmentForImageCard = CGFloat (360 / transformSublayers.count)
        
        var angleOffset = currentAngle
        
        for layer in transformSublayers{
            
            var transformMatrix = CATransform3DIdentity
            transformMatrix.m34 = -1 / 500
            
            transformMatrix = CATransform3DRotate(transformMatrix, degreeToRadians(deg: angleOffset), 0, 1, 0)
            transformMatrix = CATransform3DTranslate(transformMatrix, 0, 0, 200)
            
            CATransaction.setAnimationDuration(0)
            
            layer.transform = transformMatrix
            
            angleOffset += segmentForImageCard
        }
        
    }
    
    fileprivate func degreeToRadians(deg: CGFloat) -> CGFloat{
        return (deg * CGFloat.pi) / 180
    }
    
}
