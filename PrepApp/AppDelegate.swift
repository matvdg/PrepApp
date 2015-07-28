//
//  AppDelegate.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 02/05/15.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import UIKit
import LocalAuthentication

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?


	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		return true
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
            if (User.currentUser!.touchId) {
                User.authenticated = false
                //we protect the app as Touch ID is enabled
            }
        }

        
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(application: UIApplication) {
    
        //println("applicationWillEnterForeground")
		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(application: UIApplication) {
        //println("applicationDidBecomeActive")
        self.touchID()
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	func applicationWillTerminate(application: UIApplication) {
        //println("applicationWillTerminate")
        // we first check if Touch ID protection is enabled
        if (User.instantiateUserStored()){
            if (User.currentUser!.touchId) {
                User.authenticated = false
                //we protect the app as Touch ID is enabled
            }
        }
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}
    
    func touchID() {
        //println("Touch ID function")
        println(User.authenticated)
        if !User.authenticated {
            if (User.instantiateUserStored()){
                if (User.currentUser!.touchId) {
                    var authenticationObject = LAContext()
                    var authenticationError: NSError?
                    
                    
                    authenticationObject.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: &authenticationError)
                    
                    if authenticationError != nil {
                        println("TouchID not available in this device")
                        NSUserDefaults.standardUserDefaults().removeObjectForKey("user")
                        NSUserDefaults.standardUserDefaults().synchronize()

                    } else {
                        println("TouchID available")
                        authenticationObject.localizedFallbackTitle = ""
                        authenticationObject.evaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, localizedReason: "Posez votre doigt pour vous authentifier avec Touch ID", reply: { (complete:Bool, error: NSError!) -> Void in
                            if error != nil {
                                // There's an error. User likely pressed cancel.
                                println(error.localizedDescription)
                                println("authentication failed")
                                NSUserDefaults.standardUserDefaults().removeObjectForKey("user")
                                NSUserDefaults.standardUserDefaults().synchronize()
                            } else {
                                // There's no error, the authentication completed successfully
                                if complete {
                                    println("authentication successful")
                                    User.authenticated = true
                                    println(User.authenticated)
                                } else {
                                    println("authentication failed")
                                    NSUserDefaults.standardUserDefaults().removeObjectForKey("user")
                                    NSUserDefaults.standardUserDefaults().synchronize()

                                    
                                }
                            }
                        })
                    }
                    
                }
            }
        }
        
        
    }
    
    
        
}

