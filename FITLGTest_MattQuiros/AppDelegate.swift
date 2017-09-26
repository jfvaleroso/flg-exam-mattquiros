//
//  AppDelegate.swift
//  FITLGTest_MattQuiros
//
//  Created by Matt Quiros on 19/09/2017.
//  Copyright © 2017 Matt Quiros. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let keyWindow = UIWindow(frame: UIScreen.main.bounds)
        keyWindow.rootViewController = UINavigationController(rootViewController: HomeViewController())
        keyWindow.makeKeyAndVisible()
        window = keyWindow
        return true
    }
    
}

