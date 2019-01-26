//
//  AlbumDetails.swift
//  Postcards
//
//  Created by Raul Mena on 1/26/19.
//  Copyright © 2019 Raul Mena. All rights reserved.
//

import UIKit

class AlbumDetails: BasePage{
    
    // MARK: -Properties
    
    // postcards
    var postcards: [String]?{
        didSet{
            self.collectionView.reloadData()
        }
    }
    
    
    
}
