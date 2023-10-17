//
//  SelectLoginMethodViewController.swift
//  Sep769_project
//
//  Created by YuanlaiHe on 2023-10-12.
//

import UIKit
import FirebaseCore
import FirebaseAuth

// For Sign in with Google
// [START google_import]
import GoogleSignIn
// [END google_import]

class SelectLoginMethodViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor.systemGreen
        self.view.backgroundColor = .white
        
        // Title
        let titleLabel = UILabel(frame: CGRect(x: 20, y: 120, width: view.bounds.width - 40, height: 50))
        titleLabel.text = "Select Login Method"
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        view.addSubview(titleLabel)
        
        // Email and Password Login Button
        let emailLoginButton = UIButton(frame: CGRect(x: 20, y: titleLabel.frame.maxY + 40, width: view.bounds.width - 40, height: 50))
        setupButton(emailLoginButton, title: "Email Login", color: UIColor(red: 0.2, green: 0.75, blue: 0.3, alpha: 1.0))
        let loginIcon = UIImage(named: "loginIcon")
        emailLoginButton.setImage(loginIcon, for: .normal)
        emailLoginButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
        
        // Email and Password Register Button
        let emailRegisterButton = UIButton(frame: CGRect(x: 20, y: emailLoginButton.frame.maxY + 20, width: view.bounds.width - 40, height: 50))
        setupButton(emailRegisterButton, title: "Email Register", color: UIColor(red: 0.3, green: 0.85, blue: 0.4, alpha: 1.0))
        let registerIcon = UIImage(named: "registerIcon")
        emailRegisterButton.setImage(registerIcon, for: .normal)
        emailRegisterButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
        
        
        // Google Login Button
        let googleLoginButton = UIButton(frame: CGRect(x: 20, y: emailRegisterButton.frame.maxY + 20, width: view.bounds.width - 40, height: 50))
        
        setupButton(googleLoginButton, title: "Login with Google", color:UIColor(red: 0.4, green: 0.9, blue: 0.5, alpha: 1.0))
        // Adding Google Icon to the button
        let googleIcon = UIImage(named: "googleIcon")
        googleLoginButton.setImage(googleIcon, for: .normal)
        googleLoginButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
        
        
        emailLoginButton.addTarget(self, action: #selector(emailLoginTapped), for: .touchUpInside)
        emailRegisterButton.addTarget(self, action: #selector(emailRegisterTapped), for: .touchUpInside)
        googleLoginButton.addTarget(self, action: #selector(googleLoginTapped), for: .touchUpInside)
        
        
        view.addSubview(emailLoginButton)
        view.addSubview(emailRegisterButton)
        view.addSubview(googleLoginButton)
    }
    
    func setupButton(_ button: UIButton, title: String, color: UIColor) {
        button.backgroundColor = color
        button.setTitle(title, for: .normal)
        button.layer.cornerRadius = 25
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
    }
    
    @objc func emailLoginTapped() {
        // Navigate to email login screen
        let emailLoginVC = EmailLoginViewController()
        navigationController?.pushViewController(emailLoginVC, animated: true)
        print("Navigate to email login screen")
    }
    
    @objc func emailRegisterTapped() {
        // Navigate to email register screen
        let emailRegisterVC = EmailRegisterViewController()
        navigationController?.pushViewController(emailRegisterVC, animated: true)
        print("Navigate to email register screen")
    }
    
    @objc func googleLoginTapped() {
        // Implement Google login functionality
        // You would typically call Google Sign-In SDK methods here.
        print("Navigate to Google login screen")
        performGoogleSignInFlow()
    }
    
    private func performGoogleSignInFlow() {
      // [START headless_google_auth]
      guard let clientID = FirebaseApp.app()?.options.clientID else { return }

      // Create Google Sign In configuration object.
      // [START_EXCLUDE silent]
      // TODO: Move configuration to Info.plist
      // [END_EXCLUDE]
      let config = GIDConfiguration(clientID: clientID)
      GIDSignIn.sharedInstance.configuration = config

      // Start the sign in flow!
      GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
        guard error == nil else {
          // [START_EXCLUDE]
          return displayError(error)
          // [END_EXCLUDE]
        }

        guard let user = result?.user,
          let idToken = user.idToken?.tokenString
        else {
          // [START_EXCLUDE]
          let error = NSError(
            domain: "GIDSignInError",
            code: -1,
            userInfo: [
              NSLocalizedDescriptionKey: "Unexpected sign in result: required authentication data is missing.",
            ]
          )
          return displayError(error)
          // [END_EXCLUDE]
        }

        let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                       accessToken: user.accessToken.tokenString)

        // [START_EXCLUDE]
        signIn(with: credential)
        // [END_EXCLUDE]
      }
      // [END headless_google_auth]
    }
    
    func signIn(with credential: AuthCredential) {
      // [START signin_google_credential]
      Auth.auth().signIn(with: credential) { result, error in
        // [START_EXCLUDE silent]
        guard error == nil else { return self.displayError(error) }
        // [END_EXCLUDE]
          let tabBarController = MainTabBarController()
          if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
             let sceneDelegate = windowScene.delegate as? SceneDelegate {
              let tabBarController = MainTabBarController()
              sceneDelegate.window?.rootViewController = tabBarController
              sceneDelegate.window?.makeKeyAndVisible()
          }
          UserDefaults.standard.setValue(true, forKey: "isLoggedIn")
        
      }
      // [END signin_google_credential]
    }
}
