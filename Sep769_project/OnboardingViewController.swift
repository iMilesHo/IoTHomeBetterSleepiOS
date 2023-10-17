//
//  OnboardingViewController.swift
//  Sep769_project
//
//  Created by YuanlaiHe on 2023-10-12.
//

import UIKit
import FirebaseCore
import FirebaseAuth

let welcomePageContent1 = " "
let welcomePageContent2 = "Temperature, humidity, and noise levels, all at your fingertips"
let welcomePageContent3 = "One-tap control to create a comfortable living environment"
let welcomePageContent4 = "Share your experience with us, and we'll continue to optimize for you"
let welcomePageContent5 = "Embrace the smart life at your fingertips"

class OnboardingViewController: UIViewController {
    
    var scrollView: UIScrollView!
    var pageControl: UIPageControl!
    var visitorLoginButton: UIButton!
    var loginRegisterButton: UIButton!
    
    let pages = [
        (title: "Welcome to the Smart Home Control Center", content: welcomePageContent1,imageName: "onboardingImage1"),
        (title: "Monitor your environment in real-time", content: welcomePageContent2,imageName: "onboardingImage2"),
        (title: "Easily control your humidifier", content: welcomePageContent3,imageName: "onboardingImage3"),
        (title: "We value your feedback", content: welcomePageContent4,imageName: "onboardingImage4"),
        (title: "Get started now", content: welcomePageContent5,imageName: "onboardingImage5"),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.navigationController?.navigationBar.tintColor = UIColor.white 

        setupScrollView()
        setupPageControl()
        
    }
    
    func setupScrollView() {
        scrollView = UIScrollView(frame: view.bounds)
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.delegate = self
        view.addSubview(scrollView)
        
        for (index, page) in pages.enumerated() {
            let pageView = UIView(frame: CGRect(x: CGFloat(index) * view.bounds.width, y: 0, width: view.bounds.width, height: view.bounds.height))
            
            //Image
            let imageView = UIImageView(frame: CGRect(x: 0, y: view.bounds.height * 0.15, width: view.bounds.width, height:view.bounds.height * 0.4))
            imageView.contentMode = .scaleAspectFit
            imageView.image = UIImage(named: page.imageName)
            pageView.addSubview(imageView)
            
            // Title
            let titleLabel = UILabel(frame: CGRect(x: 0, y: imageView.frame.maxY + 20, width: view.bounds.width, height: 60))
            titleLabel.text = page.title
            titleLabel.textAlignment = .center
            titleLabel.numberOfLines = 0  // Allows the label to wrap text across multiple lines
            titleLabel.lineBreakMode = .byWordWrapping  // Wraps words at the boundary
            titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
            pageView.addSubview(titleLabel)
            
            // Subtitle
            let subtitleLabel = UILabel(frame: CGRect(x: 20, y: titleLabel.frame.maxY+2, width: view.bounds.width - 40, height: 60)) // I've added some padding and a little vertical spacing between the title and subtitle
            subtitleLabel.text = page.content
            subtitleLabel.textAlignment = .center
            subtitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)  // Slightly smaller font for the subtitle
            subtitleLabel.numberOfLines = 0  // Allows the label to wrap text across multiple lines
            subtitleLabel.lineBreakMode = .byWordWrapping  // Wraps words at the boundary
            pageView.addSubview(subtitleLabel)
            
            if index == pages.count - 1 {  // Only for the last page
                let buttonWidth: CGFloat = (view.bounds.width - 60) / 2  // Subtracting 60 to account for padding and spacing between buttons
                let buttonHeight: CGFloat = 50
                let spacing: CGFloat = 20  // Spacing between buttons
                
                // Visitor Login Button
                visitorLoginButton = UIButton(frame: CGRect(x: 20, y: view.bounds.height * 0.85, width: buttonWidth, height: buttonHeight))
                visitorLoginButton.backgroundColor = UIColor(red: 0.3, green: 0.85, blue: 0.4, alpha: 1.0)  // A modern shade of green
                visitorLoginButton.setTitle("Visitor Login", for: .normal)
                visitorLoginButton.layer.cornerRadius = 25  // Rounded corners
                visitorLoginButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
                visitorLoginButton.addTarget(self, action: #selector(visitorLoginTapped), for: .touchUpInside)
                //                visitorLoginButton.isHidden = true
                visitorLoginButton.alpha = 0
                pageView.addSubview(visitorLoginButton)
                
                // Login & Register Button
                loginRegisterButton = UIButton(frame: CGRect(x: visitorLoginButton.frame.maxX + spacing, y: view.bounds.height * 0.85, width: buttonWidth, height: buttonHeight))
                loginRegisterButton.backgroundColor = UIColor(red: 0.2, green: 0.75, blue: 0.3, alpha: 1.0)  // A slightly darker shade of green for contrast
                loginRegisterButton.setTitle("Login/Register", for: .normal)
                loginRegisterButton.layer.cornerRadius = 25  // Rounded corners
                loginRegisterButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
                loginRegisterButton.addTarget(self, action: #selector(loginRegisterTapped), for: .touchUpInside)
                //                loginRegisterButton.isHidden = true
                loginRegisterButton.alpha = 0
                pageView.addSubview(loginRegisterButton)
            }
            
            
            
            scrollView.addSubview(pageView)
        }
        
        scrollView.contentSize = CGSize(width: view.bounds.width * CGFloat(pages.count), height: view.bounds.height)
    }
    
    func setupPageControl() {
        pageControl = UIPageControl(frame: CGRect(x: 0, y: view.bounds.height * 0.75, width: view.bounds.width, height: 50))
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.addTarget(self, action: #selector(pageControlChanged), for: .valueChanged)
        view.addSubview(pageControl)
    }
    
    @objc func pageControlChanged() {
        let currentPage = pageControl.currentPage
        scrollView.setContentOffset(CGPoint(x: CGFloat(currentPage) * view.bounds.width, y: 0), animated: true)
    }
    
    @objc func visitorLoginTapped() {
        // Handle visitor login action here
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

extension OnboardingViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentPage = Int(scrollView.contentOffset.x / view.bounds.width)
        pageControl.currentPage = currentPage
        
        let pageIndex = round(scrollView.contentOffset.x / view.bounds.width)
        if pageIndex == CGFloat(pages.count - 1) {
            UserDefaults.standard.set(true, forKey: "hasShownOnboarding")
            UIView.animate(withDuration: 0.5) {
                self.visitorLoginButton.alpha = 1
                self.loginRegisterButton.alpha = 1
            }
        } else {
            UIView.animate(withDuration: 0.1) {
                self.visitorLoginButton.alpha = 0
                self.loginRegisterButton.alpha = 0
            }
        }
        
    }
    
}
