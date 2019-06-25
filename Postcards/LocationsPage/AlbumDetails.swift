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
}

extension AlbumDetails: ImagePickerDelegate{
    func uploadPhotos(assets: [PHAsset]) {
//        // reference to storage
//        let storageRef = Storage.storage().reference()
//        // reference to file you want to upload
        
//        let winterRef = storageRef.child("image/winter.png")
//
//        guard let winterImage = UIImage(named: "winter") else {return}
//
//        guard let data = winterImage.pngData() else {return}
//
//        winterRef.putData(data, metadata: nil) { (metadata, error) in
//            if error == nil{
//                self.ref.child("games/1/image").setValue("winter.png")
//            }
//            else{
//                print(error)
//            }
//
//            guard let metadata = metadata else{return}
//
//            let size = metadata.size
//            print(size)
//
//            // download url
//            winterRef.downloadURL(completion: { (url, error) in
//                guard let url = url else {
//                    print(error)
//                    return
//                }
//            })
//        }
        guard let user = Auth.auth().currentUser?.email else {return}
        let storageRef = storage.reference()
        
        assets.forEach { (asset) in
            let imageName = asset.localIdentifier + ".png"
            let imageRef = storageRef.child("users/\(user)/\(imageName)")
            
            let options = PHImageRequestOptions()
            options.version = .original
            //  options.deliveryMode = .highQualityFormat
            PHImageManager.default().requestImage(for: asset, targetSize: .init(width: 2000, height: 2000), contentMode: .aspectFit, options: options) { image, _ in
                guard let image = image else { return }
                guard let data = image.pngData() else {return}
                imageRef.putData(data, metadata: nil, completion: { (metadata, error) in
                    if error == nil{
                        let albumDoc = self.db.collection("users").document(user).collection("albums").document(self.album!.name!)
                        
                    }
                })
            }
        }
    }
}
