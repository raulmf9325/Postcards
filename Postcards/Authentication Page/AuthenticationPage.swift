//
//  AuthenticationPage.swift
//  Postcards
//
//  Created by Raul Mena on 1/16/19.
//  Copyright © 2019 Raul Mena. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class AuthenticationPage: UIViewController{
    
    enum authentication{
        case login
        case signUp
    }
    
    var auth: authentication?
    
    let logoImageView: UIImageView = {
        let image = UIImage(named: "tent")
        let imageView = UIImageView(image: image)
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let loginLabel: UILabel = {
        let label = UILabel()
        label.text = "Login"
        label.textColor = .darkGray
        label.font = UIFont(name: "AvenirNext-Heavy", size: 30)
        label.textAlignment = .center
        return label
    }()
    
    let usernameTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "  username"
        field.borderStyle = .roundedRect
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        return field
    }()
    
    let passwordTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "  password"
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.borderStyle = .roundedRect
        field.isSecureTextEntry = true
        return field
    }()
    
    let loginButton: DarkHighlightedButton = {
        let button = DarkHighlightedButton()
        button.setTitle("Login", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .phoenix
        button.layer.cornerRadius = 8
        return button
    }()
    
    let wrongEmailLabel: UILabel = {
        let label = UILabel()
        label.text = "Incorrect username or password."
        label.font = UIFont(name: "AvenirNext-Heavy", size: 14)
        label.textColor = .red
        label.textAlignment = .center
        return label
    }()
    
    var logoConstraints: [NSLayoutConstraint]?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        setupViews()
        registerListeners()
        disableButton()
        usernameTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    fileprivate func registerListeners(){
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc func keyboardWillShow(notification: NSNotification){
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardInfo = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        let keyboardSize = keyboardInfo.cgRectValue.size
        
        let padding = view.frame.height - (loginButton.frame.origin.y + loginButton.frame.height) - 10
        view.frame.origin.y = view.frame.origin.y - keyboardSize.height + padding
        
        guard let constraint = logoConstraints?[0] else {return}
        
        view.layoutIfNeeded()
        UIView.animate(withDuration: 1) {
            constraint.constant += 60
            self.view.layoutIfNeeded()
        }
        
    }
    
    @objc func keyboardWillHide(notification: NSNotification){
        view.frame.origin.y = 0
        
        guard let constraint = logoConstraints?[0] else {return}
        
        view.layoutIfNeeded()
        UIView.animate(withDuration: 1) {
            constraint.constant -= 60
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    
    fileprivate func disableButton(){
        loginButton.isUserInteractionEnabled = false
        loginButton.backgroundColor = .darkGray
    }
    
    fileprivate func enableButton(){
        loginButton.isUserInteractionEnabled = true
        loginButton.backgroundColor = .phoenix
    }
    
    
    fileprivate func setupViews(){
        
        let horizontalPadding: CGFloat = 90
        let verticalPadding: CGFloat = 100
        let distanceFromLogoToLabel: CGFloat = 80
        let elementsInset: CGFloat = 40
        let distanceBetweenTextFields: CGFloat = 18
        let labelHeight: CGFloat = 45
        let buttonHeight: CGFloat = 45
        let buttonWidth: CGFloat = 140
        let textFieldHeight: CGFloat = 40
        let logoHeight: CGFloat = 130
        
        view.addSubview(logoImageView)
        view.addSubview(loginLabel)
        view.addSubview(usernameTextField)
        view.addSubview(passwordTextField)
        view.addSubview(loginButton)
        view.addSubview(wrongEmailLabel)
        
        view.addConstraintsWithFormat(format: "H:|-\(horizontalPadding + 15)-[v0]-\(horizontalPadding + 15)-|", views: logoImageView)
        logoConstraints = [NSLayoutConstraint]()
        logoConstraints?.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|-\(verticalPadding)-[v0(\(logoHeight))]", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": logoImageView]))
        view.addConstraints(logoConstraints!)
        view.addConstraintsWithFormat(format: "H:|-\(horizontalPadding)-[v0]-\(horizontalPadding)-|", views: loginLabel)
        view.addConstraintsWithFormat(format: "V:|-\(verticalPadding + logoHeight + distanceFromLogoToLabel)-[v0(\(labelHeight))]", views: loginLabel)
        view.addConstraintsWithFormat(format: "H:|-\(horizontalPadding)-[v0]-\(horizontalPadding)-|", views: usernameTextField)
        view.addConstraintsWithFormat(format: "V:[v0]-\(elementsInset)-[v1(\(textFieldHeight))]", views: loginLabel, usernameTextField)
        view.addConstraintsWithFormat(format: "H:|-\(horizontalPadding)-[v0]-\(horizontalPadding)-|", views: passwordTextField)
        view.addConstraintsWithFormat(format: "V:[v0]-\(distanceBetweenTextFields)-[v1(\(textFieldHeight))]", views: usernameTextField, passwordTextField)
        view.addConstraintsWithFormat(format: "H:|-\(view.frame.width / 2 - buttonWidth / 2)-[v0(\(buttonWidth))]", views: loginButton)
        view.addConstraintsWithFormat(format: "V:[v0]-\(elementsInset / 2 - 10)-[v1(25)]-\(elementsInset / 2)-[v2(\(buttonHeight))]", views: passwordTextField, wrongEmailLabel, loginButton)
        view.addConstraintsWithFormat(format: "H:|[v0]|", views: wrongEmailLabel)
        
        wrongEmailLabel.alpha = 0
        loginButton.addTarget(self, action: #selector(handleTapLogin), for: .touchUpInside)
    }
    
    @objc func handleTapLogin(){
        guard let email = usernameTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        
        if auth == .login{
            // Sign In
            Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
                if let error = error{
                    print("Error with silent sign in: \(error)")
                    self.wrongEmailLabel.alpha = 1
                    self.usernameTextField.text = ""
                    self.passwordTextField.text = ""
                    return
                }
                guard let user = authResult?.user else {return}
                print("User: \(user.email) signed in")
            }
        }
        else{
            // Sign Up
            Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
                if let error = error{
                    print(error)
                    
                    if password.count < 6{
                        self.wrongEmailLabel.text = "The password must be 6 characters long or more."
                    }
                    else{
                        self.wrongEmailLabel.text = "Incorrect username or password."
                    }
                    
                    self.wrongEmailLabel.alpha = 1
                    self.usernameTextField.text = ""
                    self.passwordTextField.text = ""
                    return
                }
                guard let user = authResult?.user else { return }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // removing observer
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
}

extension AuthenticationPage: UITextFieldDelegate{
    
    // MARK: UITextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String
        ) -> Bool
    {
        // Enable button when username is filled out
        var username = ""
        var password = ""
        
        if textField == usernameTextField{
            username = (usernameTextField.text! as NSString).replacingCharacters(in: range, with: string)
            password = passwordTextField.text ?? ""
        }
        else{
            username = usernameTextField.text ?? ""
            password = (passwordTextField.text! as NSString).replacingCharacters(in: range, with: string)
        }
        
        
        if !username.isEmpty && !password.isEmpty {
            enableButton()
            
        } else {
            disableButton()
        }
        return true
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
}

class DarkHighlightedButton: UIButton{
    override var isHighlighted: Bool{
        didSet{
            backgroundColor = isHighlighted ? UIColor.darkGray : .phoenix
        }
    }
}

extension UIColor{
    static var phoenix = UIColor(red: 0.05, green: 0.6, blue: 1, alpha: 1)
}

