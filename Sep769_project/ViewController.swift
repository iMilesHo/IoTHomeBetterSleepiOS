//
//  ViewController.swift
//  Sep769_project
//
//  Created by YuanlaiHe on 2023-10-07.
//

import UIKit
import HealthKit


// Create UITabBarController
class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. 设置TabBar的背景色
        tabBar.barTintColor = UIColor.white
        
        // 2. 设置TabBar的选中颜色
        tabBar.tintColor = .systemGreen
        
        // 3. 设置TabBar的阴影
        tabBar.layer.shadowColor = UIColor.gray.cgColor
        tabBar.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        tabBar.layer.shadowRadius = 10
        tabBar.layer.shadowOpacity = 0.3
        tabBar.layer.masksToBounds = false
        
        let environmentVC = UINavigationController(rootViewController: DashboardViewController())
        environmentVC.tabBarItem = UITabBarItem(title: "Environment", image: UIImage(systemName: "house"), selectedImage: nil)
        
        let deviceControlVC = UINavigationController(rootViewController: DeviceControlViewController())
        deviceControlVC.tabBarItem = UITabBarItem(title: "Control", image: UIImage(systemName: "slider.horizontal.3"), selectedImage: nil)
        
        let feedbackVC = UINavigationController(rootViewController: FeedbackViewController())
        feedbackVC.tabBarItem = UITabBarItem(title: "Feedback", image: UIImage(systemName: "bubble.right"), selectedImage: nil)
        
        let userInfoVC = UINavigationController(rootViewController: UserViewController())
        userInfoVC.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person.circle"), selectedImage: nil)
        
        viewControllers = [environmentVC, deviceControlVC, feedbackVC, userInfoVC]
    }
}


