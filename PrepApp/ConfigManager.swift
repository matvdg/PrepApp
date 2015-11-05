//
//  ConfigManager.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 20/08/15.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//


import UIKit

class ConfigManager {
    
    func saveConfig(callback: (Bool) -> Void) {
        self.getConfig({ (config) -> Void in
            if let config: NSDictionary = config {
                let date = NSDate(timeIntervalSince1970: NSTimeInterval(Int((config["dateExam"] as! String))!))
                let weeksBeforeExam = Int((config["weeksBeforeExam"] as! String))!
                let nicknameAllowed = (config["nickname"] as! String).toBool()!
                let duration = Int((config["challengeDuration"] as! String))!
                
                //we backup the config for persistence storage
                NSUserDefaults.standardUserDefaults().setObject(date, forKey: "date")
                NSUserDefaults.standardUserDefaults().setObject(weeksBeforeExam, forKey: "weeksBeforeExam")
                NSUserDefaults.standardUserDefaults().setObject(nicknameAllowed, forKey: "nicknamePreference")
                NSUserDefaults.standardUserDefaults().setObject(duration, forKey: "duration")
                NSUserDefaults.standardUserDefaults().synchronize()
                callback(true)
            } else {
                callback(false)
            }
        })
    }
    
    func saveVersion(version: Int) {
        //we backup the DatabaseVersion for persistence storage
        NSUserDefaults.standardUserDefaults().setObject(version, forKey: "version")
        NSUserDefaults.standardUserDefaults().synchronize()
        print("version saved")
    }
    
    func saveCurrentDay(currentDay: Int) {
        //we backup the currentDay for persistence storage
        NSUserDefaults.standardUserDefaults().setObject(currentDay, forKey: "currentDay")
        NSUserDefaults.standardUserDefaults().synchronize()
        print("currentDay saved")
    }
    
    func loadDate() -> String {
        //we retrieve the date from the local Persistence Storage
        if let date : AnyObject = NSUserDefaults.standardUserDefaults().objectForKey("date") {
            if let result = date as? NSDate {
                let formatter = NSDateFormatter()
                formatter.dateFormat = "dd/MM/yyyy"
                let dateInString = formatter.stringFromDate(result)
                return dateInString
            } else {
                return "Error: date in the wrong format"
            }
            
        } else {
            return "Error: date has never been downloaded from server"
        }        
    }
    
    func loadWeeksBeforeExam() -> Int {
        var result: Int
        //we retrieve the weeksBeforeExam from the local Persistence Storage
        if let weeksBeforeExam : AnyObject = NSUserDefaults.standardUserDefaults().objectForKey("weeksBeforeExam") {
            if let result = weeksBeforeExam as? Int {
                return result
            } else {
                result = -1
            }
                
        } else {
            result = -1
        }
        return result
    }
    
    func loadDuration() -> Int {
        var result: Int
        //we retrieve the duration from the local Persistence Storage
        if let duration : AnyObject = NSUserDefaults.standardUserDefaults().objectForKey("duration") {
            if let result = duration as? Int {
                return result
            } else {
                result = -1
            }
            
        } else {
            result = -1
        }
        return result
    }
    
    func loadCurrentDay() -> Int {
        var result: Int
        //we retrieve the currentDay retrieved from the local Persistence Storage
        if let currentDay : AnyObject = NSUserDefaults.standardUserDefaults().objectForKey("currentDay") {
            if let result = currentDay as? Int {
                return result
            } else {
                result = -1
            }
            
        } else {
            result = -1
        }
        return result
    }

    ///return true if nickname allowed (Bool)
    func loadNicknamePreference() -> Bool {
        //we retrieve the nicknamePreference from the local Persistence Storage
        if let nicknamePreference : AnyObject = NSUserDefaults.standardUserDefaults().objectForKey("nicknamePreference") {
            if let result = nicknamePreference as? Bool {
                return result
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    ///return version number (Int)
    func loadVersion() -> Int {
        //we retrieve the version from the local Persistence Storage
        if let version : AnyObject = NSUserDefaults.standardUserDefaults().objectForKey("version") {
            return version as! Int
        } else {
            return 0
        }
    }
    
    private func getConfig(callback: (NSDictionary?) -> Void) {
        let request = NSMutableURLRequest(URL: FactorySync.configUrl!)
        request.HTTPMethod = "POST"
        let postString = "mail=\(User.currentUser!.email)&pass=\(User.currentUser!.encryptedPassword)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            (data, response, error) in
            
            dispatch_async(dispatch_get_main_queue()) {
                if error != nil {
                    print("error : no connexion in getConfig")
                    callback(nil)
                } else {
                    
                    let statusCode = (response as! NSHTTPURLResponse).statusCode
                    if statusCode == 200 {
                        let jsonResult = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                        
                        if let result = jsonResult {
                            callback(result)
                        } else {
                            print("error : NSDictionary nil in getConfig")
                            callback(nil)
                        }
                        
                        
                    } else {
                        print("header status = \(statusCode)  in getConfig")
                        callback(nil)
                    }
                    
                }
            }
        }
        task.resume()
    }
    
    func getLastVersion(callback: (Int?) -> Void) {
        let request = NSMutableURLRequest(URL: FactorySync.versionUrl!)
        request.HTTPMethod = "POST"
        let postString = "mail=\(User.currentUser!.email)&pass=\(User.currentUser!.encryptedPassword)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            (data, response, error) in
            
            dispatch_async(dispatch_get_main_queue()) {
                if error != nil {
                    print("error : no connexion in getLastVersion")
                    callback(nil)
                } else {
                    let statusCode = (response as! NSHTTPURLResponse).statusCode
                    if statusCode == 200 {
                        let jsonResult = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as? NSString
                        
                        if let result = jsonResult as? String {
                            callback(Int(result)!)
                        } else {
                            print("error : NSDictionary nil in getLastVersion")
                            callback(nil)
                        }
                        
                        
                    } else {
                        print("header status = \(statusCode)  in getLastVersion")
                        callback(nil)
                    }
                    
                }
            }
        }
        task.resume()
    }
    
}
