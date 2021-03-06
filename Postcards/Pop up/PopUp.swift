//
//  PopUp.swift
//  Postcards
//
//  Created by Raul Mena on 6/21/19.
//  Copyright © 2019 Raul Mena. All rights reserved.
//

import UIKit

protocol PopupDelegate{
    func handleUserEntry(albumName: String)
}

class PopUp: UIView{
    
    var delegate: PopupDelegate!
    
    var title = "Please enter name of new album"
    var placeholder = " new album name"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func present(){
        // black overlay
        addSubview(blackOverlay)
        blackOverlay.frame = self.bounds
        blackOverlay.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        // dialog window
        addSubview(dialogWindow)
        dialogWindow.centerXAnchor == centerXAnchor
        dialogWindow.centerYAnchor == centerYAnchor * 0.8
        dialogWindow.widthAnchor == (0.75) * widthAnchor
        dialogWindow.heightAnchor == (0.25) * heightAnchor
        
        // prompt label
        dialogWindow.addSubview(promptLabel)
        promptLabel.topAnchor == dialogWindow.topAnchor + 8
        promptLabel.leftAnchor == dialogWindow.leftAnchor + 8
        promptLabel.rightAnchor == dialogWindow.rightAnchor - 8
        promptLabel.heightAnchor == 50
        promptLabel.text = title
        
        // text field
        dialogWindow.addSubview(textField)
        textField.topAnchor == promptLabel.bottomAnchor + 10
        textField.leftAnchor == dialogWindow.leftAnchor + 20
        textField.rightAnchor == dialogWindow.rightAnchor - 20
        textField.heightAnchor == 35
        textField.placeholder = placeholder
        
        // division line
        let textFieldLine = grayThinLine()
        dialogWindow.addSubview(textFieldLine)
        textFieldLine.topAnchor == textField.bottomAnchor
        textFieldLine.leftAnchor == textField.leftAnchor
        textFieldLine.rightAnchor == textField.rightAnchor
        textFieldLine.heightAnchor == 0.7
        
        // vertical gray thin line
        let verticalLine = grayThinLine()
        dialogWindow.addSubview(verticalLine)
        verticalLine.centerXAnchor == dialogWindow.centerXAnchor
        verticalLine.bottomAnchor == dialogWindow.bottomAnchor
        verticalLine.widthAnchor == 1
        verticalLine.heightAnchor == dialogWindow.heightAnchor / 4
        
        // horizontal gray thin line
        let horizontalLine = grayThinLine()
        dialogWindow.addSubview(horizontalLine)
        horizontalLine.bottomAnchor == verticalLine.topAnchor
        horizontalLine.leftAnchor == dialogWindow.leftAnchor
        horizontalLine.rightAnchor == dialogWindow.rightAnchor
        horizontalLine.heightAnchor == 1
        
        // cancel button
        dialogWindow.addSubview(cancelButton)
        cancelButton.centerXAnchor == dialogWindow.centerXAnchor / 2
        cancelButton.widthAnchor == 0.25 * dialogWindow.widthAnchor
        cancelButton.bottomAnchor == dialogWindow.bottomAnchor - (frame.height * 0.0125)
        cancelButton.topAnchor == horizontalLine.bottomAnchor + (frame.height * 0.0125)
        cancelButton.addTarget(self, action: #selector(handleTapCancelButton), for: .touchUpInside)
        
        // confirm button
        dialogWindow.addSubview(confirmButton)
        confirmButton.centerXAnchor == dialogWindow.centerXAnchor * 1.5
        confirmButton.widthAnchor == cancelButton.widthAnchor
        confirmButton.bottomAnchor == cancelButton.bottomAnchor
        confirmButton.topAnchor == cancelButton.topAnchor
        confirmButton.addTarget(self, action: #selector(handleTapConfirmButton), for: .touchUpInside)
        
        // animate
        dialogWindow.transform = CGAffineTransform(scaleX: 0, y: 0)
        self.textField.becomeFirstResponder()
        UIView.animate(withDuration: 0.3, animations: {
            self.dialogWindow.transform = .identity
        }) { (_) in
            
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func handleTapCancelButton(){
        UIView.animate(withDuration: 0.3, animations: {
            self.dialogWindow.transform = CGAffineTransform(scaleX: 0.0001, y: 0.0001)
        }) { (_) in
            self.removeFromSuperview()
        }
    }
    
    @objc private func handleTapConfirmButton(){
        let albumName = textField.text ?? ""
        if albumName.count == 0 {return}
        
        delegate.handleUserEntry(albumName: albumName)
        handleTapCancelButton()
    }
    
    @objc private func dismissKeyboard(){
        endEditing(true)
    }
    
    private func grayThinLine() -> UIView{
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }
    
    let cancelButton: UIButton = {
        let button = UIButton()
        let string = NSAttributedString(string: "Cancel", attributes: [NSAttributedString.Key.foregroundColor : UIColor(red: 203/255, green: 65/255, blue: 84/255, alpha: 1), NSAttributedString.Key.font : UIFont(name: "AvenirNext-Medium", size: 17)])
        button.setAttributedTitle(string, for: .normal)
        return button
    }()
    
    let confirmButton: UIButton = {
        let button = UIButton()
        let string = NSAttributedString(string: "Confirm", attributes: [NSAttributedString.Key.foregroundColor : UIColor(red: 203/255, green: 65/255, blue: 84/255, alpha: 1), NSAttributedString.Key.font : UIFont(name: "AvenirNext-Medium", size: 17)])
        button.setAttributedTitle(string, for: .normal)
        return button
    }()
    
    let promptLabel: UILabel = {
        let label = UILabel()
        label.text = "Please enter name of new album"
        label.numberOfLines = 2
        label.font = UIFont(name: "AvenirNext-Heavy", size: 15)
        label.textAlignment = .center
        return label
    }()
    
    let textField: UITextField = {
        let field = UITextField()
        field.placeholder = " new album name"
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        return field
    }()
    
    let dialogWindow: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.backgroundColor = .white
        return view
    }()
    
    let blackOverlay: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        return view
    }()
}
