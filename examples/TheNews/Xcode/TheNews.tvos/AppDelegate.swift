//
//  AppDelegate.swift
//  TheNews.tvos
//
//  Created by Daniel on 4/26/20.
//  Copyright © 2020 dk. All rights reserved.
//

import UIKit
import SnowplowTracker

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        let tabController = TvTabBarController()

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = tabController
        window?.makeKeyAndVisible()

        /*
        let remoteConfig = RemoteConfiguration(endpoint: <REMOTE_CONFIG_URL>, method: .get)
        Snowplow.setup(remoteConfiguration: remoteConfig, defaultConfiguration: nil) { namespaces in
            print(namespaces ?? "Good luck!")
        }
        */
        
        Snowplow.createTracker(namespace: "defaultTracker", endpoint: "http://192.168.99.101:9090", method: .get);
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }


}
