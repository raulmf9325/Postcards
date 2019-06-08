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

protocol AuthenticationDelegate{
    func handleLoginWasSuccessful()
}

class AuthenticationPage: UIViewController{
    // database reference
    let db = Firestore.firestore()
    
    // navigation delegate
    var delegate: AuthenticationDelegate?
    
    enum authentication{
        case login
        case signUp
    }
    
    var auth: authentication?
    
  
    
    init(auth: authentication){
        super.init(nibName: nil, bundle: nil)
        self.auth = auth
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        UIView.animate(withDuration: 0.1) {
            self.view.frame.origin.y -= keyboardFrame.size.height
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification){
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        UIView.animate(withDuration: 0.1) {
            self.view.frame.origin.y += keyboardFrame.size.height
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
        if auth == .login{
            loginLabel.text = "Log in"
            loginButton.setTitle("Log in", for: .normal)
        }
        else{
            loginLabel.text = "Sign up"
            loginButton.setTitle("Sign up", for: .normal)
        }
        
        let horizontalPadding: CGFloat = 70
        let verticalPadding: CGFloat = 40
        
        view.addSubview(logoImageView)
        logoImageView.topAnchor == view.safeAreaLayoutGuide.topAnchor + verticalPadding
        logoImageView.leftAnchor == view.leftAnchor + horizontalPadding
        logoImageView.rightAnchor == view.rightAnchor - horizontalPadding
        logoImageView.heightAnchor == 160
        
        view.addSubview(errorLabel)
        errorLabel.bottomAnchor == view.safeAreaLayoutGuide.bottomAnchor - 20
        errorLabel.leftAnchor == logoImageView.leftAnchor + 10
        errorLabel.rightAnchor == logoImageView.rightAnchor - 10
        errorLabel.heightAnchor == 45
        
        view.addSubview(loginButton)
        loginButton.leftAnchor == logoImageView.leftAnchor + 30
        loginButton.rightAnchor == logoImageView.rightAnchor - 30
        loginButton.bottomAnchor == errorLabel.topAnchor - 10
        loginButton.heightAnchor == 50
        
        view.addSubview(loginLabel)
        loginLabel.topAnchor == logoImageView.bottomAnchor + 50
        loginLabel.centerXAnchor == view.centerXAnchor
        loginLabel.widthAnchor == loginButton.widthAnchor
        loginLabel.heightAnchor == loginButton.heightAnchor
        
        view.addSubview(usernameTextField)
        usernameTextField.leftAnchor == logoImageView.leftAnchor - 20
        usernameTextField.rightAnchor == logoImageView.rightAnchor + 20
        usernameTextField.topAnchor == loginLabel.bottomAnchor + 50
        usernameTextField.heightAnchor == loginButton.heightAnchor
        
        view.addSubview(passwordTextField)
        passwordTextField.leftAnchor == usernameTextField.leftAnchor
        passwordTextField.rightAnchor == usernameTextField.rightAnchor
        passwordTextField.topAnchor == usernameTextField.bottomAnchor + 25
        passwordTextField.heightAnchor == loginButton.heightAnchor
    }
    
    @objc func handleTapLogin(){
        guard let email = usernameTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        
        if auth == .login{
            // Sign In
            Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
                if let error = error{
                    self.usernameTextField.text = ""
                    self.passwordTextField.text = ""
                    return
                }
                self.delegate?.handleLoginWasSuccessful()
            }
        }
        else{
            // Sign Up
            Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
                if let error = error{
                    print(error)
                    
                    if password.count < 6{
                        self.errorLabel.text = "The password must be 6 characters long or more."
                    }
                    else{
                        self.errorLabel.text = "\(error.localizedDescription)"
                    }
                    
                    self.usernameTextField.text = ""
                    self.passwordTextField.text = ""
                    return
                }
                guard let user = authResult?.user else { return }
                guard let email = user.email else {return}
                
                let data: [String : Any] = ["email" : email, "favorites": [String]()]
                self.db.collection("users").document("\(email)").setData(data)
                self.delegate?.handleLoginWasSuccessful()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // removing observer
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
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
    
    let errorLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont(name: "AvenirNext-Heavy", size: 16)
        label.textColor = .red
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
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

