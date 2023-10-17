//
//  AppDelegate.swift
//  Sep769_project
//
//  Created by YuanlaiHe on 2023-10-07.
//

import UIKit
import FirebaseCore
import FBSDKCoreKit
import GoogleSignIn

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // [START firebase_configure]
        FirebaseApp.configure()
        // [END firebase_configure]
        
        ApplicationDelegate.shared.application(
          application,
          didFinishLaunchingWithOptions: launchOptions
        )
        
        return true
    }
    
    // [START application_open]
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
      // [END application_open]
      if GIDSignIn.sharedInstance.handle(url) {
        return true
      }
      return ApplicationDelegate.shared.application(
        app,
        open: url,
        sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
        annotation: options[UIApplication.OpenURLOptionsKey.annotation]
      )
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    private func configureApplicationAppearance() {
      UINavigationBar.appearance().tintColor = .systemGreen
      UITabBar.appearance().tintColor = .systemGreen
    }
}

