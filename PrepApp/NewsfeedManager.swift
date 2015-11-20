//
//  NewsfeedManager.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 08/11/2015.
//  Copyright © 2015 PrepApp. All rights reserved.
//

import UIKit

class NewsfeedManager {
    
    private var realm = FactoryRealm.getRealm()
    
    //API
    private func retrieveNewsfeed(callback: (NSArray?) -> Void) {
        let request = NSMutableURLRequest(URL: FactorySync.newsfeedUrl!)
        request.HTTPMethod = "POST"
        request.timeoutInterval = NSTimeInterval(5)
        let postString = "mail=\(User.currentUser!.email)&pass=\(User.currentUser!.encryptedPassword)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            (data, response, error) in
            
            dispatch_async(dispatch_get_main_queue()) {
                if error != nil {
                    print("newsfeed offline")
                    callback(nil)
                } else {
                    let statusCode = (response as! NSHTTPURLResponse).statusCode
                    if statusCode == 200 {
                        let jsonResult = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSArray
                        
                        if let result = jsonResult {
                            callback(result)
                        } else {
                            print("error : NSArray nil in retrieveNewsfeed")
                            callback(nil)
                        }
                    } else {
                        print("header status = \(statusCode) in retrieveNewsfeed")
                        callback(nil)
                    }
                }
            }
            
        }
        task.resume()
    }
    
    //REALM
    func getNewsfeed(callback: ([News]) -> Void) {
        self.retrieveNewsfeed { (data) -> Void in
            var result = [News]()
            if let newsfeed = data {
                //online
                try! self.realm.write({ () -> Void in
                    self.realm.delete(self.realm.objects(News))
                })
                for data in newsfeed {
                    if let news = data as? NSDictionary {
                        let newPost = News()
                        newPost.id = news["id"] as! Int
                        newPost.title = news["title"] as! String
                        newPost.content = news["content"] as! String
                        newPost.date = NSDate(timeIntervalSince1970: NSTimeInterval(news["date"] as! Int))
                        if let authorData = news["author"] as? NSDictionary {
                            newPost.idAuthor = authorData["id"] as! Int
                            newPost.firstName = authorData["firstName"] as! String
                            newPost.lastName = authorData["lastName"] as! String
                            newPost.role = authorData["role"] as! Int
                        }
                        result.append(newPost)
                        try! self.realm.write({
                            self.realm.add(newPost)
                        })
                    }
                }
            } else {
                //offline
                let newsfeed = self.realm.objects(News)
                for news in newsfeed {
                    result.append(news)
                }
            }
            callback(result)
        }
    }

}
