//
//  AppDelegate.swift
//  weather
//
//  Created by Telekom MK on 7/22/19.
//  Copyright © 2019 petar. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        if UserDefaults.standard.object(forKey: "cities") == nil{
            let cities : [String:String] = ["Sofia":"839722",
                                            "New York":"2459115",
                                            "Tokyo":"1118370"]
            
            UserDefaults.standard.set(cities, forKey: "cities")
        }
        
        if UserDefaults.standard.object(forKey: "lastCity") == nil{
            UserDefaults.standard.set("Sofia", forKey: "lastCity")
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }


}

