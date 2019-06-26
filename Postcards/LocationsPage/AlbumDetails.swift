//
//  AlbumDetails.swift
//  Postcards
//
//  Created by Raul Mena on 1/26/19.
//  Copyright © 2019 Raul Mena. All rights reserved.
//

import UIKit
import Photos
import Firebase


class AlbumDetails: PinterestPage{
    
    override var topInset: CGFloat {
        get{return 70}
        set {}
    }
    
    override func viewDidLoad() {
        navigationController?.isNavigationBarHidden = true
        collectionView.register(PinterestCell.self, forCellWithReuseIdentifier: "CellId")
        collectionView.register(CarouselCell.self, forCellWithReuseIdentifier: "CarouselCell")
        collectionView.backgroundView = backgroundView
        setupHeader(carouselAvailable: true)
        addBackButton()
        addUploadButton()
    }
    
    private func addUploadButton(){
        if album?.type == .defaultAlbum {return}
        PinterestHeader.addSubview(uploadButton)
        uploadButton.rightAnchor == cubeButton.leftAnchor - 30
        uploadButton.bottomAnchor == backButton.bottomAnchor
        uploadButton.widthAnchor == 25
        uploadButton.heightAnchor == 25
        uploadButton.addTarget(self, action: #selector(handleTapUploadButton), for: .touchUpInside)
    }
        
   private func addBackButton(){
        PinterestHeader.addSubview(backButton)
        PinterestHeader.addConstraintsWithFormat(format: "H:[v0(20)]-25-|", views: backButton)
        PinterestHeader.addConstraintsWithFormat(format: "V:[v0(15)]-16-|", views: backButton)
        
        backButton.addTarget(self, action: #selector(handleTapBackButton), for: .touchUpInside)
    }
    
    @objc private func handleTapUploadButton(){
        let imagePicker = ImagePicker(collectionViewLayout: UICollectionViewFlowLayout())
        let selectedFrame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: view.frame.height)
        
        let rootController = delegate as! RootController
        imagePicker.navigationDelegate = rootController
        imagePicker.delegate = self
        
        rootController.pushController(selectedFrame: selectedFrame, vc: imagePicker)
    }
    
    @objc private func handleTapBackButton(){
        let rootController = delegate as! RootController
        rootController.pop(originFrame: CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: view.frame.height), animated: true, collapse: true)
    }
    
    let backButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "backButton")
        button.setImage(image, for: .normal)
        return button
    }()
    
    
    let uploadButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "upload"), for: .normal)
        return button
    }()
    
    let blackOverlay: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.7)
        return view
    }()
    
    let uploadingLabel: UILabel = {
        let label = UILabel()
        let attributedText = NSMutableAttributedString(string: "Uploading", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font : UIFont(name: "AvenirNext-Heavy", size: 26)])
        label.attributedText = attributedText
        label.textAlignment = .center
        return label
    }()
}

extension AlbumDetails: ImagePickerDelegate{
    func uploadPhotos(assets: [PHAsset]) {
        guard let user = Auth.auth().currentUser?.email else {return}
        let storageRef = storage.reference()
        
        presentUploadDialog()
        
        
        for (i, asset) in assets.enumerated(){
            let identifier = asset.localIdentifier
            let startIndex = identifier.startIndex
            let endIndex = identifier.index(identifier.startIndex, offsetBy: 36)
            let imageName = String(identifier[startIndex..<endIndex]) + ".png"
            
            let imageRef = storageRef.child("users/\(user)/\(imageName)")
            
            let options = PHImageRequestOptions()
            options.version = .original
            options.deliveryMode = .highQualityFormat
            PHImageManager.default().requestImage(for: asset, targetSize: .init(width: 2000, height: 2000), contentMode: .aspectFit, options: options) { image, _ in
                guard let image = image else { return }
                guard let data = image.pngData() else {return}
                imageRef.putData(data, metadata: nil, completion: { (metadata, error) in
                    if error == nil{
                        let albumDoc = self.db.collection("users").document(user).collection("albums").document(self.album!.name!)
                        albumDoc.getDocument(completion: { (snapshot, error) in
                            guard var dictionary = snapshot?.data() as? [String:String] else {return}
                            let count = "\(dictionary.values.count + 1)"
                            dictionary[count] = imageName
                            albumDoc.setData(dictionary)
  
                        })
                        imageRef.downloadURL(completion: { (url, error) in
                            if let url = url{
                                self.postcards.append(postcard(albumName: self.album!.name!, imageStringURL: url.absoluteString, imageName: imageName))
                            }
                            if i == assets.count - 1{
                                self.collectionView.reloadData()
                                self.dismissUploadDialog()
                            }
                        })
                    }
                })
            }
        }
    }
    
    private func presentUploadDialog(){
        view.addSubview(blackOverlay)
        blackOverlay.widthAnchor == view.widthAnchor
        blackOverlay.heightAnchor == view.heightAnchor
        
        view.addSubview(uploadingLabel)
        uploadingLabel.centerXAnchor == view.centerXAnchor
        uploadingLabel.centerYAnchor == view.centerYAnchor - 60
        uploadingLabel.widthAnchor == 200
        uploadingLabel.heightAnchor == 40
        
        startActivityIndicator()
    }
    
    private func dismissUploadDialog(){
        uploadingLabel.removeFromSuperview()
        blackOverlay.removeFromSuperview()
        removeActivityIndicator()
    }
}
