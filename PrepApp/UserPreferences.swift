//
//  UserPreferences.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 19/08/15.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import UIKit
import LocalAuthentication

class UserPreferences {
    
    static var touchId: Bool = false
    static var sounds: Bool = true
    static var welcome: Bool = true
    
    static func touchID() {
        
        if !User.authenticated {
            if (User.instantiateUserStored()){
                if (UserPreferences.touchId) {
                    let authenticationObject = LAContext()
                    let authenticationError = NSErrorPointer()
                    authenticationObject.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: authenticationError)
                    
                    if authenticationError != nil {
                        //TouchID not available in this device
                        NSUserDefaults.standardUserDefaults().removeObjectForKey("user")
                        NSUserDefaults.standardUserDefaults().synchronize()
                        NSNotificationCenter.defaultCenter().postNotificationName("failed", object: nil)
                        
                    } else {
                        //TouchID available
                        authenticationObject.localizedFallbackTitle = ""
                        authenticationObject.evaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, localizedReason: "Posez votre doigt pour vous authentifier avec Touch ID", reply: { (complete:Bool, error: NSError?) -> Void in
                            if error != nil {
                                // There's an error. User likely pressed cancel.
                                print(error!.localizedDescription)
                                print("authentication failed")
                                NSNotificationCenter.defaultCenter().postNotificationName("failed", object: nil)
                                NSUserDefaults.standardUserDefaults().removeObjectForKey("user")
                                NSUserDefaults.standardUserDefaults().synchronize()
                            } else {
                                
                                if complete {
                                    // There's no error, the authentication completed successfully
                                    print("authentication successful")
                                    User.authenticated = true
                                    NSNotificationCenter.defaultCenter().postNotificationName("success", object: nil)
                                } else {
                                    // There's an error, the authentication didn't complete successfully
                                    print("authentication failed")
                                    NSUserDefaults.standardUserDefaults().removeObjectForKey("user")
                                    NSUserDefaults.standardUserDefaults().synchronize()
                                    NSNotificationCenter.defaultCenter().postNotificationName("failed", object: nil)
                                    
                                }
                            }
                        })
                    }
                }
            }
        }
    }
    
    static func saveUserPreferences() {
        //we backup the userPreferences in a boolean array for persistence storage
        
        let savedUserPreferences = [self.touchId, self.sounds, self.welcome]
        NSUserDefaults.standardUserDefaults().setObject(savedUserPreferences, forKey: "userPreferences")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    static func loadUserPreferences() {
        var data : [Bool] = []
        //we instantiate the user retrieved in the local Persistence Storage
        if let userPreferences = NSUserDefaults.standardUserDefaults().objectForKey("userPreferences") as? [Bool] {
            for element in userPreferences {
                data.append(element)
            }
            self.touchId = data[0]
            self.sounds = data[1]
            self.welcome = data[2]
        }
    }

}
