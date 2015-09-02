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


	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "rotated", name: UIDeviceOrientationDidChangeNotification, object: nil)
		return true
	}
    
    func rotated()
    {
        if(UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation))
        {
            NSNotificationCenter.defaultCenter().postNotificationName("landscape", object: nil)
        }
        
        if(UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation))
        {
            NSNotificationCenter.defaultCenter().postNotificationName("portrait", object: nil)
        }
        
    }

	func applicationWillResignActive(application: UIApplication) {
        //println("applicationWillResignActive")
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(application: UIApplication) {
        //println("applicationDidEnterBackground")
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
    
        //println("applicationWillEnterForeground")
        UserPreferences.touchID()
        Factory.offlineMode = false
        Factory.getVersionManager().getLastVersion { (version) -> Void in
            if let versionDB: Int = version { //checking if sync is needed
                println("localVersion = \(Factory.getVersionManager().loadVersion()) dbVersion = \(versionDB)")
                if Factory.getVersionManager().loadVersion() != versionDB { //prompting a sync
                    NSNotificationCenter.defaultCenter().postNotificationName("update", object: nil)
                }
            }
        }

		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
	}

	func applicationDidBecomeActive(application: UIApplication) {
        //println("applicationDidBecomeActive")
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
	}

	func applicationWillTerminate(application: UIApplication) {
        //println("applicationWillTerminate")
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

