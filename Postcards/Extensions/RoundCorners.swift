//
//  RoundCorners.swift
//  Postcards
//
//  Created by Raul Mena on 1/20/19.
//  Copyright © 2019 Raul Mena. All rights reserved.
//

import UIKit

extension UIView{
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
}
