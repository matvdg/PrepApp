//
//  SubjectManager.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 21/07/15.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import UIKit
import RealmSwift


class SubjectManager {
    
    let realm = FactoryRealm.getRealm()
    
    func saveSubjects() {
        self.getSubjects({ (subjects) -> Void in
            var empty = true
            for subject in subjects {
                empty = false
                self.saveSubject(subject as! NSDictionary)
            }
            if empty {
                FactorySync.errorNetwork = true
            } else {
                println("subjects downloaded")
                FactorySync.getChapterManager().saveChapters()
            }
        })
    }
    
    private func saveSubject(data: NSDictionary) {
        
        var newSubject = Subject()
        newSubject.id =  data["id"] as! Int
        newSubject.name = data["name"] as! String
        self.realm.write {
            self.realm.add(newSubject)
        }
    }
    
    private func getSubjects(callback: (NSArray) -> Void) {
        let request = NSMutableURLRequest(URL: FactorySync.subjectUrl!)
        request.HTTPMethod = "POST"
        let postString = "mail=\(User.currentUser!.email)&pass=\(User.currentUser!.encryptedPassword)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            (data, response, error) in
            
            dispatch_async(dispatch_get_main_queue()) {
                if error != nil {
                    println("error : no connexion in getSubjects")
                    FactorySync.errorNetwork = true
                } else {
                    
                    var err: NSError?
                    var statusCode = (response as! NSHTTPURLResponse).statusCode
                    if statusCode == 200 {
                        var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as? NSArray
                        
                        if let result = jsonResult {
                            if err != nil {
                                println("error : parsing JSON in getSubjects")
                                FactorySync.errorNetwork = true
                            } else {
                                callback(result)
                            }
                        } else {
                            println("error : NSArray nil in getSubjects")
                            FactorySync.errorNetwork = true
                        }
                        
                        
                    } else {
                        println("error : != 200 in getSubjects")
                        FactorySync.errorNetwork = true
                    }
                    
                }
            }
        }
        task.resume()
        
        
    }
    
    
}