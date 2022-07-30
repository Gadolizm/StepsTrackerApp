//
//  AppDelegate.swift
//  StepsTrackerApp
//
//  Created by Gado on 19/07/2022.
//

import UIKit
import GoogleMaps
import FirebaseCore
import FirebaseFirestore


@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        GMSServices.provideAPIKey("AIzaSyAmQXfv96FE-nFEVyaeYa4E495NNFOb3ew")
        FirebaseApp.configure()

        UserDefaults.standard.set(Date(), forKey: "latestLaunchDate")
        // your code
        print("didFinishLaunchingWithOptions")

        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        UserDefaults.standard.removeObject(forKey: "latestLaunchDate")
        print("applicationWillTerminate")

    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        print("applicationWillResignActive")

    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("applicationDidEnterBackground")
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

