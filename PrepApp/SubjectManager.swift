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
            for subject in subjects! {
                self.saveSubject(subject as! NSDictionary)
            }
            println("subjects downloaded")
            Factory.getChapterManager().saveChapters()
            
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
    
    private func getSubjects(callback: (NSArray?) -> Void) {
        let request = NSMutableURLRequest(URL: Factory.subjectUrl!)
        request.HTTPMethod = "POST"
        let postString = "mail=\(User.currentUser!.email)&pass=\(User.currentUser!.encryptedPassword)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            (data, response, error) in
            
            dispatch_async(dispatch_get_main_queue()) {
                if error != nil {
                    println("error : no connexion in getSubjects")
                    Factory.errorNetwork = true
                } else {
                    
                    var err: NSError?
                    var statusCode = (response as! NSHTTPURLResponse).statusCode
                    if statusCode == 200 {
                        var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as? NSArray
                        
                        if let result = jsonResult {
                            if err != nil {
                                println("error : parsing JSON in getSubjects")
                                Factory.errorNetwork = true
                            } else {
                                callback(result as NSArray)
                            }
                        } else {
                            println("error : NSArray nil in getSubjects")
                            Factory.errorNetwork = true
                        }
                        
                        
                    } else {
                        println("error : != 200 in getSubjects")
                        Factory.errorNetwork = true
                    }
                    
                }
            }
        }
        task.resume()
        
        
    }
    
    
}