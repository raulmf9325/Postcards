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
    
    // selected photos
    var selectedPhotos = [Int : PHAsset]()
    
    // navigation delegate
    var navigationDelegate: RootController!
    
    // wallpaper
    let wallpaper = getWallpaper()
    
    // navigation bar
    let navBar: UIView = {
        let bar = UIView()
        bar.backgroundColor = UIColor(white: 0, alpha: 0.7)
        return bar
    }()
    
    // back button
    let backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "backButton"), for: .normal)
        return button
    }()
    
    // selection state
    enum SelectionState{
        case select
        case cancel
    }
    
    var selectState: SelectionState = .select
    
    // label
    let label: UILabel = {
        let label = UILabel()
        let labelTitle =  NSAttributedString(string: "Select Items", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font : UIFont(name: "AvenirNext-Heavy", size: 20)])
        label.attributedText = labelTitle
        return label
    }()

    
    // select button
    let selectButton: UIButton = {
        let button = UIButton(type: .system)
        let title = NSAttributedString(string: "Select", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font : UIFont(name: "AvenirNext-Heavy", size: 20)])
        button.setAttributedTitle(title, for: .normal)
        return button
    }()
    
    // zoomed photo
    let zoomedPhoto: UIImageView = {
        let imageView = UIImageView(image: nil)
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let zoomedPhotoContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    // black overlay
    let blackOverlay: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
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
        backButton.bottomAnchor == navBar.bottomAnchor - 14
        backButton.widthAnchor == 20
        backButton.heightAnchor == 15
        backButton.addTarget(self, action: #selector(handleTapBackButton), for: .touchUpInside)
        
        navBar.addSubview(selectButton)
        selectButton.bottomAnchor == navBar.bottomAnchor - 4
        selectButton.rightAnchor == navBar.rightAnchor - 30
        selectButton.widthAnchor == 70
        selectButton.heightAnchor == 35
        selectButton.addTarget(self, action: #selector(handleTapSelectButton), for: .touchUpInside)
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
        
        if selectedPhotos[indexPath.item] != nil{
            cell.cellWasSelected()
        }
        else{
            cell.cellWasDeselected()
        }
        
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
        
        if selectState == .select{
            guard let asset = cell.asset else {return}
            let width: CGFloat = view.frame.width
            let height: CGFloat = width + 60
            zoomedPhoto.fetchImage(asset: asset, contentMode: .aspectFill, targetSize: CGSize(width: width, height: height))
            
            view.addSubview(blackOverlay)
            blackOverlay.widthAnchor == view.widthAnchor
            blackOverlay.heightAnchor == view.heightAnchor
            blackOverlay.addSubview(zoomedPhotoContainer)
            
            zoomedPhotoContainer.centerXAnchor == view.centerXAnchor
            zoomedPhotoContainer.centerYAnchor == view.centerYAnchor
            zoomedPhotoContainer.widthAnchor == width
            zoomedPhotoContainer.heightAnchor == height
            
            zoomedPhotoContainer.addSubview(zoomedPhoto)
            zoomedPhoto.widthAnchor == zoomedPhotoContainer.widthAnchor
            zoomedPhoto.heightAnchor == zoomedPhotoContainer.heightAnchor
            zoomedPhotoContainer.alpha = 0
            
            UIView.animate(withDuration: 0.3, animations: {
                self.zoomedPhotoContainer.alpha = 1
            }) { (_) in
                [self.blackOverlay, self.zoomedPhoto].forEach{$0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissZoomedImage)))}
            }
        }
        else{
            if selectedPhotos[indexPath.item] != nil{
                cell.cellWasDeselected()
                selectedPhotos.removeValue(forKey: indexPath.item)
            }
            else{
                cell.cellWasSelected()
                selectedPhotos[indexPath.item] = cell.asset
            }
            
        }
    }
    
    @objc private func handleTapSelectButton(){
        if selectState == .select{
           selectState = .cancel
           let title = titleForButton(title: "Cancel")
           selectButton.setAttributedTitle(title, for: .normal)
        
           navBar.addSubview(label)
           label.centerXAnchor == navBar.centerXAnchor
           label.bottomAnchor == selectButton.bottomAnchor
           label.widthAnchor == 150
           label.heightAnchor == 35
        }
        else{
            selectState = .select
            label.removeFromSuperview()
            let title = titleForButton(title: "Select")
            selectButton.setAttributedTitle(title, for: .normal)
        }
    }
    
    @objc private func dismissZoomedImage(){
        UIView.animate(withDuration: 0.3, animations: {
            self.zoomedPhotoContainer.alpha = 0
            self.blackOverlay.alpha = 0
        }) { (_) in
            self.blackOverlay.removeFromSuperview()
            self.zoomedPhotoContainer.alpha = 1
            self.blackOverlay.alpha = 1
        }
    }
    
    private func titleForButton(title: String) -> NSAttributedString{
        let title = NSAttributedString(string: "\(title)", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font : UIFont(name: "AvenirNext-Heavy", size: 20)])
        
        return title
    }
    
}

extension UIImageView{
    func fetchImage(asset: PHAsset, contentMode: PHImageContentMode, targetSize: CGSize) {
        let options = PHImageRequestOptions()
        options.version = .original
      //  options.deliveryMode = .highQualityFormat
        PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: contentMode, options: options) { image, _ in
            guard let image = image else { return }
            self.image = image
        }
    }
}
