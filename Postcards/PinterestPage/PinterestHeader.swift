//
//  PinterestHeader.swift
//  Postcards
//
//  Created by Raul Mena on 1/18/19.
//  Copyright © 2019 Raul Mena. All rights reserved.
//

import UIKit

let PinterestHeader: UIView = {
    let view = UIView()
    
    // Label
    let label = UILabel()
    let attributedText = NSMutableAttributedString(string: "The Latest\n", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font : UIFont(name: "AvenirNext-Heavy", size: 26)])
    attributedText.append(NSAttributedString(string: "welcome to postcards", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font : UIFont(name: "AvenirNext-Medium", size: 17)]))
    
    label.attributedText = attributedText
    label.numberOfLines = 2
    
    view.addSubview(label)
    view.addConstraintsWithFormat(format: "H:|-20-[v0]", views: label)
    view.addConstraintsWithFormat(format: "V:[v0(60)]-2-|", views: label)
    
    return view
}()

