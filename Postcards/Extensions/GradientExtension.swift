//
//  GradientExtension.swift
//  Postcards
//
//  Created by Raul Mena on 1/20/19.
//  Copyright © 2019 Raul Mena. All rights reserved.
//

import UIKit

extension UIView{
    
    func setBackgroundGradient(colorOne: UIColor, colorTwo: UIColor){
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [colorOne.cgColor, colorTwo.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        
        layer.insertSublayer(gradientLayer, at: 0)
    }
}
