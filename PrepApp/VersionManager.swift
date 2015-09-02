//
//  DatabaseVersion.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 20/08/15.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//


import UIKit

class VersionManager {
    
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
    
    func getLastVersion(callback: (Int?) -> Void) {
        let urlRequest = NSURLRequest(URL: Factory.versionUrl!)
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
                            if let integer = result["current"] as? Int {
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
