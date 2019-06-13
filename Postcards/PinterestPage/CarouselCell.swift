//
//  CarouselCell.swift
//  Postcards
//
//  Created by Raul Mena on 6/10/19.
//  Copyright © 2019 Raul Mena. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class CarouselCell: UICollectionViewCell{
    
    var imageSet = [UIImageView]()
    var postcards: [postcard]?{
        didSet{
            guard let postcards = postcards else {return}
            for (i, postcard) in postcards.enumerated(){
                let imageView = imageSet[i]
                let imageURL = URL(string: postcard.imageStringURL)
                imageView.sd_setImage(with: imageURL) { (image, error, cache, url) in
                    self.imagesDownloaded += 1
                    
                    if self.imagesDownloaded == postcards.count{
                        guard var layers = self.transformLayer.sublayers else {return}
                        for(i, layer) in layers.enumerated(){
                            layer.contents = self.imageSet[i].image?.cgImage
                        }
                        for i in postcards.count ..< 6{
                            layers[i].removeFromSuperlayer()
                        }
                    }
                }
                
            }
        }
    }
    
    var imagesDownloaded = 0
    
    let transformLayer = CATransformLayer()
    var currentAngle: CGFloat = 0
    var currentOffset: CGFloat = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        currentAngle = CGFloat.random(in: 0 ... 360)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
       // backgroundColor = .white
 
        transformLayer.frame = CGRect(x: (frame.width / 2) - (frame.width - 40) / 2, y: 20, width: frame.width - 40, height: frame.height - 40)
        layer.addSublayer(self.transformLayer)
    
        let timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
            self.currentAngle += 0.1
            self.turnCarousel()
        }
    }
    
    func addImages(){
        for i in 0 ..< 6{
            let imageView = UIImageView(image: UIImage(named: "picture"))
            imageView.isUserInteractionEnabled = true
            imageSet.append(imageView)
            addImageCard(imageView: imageSet[i])
        }
        
        turnCarousel()
    }
    
    fileprivate func addImageCard(imageView: UIImageView?){
        let imageLayer = CALayer()
        imageLayer.frame = CGRect(x: (frame.width / 2 - 60), y: (transformLayer.bounds.height / 2 - 65), width: 120, height: 130)
        
        imageLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        imageLayer.contents = imageView?.image?.cgImage
        imageLayer.contentsGravity = .resizeAspectFill
        imageLayer.masksToBounds = true
        imageLayer.isDoubleSided = true
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
    
    func removeLayers(){
        transformLayer.sublayers?.forEach({ (layer) in
            layer.removeFromSuperlayer()
        })
        imageSet = [UIImageView]()
        imagesDownloaded = 0
    }
    
    fileprivate func degreeToRadians(deg: CGFloat) -> CGFloat{
        return (deg * CGFloat.pi) / 180
    }
    
}
