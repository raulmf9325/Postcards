//
//  PinterestLayout.swift
//  PinterestLayout
//
//  Created by Raul Mena on 1/13/19.
//  Copyright © 2019 Raul Mena. All rights reserved.
//

import UIKit

class PinterestLayout: UICollectionViewFlowLayout{
    
    // 1
    let cellHeights: [CGFloat] = [200,240,200,80,80,180,200,200,80,200,120,180]
    
    // 2
    fileprivate var numberOfColumns = 3
    fileprivate var cellPadding: CGFloat = 6
    fileprivate var insets: UIEdgeInsets = UIEdgeInsets(top: 110, left: 0, bottom: 50, right: 0)
    
    // 3
    fileprivate var cache = [UICollectionViewLayoutAttributes]()
    
    // 4
    fileprivate var contentHeight: CGFloat = 0
    
    fileprivate var contentWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }
    
     //5
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    init(topInset: CGFloat) {
            super.init()
            self.insets.top = topInset
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func prepare() {
        // 1
        guard let collectionView = collectionView else {return}

        cache = [UICollectionViewLayoutAttributes]()
        
        // 2
        let columnWidth = contentWidth / CGFloat(numberOfColumns)
        var xOffset = [CGFloat]()
        for column in 0 ..< numberOfColumns {
            xOffset.append(CGFloat(column) * columnWidth)
        }
        var column = 0
        var yOffset = [CGFloat](repeating: 0, count: numberOfColumns)
        
        for (index, _) in yOffset.enumerated(){
            yOffset[index] = insets.top
        }
        
        // 3
        for item in 0 ..< collectionView.numberOfItems(inSection: 0) {
            
            let indexPath = IndexPath(item: item, section: 0)
            
            // 4
            let photoHeight = cellHeights[item % cellHeights.count]
            let height = cellPadding * 2 + photoHeight
            let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
            
            // 5
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            cache.append(attributes)
            
            // 6
            contentHeight = max(contentHeight, frame.maxY)
            yOffset[column] = yOffset[column] + height
            
            column = column < (numberOfColumns - 1) ? (column + 1) : 0
        }
        
        contentHeight += insets.bottom
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
        
        // Loop through the cache and look for items in the rect
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        return visibleLayoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if indexPath.item < cache.count{
            return cache[indexPath.item]
        }
        return UICollectionViewLayoutAttributes()
    }

}
