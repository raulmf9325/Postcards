//
//  ImagePicker.swift
//  Postcards
//
//  Created by Raul Mena on 6/23/19.
//  Copyright © 2019 Raul Mena. All rights reserved.
//

import UIKit
import Photos

class ImagePicker: UICollectionViewController {
    
    /*  Stored Properties
     */
    
    // photos
    var photos: PHFetchResult<PHAsset>?{
        didSet{
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    // wallpaper
    let wallpaper = getWallpaper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: "CellId")
        
        // add wallpaper
        addWallpaper()
        
        // Load Photos
        PHPhotoLibrary.requestAuthorization { (status) in
            switch status {
            case .authorized:
                
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
                self.photos = PHAsset.fetchAssets(with: fetchOptions)
                
            case .denied, .restricted:
                print("Not allowed")
            case .notDetermined:
                print("Not determined yet")
            }
        }
        
    }
    
    private func addWallpaper(){
        collectionView.backgroundView = wallpaper
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
}

extension ImagePicker: UICollectionViewDelegateFlowLayout{
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos?.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellId", for: indexPath) as! PhotoCell
        let asset = photos?.object(at: indexPath.item)
        cell.photo.fetchImage(asset: asset!, contentMode: .aspectFit, targetSize: CGSize(width: 800, height: 800))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let horizontalPadding: CGFloat = 10
        let width: CGFloat = (view.frame.width / 3) - 20
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 100, left: 10, bottom: 20, right: 10)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoCell
        
    }
    
}

extension UIImageView{
    func fetchImage(asset: PHAsset, contentMode: PHImageContentMode, targetSize: CGSize) {
        let options = PHImageRequestOptions()
        options.version = .original
        
        PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: contentMode, options: options) { image, _ in
            guard let image = image else { return }
            self.image = image
        }
    }
}
