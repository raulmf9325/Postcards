//
//  WelcomePage.swift
//  Postcards
//
//  Created by Raul Mena on 1/16/19.
//  Copyright © 2019 Raul Mena. All rights reserved.
//

import UIKit

class WelcomePage: UIViewController{
    
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
        let buttonWidth: CGFloat = 85
        let buttonHeight: CGFloat = 35
        let buttonHorizontalInset: CGFloat = 20
        let buttonVerticalInset: CGFloat = 120
        let padding: CGFloat = (view.frame.width - 2 * buttonWidth - buttonHorizontalInset) / 2
        print(padding)
        
        
        loginButton = buttonForTitle(title: "Login")
        signUpButton = buttonForTitle(title: "Sign Up")
        
        guard let loginButton = loginButton, let signUpButton = signUpButton else {
            print("ERROR!: Couldn't Render Buttons")
            return
        }
        
        view.addSubview(loginButton)
        view.addSubview(signUpButton)
        view.addConstraintsWithFormat(format: "H:|-\(padding)-[v0(\(buttonWidth))]-\(buttonHorizontalInset)-[v1(\(buttonWidth))]-\(padding)-|", views: loginButton, signUpButton)
        view.addConstraintsWithFormat(format: "V:[v0(\(buttonHeight))]-\(buttonVerticalInset)-|", views: loginButton)
        view.addConstraintsWithFormat(format: "V:[v0(\(buttonHeight))]-\(buttonVerticalInset)-|", views: signUpButton)
        
        // welcome label
        view.addSubview(welcomeLabel)
        view.addConstraintsWithFormat(format: "H:|-\(padding)-[v0]-\(padding)-|", views: welcomeLabel)
        view.addConstraintsWithFormat(format: "V:[v0(90)]-10-[v1]", views: welcomeLabel, loginButton)
       
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
    
    /*
        Print Family Fonts
    */
    func printFonts() {
        let fontFamilyNames = UIFont.familyNames
        for familyName in fontFamilyNames {
            print("------------------------------")
            print("Font Family Name = [\(familyName)]")
            let names = UIFont.fontNames(forFamilyName: familyName)
            print("Font Names = [\(names)]")
        }
    }
}
