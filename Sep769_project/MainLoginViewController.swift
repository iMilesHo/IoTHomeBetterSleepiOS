//
//  MainLoginViewController.swift
//  Sep769_project
//
//  Created by YuanlaiHe on 2023-10-12.
//

import UIKit
import FirebaseCore
import FirebaseAuth

class MainLoginViewController: UIViewController {
    var pageView: UIView!
    var visitorLoginButton: UIButton!
    var loginRegisterButton: UIButton!
        
    let myImageName = "onboardingImage5"
    let myTitle = "Get started now"
    let mySubtitle = "Embrace the smart life at your fingertips"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.navigationController?.navigationBar.tintColor = UIColor.white

        setupView()
    }
    
    func setupView() {
        pageView = UIScrollView(frame: view.bounds)
        view.addSubview(pageView)
        
        //Image
        let imageView = UIImageView(frame: CGRect(x: 0, y: view.bounds.height * 0.1, width: view.bounds.width, height:view.bounds.height * 0.4))
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: myImageName)
        pageView.addSubview(imageView)
        
        // Title
        let titleLabel = UILabel(frame: CGRect(x: 0, y: imageView.frame.maxY + 20, width: view.bounds.width, height: 60))
        titleLabel.text = myTitle
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0  // Allows the label to wrap text across multiple lines
        titleLabel.lineBreakMode = .byWordWrapping  // Wraps words at the boundary
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        pageView.addSubview(titleLabel)
        
        // Subtitle
        let subtitleLabel = UILabel(frame: CGRect(x: 20, y: titleLabel.frame.maxY+2, width: view.bounds.width - 40, height: 60)) // I've added some padding and a little vertical spacing between the title and subtitle
        subtitleLabel.text = mySubtitle
        subtitleLabel.textAlignment = .center
        subtitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)  // Slightly smaller font for the subtitle
        subtitleLabel.numberOfLines = 0  // Allows the label to wrap text across multiple lines
        subtitleLabel.lineBreakMode = .byWordWrapping  // Wraps words at the boundary
        pageView.addSubview(subtitleLabel)
        
        let buttonWidth: CGFloat = (view.bounds.width - 60) / 2  // Subtracting 60 to account for padding and spacing between buttons
        let buttonHeight: CGFloat = 50
        let spacing: CGFloat = 20  // Spacing between buttons
        
        // Visitor Login Button
        visitorLoginButton = UIButton(frame: CGRect(x: 20, y: subtitleLabel.frame.maxY+10, width: buttonWidth, height: buttonHeight))
        let visitorColor = UIColor(red: 0.3, green: 0.85, blue: 0.4, alpha: 1.0)  // A modern shade of green
        visitorLoginButton.setTitleColor(.white, for: .normal)
        visitorLoginButton.setTitleColor(.highlightedLabel, for: .highlighted)
        visitorLoginButton.setBackgroundImage(visitorColor.image, for: .normal)
        visitorLoginButton.setBackgroundImage(UIColor.systemGreen.highlighted.image, for: .highlighted)
        visitorLoginButton.setTitle("Visitor Login", for: .normal)
        visitorLoginButton.clipsToBounds = true
        visitorLoginButton.layer.cornerRadius = 25
        visitorLoginButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        visitorLoginButton.addTarget(self, action: #selector(visitorLoginTapped), for: .touchUpInside)
        pageView.addSubview(visitorLoginButton)
        
        // Login & Register Button
        loginRegisterButton = UIButton(frame: CGRect(x: visitorLoginButton.frame.maxX + spacing, y: subtitleLabel.frame.maxY+10, width: buttonWidth, height: buttonHeight))
        let loginColor = UIColor(red: 0.2, green: 0.75, blue: 0.3, alpha: 1.0)
        loginRegisterButton.setTitleColor(.white, for: .normal)
        loginRegisterButton.setTitleColor(.highlightedLabel, for: .highlighted)
        loginRegisterButton.setBackgroundImage(loginColor.image, for: .normal)
        loginRegisterButton.setBackgroundImage(UIColor.systemGreen.highlighted.image, for: .highlighted)
        loginRegisterButton.setTitle("Login/Register", for: .normal)
        loginRegisterButton.clipsToBounds = true
        loginRegisterButton.layer.cornerRadius = 25  // Rounded corners
        loginRegisterButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        loginRegisterButton.addTarget(self, action: #selector(loginRegisterTapped), for: .touchUpInside)
        pageView.addSubview(loginRegisterButton)
    }
    
    @objc func visitorLoginTapped() {
        Auth.auth().signInAnonymously { result, error in
          guard error == nil else { return self.displayError(error) }
            let tabBarController = MainTabBarController()
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let sceneDelegate = windowScene.delegate as? SceneDelegate {
                let tabBarController = MainTabBarController()
                sceneDelegate.window?.rootViewController = tabBarController
                sceneDelegate.window?.makeKeyAndVisible()
            }
        }
    }
    
    @objc func loginRegisterTapped() {
        // Handle login and register action here
        let selectLoginVC = SelectLoginMethodViewController()
        navigationController?.pushViewController(selectLoginVC, animated: true)
    }
    
}
