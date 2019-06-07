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
    
    // database reference
    var db: Firestore?
    
    // root controller
    var rootController: RootController?
    
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
        field.placeholder = "  email"
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
        label.font = UIFont(name: "AvenirNext-Heavy", size: 16)
        label.textColor = .red
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    let scrollView = UIScrollView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        setupViews()
        disableButton()
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerListeners()
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
        
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.setContentOffset(CGPoint(x: 0, y: keyboardSize.height), animated: true)
    }
    
    @objc func keyboardWillHide(notification: NSNotification){
       scrollView.contentInset = .zero
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
        let distanceFromLogoToLabel: CGFloat = 80
        let distanceFromLoginLabelToTextField: CGFloat = 20
        let distanceBetweenTextFields: CGFloat = 18
        let distanceFromPasswordFieldToWrongEmailLabel: CGFloat = 20
        let loginLabelHeight: CGFloat = 45
        let loginLabelWidth: CGFloat = view.frame.width - 2 * horizontalPadding
        let buttonHeight: CGFloat = 45
        let buttonWidth: CGFloat = 140
        let textFieldHeight: CGFloat = 40
        let textFieldWidth: CGFloat = 200
        let logoHeight: CGFloat = 130
        let logoWidth: CGFloat = 160
        
        view.addSubview(scrollView)
        scrollView.fillSuperview()
        
        scrollView.addSubview(logoImageView)
        scrollView.addSubview(loginLabel)
        scrollView.addSubview(usernameTextField)
        scrollView.addSubview(passwordTextField)
        scrollView.addSubview(loginButton)
        scrollView.addSubview(wrongEmailLabel)
        
        loginLabel.centerInSuperview(size: CGSize(width: loginLabelWidth, height: loginLabelHeight))
        
        logoImageView.anchor(top: nil, leading: scrollView.leadingAnchor, bottom: loginLabel.topAnchor, trailing: nil, padding: UIEdgeInsets(top: 0, left: (view.frame.width - logoWidth) / 2, bottom: distanceFromLogoToLabel, right: 0), size: CGSize(width: logoWidth, height: logoHeight))
        
        usernameTextField.anchor(top: loginLabel.bottomAnchor, leading: scrollView.leadingAnchor, bottom: nil, trailing: nil, padding: UIEdgeInsets(top: distanceFromLoginLabelToTextField, left: (view.frame.width - textFieldWidth) / 2, bottom: 0, right: 0), size: CGSize(width: textFieldWidth, height: textFieldHeight))
        
        passwordTextField.anchor(top: usernameTextField.bottomAnchor, leading: scrollView.leadingAnchor, bottom: nil, trailing: nil, padding: UIEdgeInsets(top: distanceBetweenTextFields, left: (view.frame.width - textFieldWidth) / 2, bottom: 0, right: 0), size: CGSize(width: textFieldWidth, height: textFieldHeight))
        
        wrongEmailLabel.anchor(top: passwordTextField.bottomAnchor, leading: scrollView.leadingAnchor, bottom: nil, trailing: scrollView.trailingAnchor, padding: UIEdgeInsets(top: distanceFromPasswordFieldToWrongEmailLabel, left: 0, bottom: 0, right: 0), size: CGSize(width: view.frame.width, height: 45))
        
        loginButton.anchor(top: wrongEmailLabel.bottomAnchor, leading: scrollView.leadingAnchor, bottom: nil, trailing: nil, padding: UIEdgeInsets(top: 18, left: (view.frame.width - buttonWidth) / 2, bottom: 0, right: 0), size: CGSize(width: buttonWidth, height: buttonHeight))
        
        wrongEmailLabel.alpha = 1
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
                
                // Enable Swipe Back Navigation
                guard let rootViewController = self.rootController else {return}
                self.navigationController?.pushViewController(rootViewController, animated: true)
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
                guard let email = user.email else {return}
                print("user: \(email) successfully signed up")
                
                let data: [String : Any] = ["email" : email, "favorites": [String]()]
                self.db?.collection("users").document("\(email)").setData(data)
                
                guard let rootViewController = self.rootController else {return}
                self.navigationController?.pushViewController(rootViewController, animated: true)
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

// Swipe back Pop View Controller
extension AuthenticationPage: UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {

        return true
    }
}

