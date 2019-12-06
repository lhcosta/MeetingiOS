//
//  AppDelegate.swift
//  MeetingiOS
//
//  Created by Bernardo Nunes on 21/11/19.
//  Copyright © 2019 Bernardo Nunes. All rights reserved.
//

import UIKit
import CoreData
import CloudKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //Pular tela login caso usuário já esteja logado
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
//        if let _ = UserDefaults.standard.string(forKey: "recordName") {
//            let storyboard = UIStoryboard(name: "MyMeetings", bundle: nil)
//            let rootVC = storyboard.instantiateInitialViewController() as! MyMeetingsViewController
//            let navController = UINavigationController(rootViewController: rootVC)
//            self.window?.rootViewController = navController
//        } else {
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let rootVC = storyboard.instantiateInitialViewController() as! LoginViewController
//            let navController = UINavigationController(rootViewController: rootVC)
//            self.window?.rootViewController = navController
//        }
//        
        self.window?.makeKeyAndVisible()
        
        // Override point for customization after application launch.
        let userNotCenter = UNUserNotificationCenter.current()
        userNotCenter.delegate = self
        
        userNotCenter.requestAuthorization(options: [.providesAppNotificationSettings], completionHandler: { (permission, error) in
            print("===>\(permission)/\(String(describing: error))")
        })
        
        DispatchQueue.main.async {
            application.registerForRemoteNotifications()
        }
        return true
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
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        guard let CloudNot = CKQueryNotification(fromRemoteNotificationDictionary: notification.request.content.userInfo) else { return }
        
    }
}
