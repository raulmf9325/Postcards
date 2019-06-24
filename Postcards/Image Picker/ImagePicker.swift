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
    
    // navigation delegate
    var navigationDelegate: RootController!
    
    // wallpaper
    let wallpaper = getWallpaper()
    
    // navigation bar
    let navBar: UIView = {
        let bar = UIView()
        bar.backgroundColor = UIColor(white: 0, alpha: 0.6)
        return bar
    }()
    
    // back button
    let backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "backButton"), for: .normal)
        return button
    }()
    
    // zoomed photo
    let zoomedPhoto: UIImageView = {
        let imageView = UIImageView(image: nil)
        return imageView
    }()
    
    // zoomed photo container
    let blackOverlay: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: "CellId")
        
        addWallpaper()
        addNavigationBar()
        
        // Load Photos
        PHPhotoLibrary.requestAuthorization { (status) in
            switch status {
            case .authorized:
                
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                self.photos = PHAsset.fetchAssets(with: fetchOptions)
                
            case .denied, .restricted:
                print("Not allowed")
            case .notDetermined:
                print("Not determined yet")
            }
        }
        
    }
    
    @objc private func handleTapBackButton(){
       navigationDelegate.pop(originFrame: CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: view.frame.height), animated: true, collapse: true)
    }
    
    private func addNavigationBar(){
        view.addSubview(navBar)
        navBar.topAnchor == view.topAnchor
        navBar.leftAnchor == view.leftAnchor
        navBar.rightAnchor == view.rightAnchor
        navBar.heightAnchor == 85
        navBar.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 85)
        navBar.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 12)
        
        navBar.addSubview(backButton)
        backButton.leftAnchor == navBar.leftAnchor + 30
        backButton.bottomAnchor == navBar.bottomAnchor - 10
        backButton.widthAnchor == 20
        backButton.heightAnchor == 15
        backButton.addTarget(self, action: #selector(handleTapBackButton), for: .touchUpInside)
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
        cell.photo.image = UIImage(named: "picture")
        cell.asset = asset
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
        zoomedPhoto.image = cell.photo.image
        
        view.addSubview(blackOverlay)
        blackOverlay.widthAnchor == view.widthAnchor
        blackOverlay.heightAnchor == view.heightAnchor
        blackOverlay.addSubview(zoomedPhoto)
        
        zoomedPhoto.frame = cell.frame
        let center = view.center
        let width: CGFloat = view.frame.width - 60
        let height: CGFloat = width + 30
        let origin = CGPoint(x: center.x - width / 2, y: center.y - height / 2)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.zoomedPhoto.frame = CGRect(origin: origin, size: CGSize(width: width, height: height))
        }) { (_) in
            [self.blackOverlay, self.zoomedPhoto].forEach{$0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissZoomedImage)))}
        }
    }
    
    @objc private func dismissZoomedImage(){
        UIView.animate(withDuration: 0.2, animations: {
            self.zoomedPhoto.frame = CGRect(origin: self.view.center, size: .zero)
        }) { (_) in
            self.blackOverlay.removeFromSuperview()
        }
        
    }
    
}

extension UIImageView{
    func fetchImage(asset: PHAsset, contentMode: PHImageContentMode, targetSize: CGSize) {
        let options = PHImageRequestOptions()
        options.version = .original
        options.deliveryMode = .highQualityFormat
        
        PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: contentMode, options: options) { image, _ in
            guard let image = image else { return }
            self.image = image
        }
    }
}
