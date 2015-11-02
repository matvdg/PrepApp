//
//  AppDelegate.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 02/05/15.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
    var portrait: Bool = true

	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "rotated", name: UIDeviceOrientationDidChangeNotification, object: nil)
		return true
	}
    
    func rotated(){
        if UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation)
        {
            if self.portrait {
                self.portrait = false
                NSNotificationCenter.defaultCenter().postNotificationName("landscape", object: nil)
            }
            
        }
        
        if UIDevice.currentDevice().orientation == UIDeviceOrientation.Portrait
        {
            if !self.portrait {
                self.portrait = true
                NSNotificationCenter.defaultCenter().postNotificationName("portrait", object: nil)

            }
        }
    }

	func applicationWillResignActive(application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(application: UIApplication) {
        // we first check if Touch ID protection is enabled
        if (User.instantiateUserStored()){
            if (UserPreferences.touchId) {
                User.authenticated = false
                //we protect the app as Touch ID is enabled
            }
        }
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(application: UIApplication) {
        UserPreferences.touchID()
        FactorySync.offlineMode = false
        FactorySync.getConfigManager().getLastVersion { (version) -> Void in
            if let versionDB: Int = version { //checking if sync is needed
                FactorySync.getConfigManager().saveConfig({ (result) -> Void in
                    if result {
                        print("config saved")
                        FactoryHistory.getHistory().sync()
                    } else {
                        print("error loading config, working with local config")
                    }
                })
                print("AppDelegate localVersion = \(FactorySync.getConfigManager().loadVersion()) dbVersion = \(versionDB)")
                if FactorySync.getConfigManager().loadVersion() != versionDB { //prompting a sync
                    NSNotificationCenter.defaultCenter().postNotificationName("update", object: nil)
                }
            }
        }

		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
	}

	func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
	}

	func applicationWillTerminate(application: UIApplication) {
        // we first check if Touch ID protection is enabled
        
        if (User.instantiateUserStored()){
            
            if (UserPreferences.touchId) {
                User.authenticated = false
                //we protect the app as Touch ID is enabled
            }
        }
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}
    
    
}

