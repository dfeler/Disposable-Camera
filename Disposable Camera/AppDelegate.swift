//
//  AppDelegate.swift
//  Disposable Camera
//
//  Created by Daniel Feler


import UIKit
import AVKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var orientationLock = UIInterfaceOrientationMask.landscape



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Override poit for customization after application launch.
        return true
    }
    
    

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
            return self.orientationLock
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
       
        
        NotificationCenter.default.post(name: Notification.Name("Background"), object: nil)
    }
//    func applicationDidBecomeActive(_ application: UIApplication) {
//        <#code#>
//    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
                 NotificationCenter.default.post(name: Notification.Name("Foreground"), object: nil) 

    }
    

    

}

