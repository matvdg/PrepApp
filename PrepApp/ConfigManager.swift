//
//  DatabaseVersion.swift
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
                var date = NSDate(timeIntervalSince1970: NSTimeInterval((config["date_exam"] as! String).toInt()!))
                println(date)
                var weeksBeforeExam = (config["weeks_before_exam"] as! String).toInt()!
                println(weeksBeforeExam)
                var nicknameAllowed = (config["nickname"] as! String).toBool()!
                println(nicknameAllowed)
                
                //we backup the config for persistence storage
                NSUserDefaults.standardUserDefaults().setObject(date, forKey: "date")
                NSUserDefaults.standardUserDefaults().setObject(weeksBeforeExam, forKey: "weeksBeforeExam")
                NSUserDefaults.standardUserDefaults().setObject(nicknameAllowed, forKey: "nicknamePreference")
                NSUserDefaults.standardUserDefaults().synchronize()
                println("config saved")
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
        println("version saved")
    }
    
    func loadDate() -> String {
        var result: NSDate?
        //we retrieve the date from the local Persistence Storage
        if let date : AnyObject = NSUserDefaults.standardUserDefaults().objectForKey("date") {
            if let result = date as? NSDate {
                var formatter = NSDateFormatter()
                formatter.dateFormat = "dd/MM/yyyy"
                var dateInString = formatter.stringFromDate(result)
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
    
    func saveCurrentDay(currentDay: Int) {
        //we backup the currentDay for persistence storage
        NSUserDefaults.standardUserDefaults().setObject(currentDay, forKey: "currentDay")
        NSUserDefaults.standardUserDefaults().synchronize()
        println("currentDay saved")
    }

    func loadNicknamePreference() -> Bool? {
        //we retrieve the nicknamePreference from the local Persistence Storage
        if let nicknamePreference : AnyObject = NSUserDefaults.standardUserDefaults().objectForKey("nicknamePreference") {
            return nicknamePreference as? Bool
        } else {
            return nil
        }
    }
    
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
                    println("error : no connexion in getConfig")
                    callback(nil)
                } else {
                    
                    var err: NSError?
                    var statusCode = (response as! NSHTTPURLResponse).statusCode
                    if statusCode == 200 {
                        var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as? NSDictionary
                        
                        if let result = jsonResult {
                            if err != nil {
                                println("error : parsing JSON in getConfig")
                                callback(nil)
                            } else {
                                callback(result)
                            }
                        } else {
                            println("error : NSDictionary nil in getConfig")
                            callback(nil)
                        }
                        
                        
                    } else {
                        println("header status = \(statusCode)  in getConfig")
                        callback(nil)
                    }
                    
                }
            }
        }
        task.resume()
        
        
    }
    
    func getLastVersion(callback: (Int?) -> Void) {
        let request = NSMutableURLRequest(URL: FactorySync.configUrl!)
        request.HTTPMethod = "POST"
        let postString = "mail=\(User.currentUser!.email)&pass=\(User.currentUser!.encryptedPassword)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)

        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            if error != nil {
                callback(nil)
                println("no connexion")
            } else {
                var err: NSError?
                var statusCode = (response as! NSHTTPURLResponse).statusCode
                if statusCode == 200 {
                    var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as? NSDictionary
                    
                    if let result = jsonResult {
                        if err != nil {
                            callback(nil)
                            println("error parsing json in getLastVersion")
                        } else {
                            if let version = result["version"] as? String {
                                callback(version.toInt()!)
                            } else {
                                callback(nil)
                                println("error no version key in getLastVersion")
                            }
                        }
                    } else {
                        callback(nil)
                        println("error casting json into NSDictionary in getLastVersion")
                    }
                } else {
                    callback(nil)
                    println("header status = \(statusCode) in getLastVersion")
                }
            }
        }
    }


    
}
