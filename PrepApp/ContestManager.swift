//
//  ContestManager.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 11/11/2015.
//  Copyright © 2015 PrepApp. All rights reserved.
//

import UIKit

class ContestManager {
    
    private var realm = FactoryRealm.getRealmContest()
    
    //API
    private func retrieveContestId(callback: (NSDictionary?) -> Void) {
        let request = NSMutableURLRequest(URL: FactorySync.contestUrl!)
        request.HTTPMethod = "POST"
        let postString = "mail=\(User.currentUser!.email)&pass=\(User.currentUser!.encryptedPassword)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            (data, response, error) in
            
            dispatch_async(dispatch_get_main_queue()) {
                if error != nil {
                    print("retrieveContestId offline")
                    callback(nil)
                } else {
                    let statusCode = (response as! NSHTTPURLResponse).statusCode
                    if statusCode == 200 {
                        let jsonResult = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                        
                        if let result = jsonResult {
                            callback(result)
                        } else {
                            print("error : NSArray nil in retrieveContestId")
                            callback(nil)
                        }
                    } else {
                        print("header status = \(statusCode) in retrieveContestId")
                        callback(nil)
                    }
                }
            }
            
        }
        task.resume()
    }
    
    private func retrieveContest(contest: Int, callback: (NSDictionary?) -> Void) {
        let url = NSURL(string: "\(FactorySync.contestUrl!)\(contest)")
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        let postString = "mail=\(User.currentUser!.email)&pass=\(User.currentUser!.encryptedPassword)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            (data, response, error) in
            
            dispatch_async(dispatch_get_main_queue()) {
                if error != nil {
                    print("contest offline")
                    callback(nil)
                } else {
                    let statusCode = (response as! NSHTTPURLResponse).statusCode
                    if statusCode == 200 {
                        let jsonResult = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                        
                        if let result = jsonResult {
                            callback(result)
                        } else {
                            print("error : NSArray nil in retrieveContest")
                            callback(nil)
                        }
                    } else {
                        print("header status = \(statusCode) in retrieveContest")
                        callback(nil)
                    }
                }
            }
            
        }
        task.resume()
    }

    
    //REALM
    func getContests(callback: (Contest?) -> Void) {
        self.retrieveContestId({ (data) -> Void in
            if let idContest = data {
                //online
                let id = idContest["id"] as! Int
                self.retrieveContest(id, callback: { (data) -> Void in
                    if let contest = data {
                        let result = Contest()
                        result.id = contest["id"] as! Int
                        result.duration = contest["duration"] as! Int
                        result.name = contest["name"] as! String
                        result.content = contest["description"] as! String
                        result.goodAnswer = contest["goodAnswer"] as! Float
                        result.wrongAnswer = contest["wrongAnswer"] as! Float
                        result.noAnswer = contest["noAnswer"] as! Float
                        result.begin = NSDate(timeIntervalSince1970: NSTimeInterval(contest["begin"] as! Int))
                        result.end = NSDate(timeIntervalSince1970: NSTimeInterval(contest["end"] as! Int))
                        try! self.realm.write({
                            self.realm.deleteAll()
                            self.realm.add(result)
                        })
                        callback(result)
                    } else {
                        //offline
                        let realm = self.realm.objects(Contest)
                        if realm.count == 1 {
                            callback(self.realm.objects(Contest).first!)
                        } else {
                            callback(nil)
                        }
                    }
                })
            } else {
                //offline
                let realm = self.realm.objects(Contest)
                if realm.count == 1 {
                    callback(self.realm.objects(Contest).first!)
                } else {
                    callback(nil)
                }

            }
        })
    }
    
}