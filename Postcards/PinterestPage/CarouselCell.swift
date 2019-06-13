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
    var imagesURL: [String]?{
        didSet{
            guard let URLs = imagesURL else {return}
            for (i, url) in URLs.enumerated(){
                let imageView = imageSet[i]
                let imageURL = URL(string: url)
                imageView.sd_setImage(with: imageURL) { (image, error, cache, url) in
                    self.imagesDownloaded += 1
                    
                    if self.imagesDownloaded == URLs.count{
                        guard var layers = self.transformLayer.sublayers else {return}
                        for(i, layer) in layers.enumerated(){
                            layer.contents = self.imageSet[i].image?.cgImage
                        }
                        for i in URLs.count ..< 6{
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
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        backgroundColor = .white
  //      setupPanGesture()
        transformLayer.frame = CGRect(x: (frame.width / 2) - (frame.width - 40) / 2, y: 20, width: frame.width - 40, height: frame.height - 40)
        layer.addSublayer(self.transformLayer)
       
        let timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
            self.currentAngle += 0.1
            self.turnCarousel()
        }
    }
    
    func addImages(){
        for i in 0 ..< 6{
            imageSet.append(UIImageView(image: UIImage(named: "picture")))
            addImageCard(imageView: imageSet[i])
        }
        
        turnCarousel()
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
    
    fileprivate func addImageCard(imageView: UIImageView?){
        let imageLayer = CALayer()
        imageLayer.frame = CGRect(x: (frame.width / 2 - 50), y: (transformLayer.bounds.height / 2 - 50), width: 100, height: 100)
        
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
