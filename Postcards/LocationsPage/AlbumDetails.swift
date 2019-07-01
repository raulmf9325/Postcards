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
    
    // delegate for albumn deletion
    var locationsPage: LocationsPage!
    
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
        addTrashButton()
    }
    
    private func addTrashButton(){
        if album?.type == .defaultAlbum {return}
        PinterestHeader.addSubview(trashButton)
        trashButton.rightAnchor == uploadButton.leftAnchor - 25
        trashButton.bottomAnchor == uploadButton.bottomAnchor
        trashButton.widthAnchor == 20
        trashButton.heightAnchor == 20
        trashButton.addTarget(self, action: #selector(handleTapTrashButton), for: .touchUpInside)
    }
    
    private func addUploadButton(){
        if album?.type == .defaultAlbum {return}
        PinterestHeader.addSubview(uploadButton)
        uploadButton.rightAnchor == cubeButton.leftAnchor - 25
        uploadButton.bottomAnchor == backButton.bottomAnchor
        uploadButton.widthAnchor == 20
        uploadButton.heightAnchor == 20
        uploadButton.addTarget(self, action: #selector(handleTapUploadButton), for: .touchUpInside)
    }
        
   private func addBackButton(){
        PinterestHeader.addSubview(backButton)
        PinterestHeader.addConstraintsWithFormat(format: "H:[v0(20)]-15-|", views: backButton)
        PinterestHeader.addConstraintsWithFormat(format: "V:[v0(15)]-5-|", views: backButton)
        
        backButton.addTarget(self, action: #selector(handleTapBackButton), for: .touchUpInside)
    }
    
    @objc private func handleTapTrashButton(){
        let alert = UIAlertController(title: "Are you sure you want to delete the album?", message: "The album will be permanently deleted. This action cannot be undone", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Delete Album", style: .destructive, handler: {(_) in
            self.locationsPage.albumWasDeleted(album: self.album!)
            self.handleTapBackButton()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
            return
        }))
        self.present(alert, animated: true)
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
    
    let trashButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "garbage"), for: .normal)
        return button
    }()
}

extension AlbumDetails: ImagePickerDelegate{
    func uploadPhotos(assets: [PHAsset]) {
        guard let user = Auth.auth().currentUser?.email else {return}
        let storageRef = storage.reference()
        
        presentUploadDialog()
        
        var numberOfElementsToUpload = assets.count

        var dictionary = [String:String]()
        
        let albumDoc = self.db.collection("users").document(user).collection("albums").document(self.album!.name!)
        albumDoc.getDocument(completion: { (snapshot, error) in
            guard let info = snapshot?.data() as? [String:String] else {return}
            dictionary = info
            
            for (_, asset) in assets.enumerated(){
                let identifier = asset.localIdentifier
                let startIndex = identifier.startIndex
                let endIndex = identifier.index(identifier.startIndex, offsetBy: 36)
                let imageName = String(identifier[startIndex..<endIndex]) + ".png"
                
                if dictionary[imageName] != nil {
                    numberOfElementsToUpload -= 1
                    if numberOfElementsToUpload == 0{
                        albumDoc.setData(dictionary, completion: { (error) in
                            self.uploadDidFinish()
                        })
                    }
                    continue
                }
                
                let imageRef = storageRef.child("users/\(user)/\(imageName)")
                
                let options = PHImageRequestOptions()
                options.version = .original
                options.deliveryMode = .highQualityFormat
                PHImageManager.default().requestImage(for: asset, targetSize: .init(width: 2000, height: 2000), contentMode: .aspectFit, options: options) { image, _ in
                    guard let image = image else { return }
                    guard let data = image.pngData() else {return}
                    imageRef.putData(data, metadata: nil, completion: { (metadata, error) in
                        if error == nil{
                            dictionary[imageName] = imageName
                            imageRef.downloadURL(completion: { (url, error) in
                                if let url = url{
                                    self.postcards.append(postcard(albumName: self.album!.name!, imageStringURL: url.absoluteString, imageName: imageName))
                                }
                                numberOfElementsToUpload -= 1
                                if numberOfElementsToUpload == 0{
                                    albumDoc.setData(dictionary, completion: { (error) in
                                        self.uploadDidFinish()
                                    })
                                }
                            })
                        }
                    })
                }
            }
        })
    }
    
    private func uploadDidFinish(){
        collectionView.reloadData()
        dismissUploadDialog()
        self.album?.postcards = postcards
        locationsPage.albumWasUpdated(updatedAlbum: self.album!)
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

protocol DeleteDelegate{
    func postcardWasDeleted(postcards: [postcard])
}

//extension AlbumDetails{
//    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        if layoutState == .carousel {return}
//
//        let cell = collectionView.cellForItem(at: indexPath) as! PinterestCell
//        let postcardDetails = PostcardDetails()
//        postcardDetails.pagePostcard = postcards[indexPath.item]
//        let rootController = delegate as! RootController
//        postcardDetails.rootController = rootController
//        postcardDetails.likeDelegate = rootController.favoritesPage
//        postcardDetails.locationsPage = rootController.locationsPage
//        postcardDetails.deleteDelegate = self
//
//        let layoutAttributes = collectionView.layoutAttributesForItem(at: indexPath)
//
//        var selectedFrame: CGRect = .zero
//
//        if let frame = layoutAttributes?.frame{
//            selectedFrame = collectionView.convert(frame, to: collectionView.superview)
//        }
//
//        rootController.pushController(selectedFrame: selectedFrame, vc: postcardDetails)
//    }
//
//}
