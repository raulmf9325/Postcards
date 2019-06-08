//
//  WelcomePage.swift
//  Postcards
//
//  Created by Raul Mena on 1/16/19.
//  Copyright © 2019 Raul Mena. All rights reserved.
//

import UIKit
import Firebase

class WelcomePage: UIViewController{
    // login page reference
    var loginPage: AuthenticationPage!
    
    enum AuthType{
        case login
        case signup
    }
    
//    // root controller
//    var rootController: RootController?{
//        didSet{
//            self.loginPage.rootController = rootController
//        }
//    }
    
    let homeImageView: UIImageView = {
        let image = UIImage(named: "home")
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let welcomeLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome to Postcards!"
        label.font = UIFont(name: "HelveticaNeue-Medium", size: 28)
        label.textColor = .white
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
 //   var timer: Timer?
    let wallpapers = ["home","1","2","3"]
    var imageCounter = 0
    
    var loginButton: UIButton?
    var signUpButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        setupViews()
        let timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(handleTimer), userInfo: nil, repeats: true)
    }
    
    /*  setup views
     */
    fileprivate func setupViews(){
        // background image
        view.addSubview(homeImageView)
        homeImageView.fillSuperview()
        
        // Login and Sign Up buttons
        let buttonWidth: CGFloat = 120
        let buttonHeight: CGFloat = 45
        let buttonHorizontalInset: CGFloat = 20
        let buttonVerticalInset: CGFloat = 200
        let padding: CGFloat = (view.frame.width - 2 * buttonWidth - buttonHorizontalInset) / 2
        print(padding)
        
        
        loginButton = buttonForTitle(title: "Login")
        signUpButton = buttonForTitle(title: "Sign Up")
        
        guard let loginButton = loginButton, let signUpButton = signUpButton else {return}
        
        view.addSubview(loginButton)
        view.addSubview(signUpButton)
        view.addConstraintsWithFormat(format: "H:|-\(padding)-[v0(\(buttonWidth))]-\(buttonHorizontalInset)-[v1(\(buttonWidth))]-\(padding)-|", views: loginButton, signUpButton)
        view.addConstraintsWithFormat(format: "V:[v0(\(buttonHeight))]-\(buttonVerticalInset)-|", views: loginButton)
        view.addConstraintsWithFormat(format: "V:[v0(\(buttonHeight))]-\(buttonVerticalInset)-|", views: signUpButton)
        
        // welcome label
        view.addSubview(welcomeLabel)
        view.addConstraintsWithFormat(format: "H:|-\(padding)-[v0]-\(padding)-|", views: welcomeLabel)
        view.addConstraintsWithFormat(format: "V:[v0(90)]-10-[v1]", views: welcomeLabel, loginButton)
        
        loginButton.addTarget(self, action: #selector(handleTapLoginButton), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(handleTapSignUpButton), for: .touchUpInside)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    @objc func handleTapLoginButton(){
        proceedToAuthenticationPage(auth: .login)
    }
    
    @objc func handleTapSignUpButton(){
        proceedToAuthenticationPage(auth: .signup)
    }
    
//    fileprivate func proceedToLoginPage(){
//        loginPage.auth = .login
//        loginPage.loginLabel.text = "Log In"
//        loginPage.loginButton.setTitle("Log In", for: .normal)
//        navigationController?.pushViewController(loginPage, animated: true)
//    }
//
//    fileprivate func proceedToSignUpPage(){
//        loginPage.auth = .signUp
//        loginPage.loginLabel.text = "Sign Up"
//        loginPage.loginButton.setTitle("Sign Up", for: .normal)
//        navigationController?.pushViewController(loginPage, animated: true)
//    }
//
    private func proceedToAuthenticationPage(auth: AuthType){
        if auth == .login{
            loginPage = AuthenticationPage(auth: .login)
        }
        else{
            loginPage = AuthenticationPage(auth: .signUp)
        }
        
        navigationController?.pushViewController(loginPage, animated: true)
    }
    
    
    fileprivate func buttonForTitle(title: String) -> UIButton{
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 0.31, green: 0.78, blue: 0.47, alpha: 1)
        button.layer.cornerRadius = 8
        return button
    }
    
    @objc fileprivate func handleTimer(){
        imageCounter = (imageCounter + 1) % 4
        let toImageName = wallpapers[imageCounter]
        let toImage = UIImage(named: toImageName)
        
        UIView.transition(with: homeImageView, duration: 1.5, options: .transitionCrossDissolve, animations: {
             self.homeImageView.image = toImage
        }, completion: nil)
    }
    
}
