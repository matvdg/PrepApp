//
//  DatabaseVersion.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 20/08/15.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//


import UIKit

class ConfigManager {
    
    func saveConfig() {
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
                NSUserDefaults.standardUserDefaults().setObject(nicknameAllowed, forKey: "nicknameAllowed")
                NSUserDefaults.standardUserDefaults().synchronize()
                println("config saved")

            }
        })
    }
    
    func saveVersion(version: Int) {
        //we backup the DatabaseVersion for persistence storage
        NSUserDefaults.standardUserDefaults().setObject(version, forKey: "version")
        NSUserDefaults.standardUserDefaults().synchronize()
        println("version saved")
    }
    
    func loadVersion() -> Int {
        var data : [Int] = []
        //we instantiate the user retrieved in the local Persistence Storage
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
                        println("error : != 200 in getConfig")
                        callback(nil)
                    }
                    
                }
            }
        }
        task.resume()
        
        
    }
    
    func getLastVersion(callback: (Int?) -> Void) {
        let urlRequest = NSURLRequest(URL: FactorySync.configUrl!)
        NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
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
                        println("error parsing json")
                    } else {
                        if let integer = result["version"] as? Int {
                        callback(integer)
                    } else {
                        callback(nil)
                        println("error no current key")
                        }
                            }
                        } else {
                            callback(nil)
                            println("error casting json into NSDictionary")
                    }
                    
                } else {
                    callback(nil)
                    println("header status != 200")
                }
            }
        }
    }


    
}
