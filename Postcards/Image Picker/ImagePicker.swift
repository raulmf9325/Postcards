//
//  ImagePicker.swift
//  Postcards
//
//  Created by Raul Mena on 6/23/19.
//  Copyright © 2019 Raul Mena. All rights reserved.
//

import UIKit
import Photos

protocol ImagePickerDelegate{
    func uploadPhotos(assets: [PHAsset])
}

// image source
enum Source{
    case local
    case instagram
}

class ImagePicker: UICollectionViewController {
    
    /*  Stored Properties
     */
    
    // delegate
    var delegate: ImagePickerDelegate!
    
    var source: Source = .local
    
    // local photos
    var photos: PHFetchResult<PHAsset>?{
        didSet{
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    // instagram images
    var images = [URL]()
    
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
    
    // upload button
    let uploadButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "upload"), for: .normal)
        return button
    }()
    
    // selection state
    enum SelectionState{
        case select
        case cancel
    }
    
    // pop-up view
    var popUp: PopUp!
    
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
        
        popUp = PopUp(frame: view.bounds)
        popUp.delegate = self
        
        if source == .local {fetchLocalPhotos()}
        else {fetchInstagramImages()}
    }
    
    private func fetchInstagramImages(){
        view.addSubview(popUp)
        popUp.title = "Please enter Instagram account name (must be public)"
        popUp.placeholder = " account name"
        popUp.present()
    }
    
    private func fetchLocalPhotos(){
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
    
    private func addBackButton() {
        navBar.addSubview(backButton)
        backButton.leftAnchor == navBar.leftAnchor + 30
        backButton.bottomAnchor == navBar.bottomAnchor - 14
        backButton.widthAnchor == 20
        backButton.heightAnchor == 15
        backButton.addTarget(self, action: #selector(handleTapBackButton), for: .touchUpInside)
    }
    
    private func removeBackButton(){
        backButton.removeFromSuperview()
    }
    
    private func addUploadButton(){
        navBar.addSubview(uploadButton)
        uploadButton.leftAnchor == navBar.leftAnchor + 30
        uploadButton.bottomAnchor == navBar.bottomAnchor - 14
        uploadButton.widthAnchor == 25
        uploadButton.heightAnchor == 25
        uploadButton.addTarget(self, action: #selector(handleTapUploadButton), for: .touchUpInside)
    }
    
    private func removeUploadButton(){
        uploadButton.removeFromSuperview()
    }
    
    private func addNavigationBar(){
        view.addSubview(navBar)
        navBar.topAnchor == view.topAnchor
        navBar.leftAnchor == view.leftAnchor
        navBar.rightAnchor == view.rightAnchor
        navBar.heightAnchor == 85
        navBar.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 85)
        navBar.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 12)
        
        addBackButton()
        
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
        let count = (source == .local) ? (photos?.count ?? 0) : images.count
        return count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellId", for: indexPath) as! PhotoCell
        
        cell.photo.image = UIImage(named: "picture")
        
        if source == .local{
            let asset = photos?.object(at: indexPath.item)
            cell.asset = asset
        }
        else{
            let imageURL = images[indexPath.item]
            cell.imageURL = imageURL
        }
        
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
        
        let width: CGFloat = view.frame.width
        let height: CGFloat = width + 60
        
        if selectState == .select{
            if source == .local{
                guard let asset = cell.asset else {return}
                zoomedPhoto.fetchImage(asset: asset, contentMode: .aspectFill, targetSize: CGSize(width: width, height: height))
            }
            else{
                zoomedPhoto.image = cell.photo.image
            }
            
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
                if selectedPhotos.values.count == 0{
                    removeUploadButton()
                }
            }
            else{
                cell.cellWasSelected()
                if selectedPhotos.values.count == 0{
                    addUploadButton()
                }
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
            
           removeBackButton()
        }
        else{
            selectState = .select
            label.removeFromSuperview()
            let title = titleForButton(title: "Select")
            selectButton.setAttributedTitle(title, for: .normal)
            selectedPhotos.removeAll()
            addBackButton()
            removeUploadButton()
            
            collectionView.reloadData()
        }
    }
    
    @objc private func handleTapUploadButton(){
        let assets: [PHAsset] = selectedPhotos.values.map{return $0}
        delegate.uploadPhotos(assets: assets)
        handleTapBackButton()
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

extension ImagePicker: PopupDelegate{
    func handleUserEntry(albumName: String) {
        fetchURL(username: albumName)
    }
    
    private func fetchURL(username: String){
        let urlString = "https://www.instagram.com/\(username)/"
        guard let url = URL(string: urlString) else {return}
        var html = ""
        do{
            html = try String(contentsOf: url)
        }
        catch let error{
            print(error.localizedDescription)
        }
        
        // let regex = "window._sharedData = (.*);</script>"
        
        if let jsonString = html.slice(from: "window._sharedData = ", to: ";</script>"){
            //print(jsonString)
            
            let data = Data(jsonString.utf8)
            do {
                // make sure this JSON is in the format we expect
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    // try to read out a string array
                    if let entry = json["entry_data"] as? [String: Any] {
                        if let profile = entry["ProfilePage"] as? [[String: Any]]{
                            if let graphql = profile[0]["graphql"] as? [String: Any]{
                                if let user = graphql["user"] as? [String: Any]{
                                    if let owner = user["edge_owner_to_timeline_media"] as? [String: Any]{
                                        if let edges = owner["edges"] as? [[String: Any]]{
                                            edges.forEach { (edge) in
                                                if let node = edge["node"] as? [String: Any]{
                                                    let image = node["display_url"] as! String
                                                    if let url = URL(string: image){
                                                        self.images.append(url)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                collectionView.reloadData()
            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
            }
        }
        else{
            let alert = UIAlertController(title: "An error occured", message: "make sure to enter a valid account name, and that the account is public", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                self.handleTapBackButton()
            }))
            present(alert, animated: true, completion: nil)
        }
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

extension String {
    
    func slice(from: String, to: String) -> String? {
        
        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                String(self[substringFrom..<substringTo])
            }
        }
    }
}
