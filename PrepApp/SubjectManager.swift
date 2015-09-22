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
    var counter = 0
    
    func saveSubjects() {
        self.counter = 0
        self.getSubjects({ (data) -> Void in
            var onlineSubjects = [Subject]()
            // dictionary
            for (id, version) in data {
                let subject = Subject()
                subject.id = (id as! String).toInt()!
                subject.version = (version as! Int)
                onlineSubjects.append(subject)
            }
            self.compare(onlineSubjects)
        })
    }
    
    private func getSubjects(callback: (NSDictionary) -> Void) {
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
                        var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as? NSDictionary
                        
                        if let result = jsonResult {
                            if err != nil {
                                println("error : parsing JSON in getSubjects")
                                FactorySync.errorNetwork = true
                            } else {
                                callback(result as NSDictionary)
                            }
                        } else {
                            println("error : NSArray nil in getSubjects")
                            FactorySync.errorNetwork = true
                        }
                        
                        
                    } else {
                        println("header status = \(statusCode) in getSubjects")
                        FactorySync.errorNetwork = true
                    }
                }
            }
            
        }
        task.resume()
    }
    
    private func compare(onlineSubjects: [Subject]){
        
        // Query a Realm
        let offlineSubjects = self.realm.objects(Subject)
        
        // we check what has been removed
        var idsToRemove = [Int]()
        for offlineSubject in offlineSubjects {
            var willBeRemoved = true
            for onlineSubject in onlineSubjects {
                if onlineSubject.id == offlineSubject.id {
                    willBeRemoved = false
                }
            }
            if willBeRemoved {
                idsToRemove.append(offlineSubject.id)
            }
        }
        self.deleteSubjects(idsToRemove)
        
        // we check what has been updated
        var idsToUpdate = [Int]()
        for offlineSubject in offlineSubjects {
            var willBeUpdated = true
            for onlineSubject in onlineSubjects {
                if onlineSubject.id == offlineSubject.id && onlineSubject.version == offlineSubject.version {
                    willBeUpdated = false
                }
            }
            if willBeUpdated {
                idsToUpdate.append(offlineSubject.id)
            }
        }
        self.updateSubjects(idsToUpdate)
        self.counter += idsToUpdate.count
        
        // we check what we have to add
        var idsToAdd = [Int]()
        for onlineSubject in onlineSubjects {
            var willBeAdded = true
            for offlineSubject in offlineSubjects {
                if onlineSubject.id == offlineSubject.id {
                    willBeAdded = false
                }
            }
            if willBeAdded {
                idsToAdd.append(onlineSubject.id)
            }
        }
        self.saveSubjects(idsToAdd)
        self.counter += idsToAdd.count
        if self.counter == 0 {
            println("subjects: nothing new to sync")
            FactorySync.getChapterManager().saveChapters()
        }
        
    }
    
    private func deleteSubjects(idsToRemove: [Int]){
        for idToRemove in idsToRemove {
            if FactorySync.errorNetwork == false {
                var objectToRemove = realm.objects(Subject).filter("id=\(idToRemove)")
                self.realm.write {
                    self.realm.delete(objectToRemove)
                }
            }
        }
    }
    
    private func updateSubjects(idsToUpdate: [Int]){
        for idToUpdate in idsToUpdate {
            if FactorySync.errorNetwork == false {
                self.getSubject(idToUpdate, callback: { (subjectData) -> Void in
                    let subjects = self.realm.objects(Subject)
                    for subject in subjects {
                        if subject.id == idToUpdate {
                            self.realm.write {
                                subject.name = subjectData["name"] as! String
                                subject.ratio = subjectData["ratio"] as! Int
                                subject.timePerQuestion = subjectData["timePerQuestion"] as! Int
                                subject.version = subjectData["version"] as! Int
                            }
                        }
                    }
                })
            }
        }
    }
    
    private  func saveSubjects(idsToAdd: [Int]){
        for idToAdd in idsToAdd {
            if FactorySync.errorNetwork == false {
                self.getSubject(idToAdd, callback: { (subjectData) -> Void in
                    var newSubject = Subject()
                    newSubject.id =  subjectData["id"] as! Int
                    newSubject.name = subjectData["name"] as! String
                    newSubject.version = subjectData["version"] as! Int
                    newSubject.ratio = subjectData["ratio"] as! Int
                    newSubject.timePerQuestion = subjectData["timePerQuestion"] as! Int
                    self.realm.write {
                        self.realm.add(newSubject)
                    }
                })
            }
        }
    }
    
    private func getSubject(id: Int, callback: (NSDictionary) -> Void) {
        let url = NSURL(string: "\(FactorySync.subjectUrl!)\(id)")
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        let postString = "mail=\(User.currentUser!.email)&pass=\(User.currentUser!.encryptedPassword)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            (data, response, error) in
            
            dispatch_async(dispatch_get_main_queue()) {
                if error != nil {
                    println("error : no connexion in getSubject")
                    FactorySync.errorNetwork = true
                } else {
                    
                    var err: NSError?
                    var statusCode = (response as! NSHTTPURLResponse).statusCode
                    if statusCode == 200 {
                        var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as? NSDictionary
                        
                        if let result = jsonResult {
                            if err != nil {
                                println("error : parsing JSON in getSubject")
                                FactorySync.errorNetwork = true
                            } else {
                                callback(result as NSDictionary)
                                self.counter--
                                if self.counter == 0 {
                                    println("subjects downloaded")
                                    FactorySync.getChapterManager().saveChapters()
                                }
                            }
                        } else {
                            println("error : NSArray nil in getSubject")
                            FactorySync.errorNetwork = true
                        }
                    } else {
                        println("header status = \(statusCode) in getSubject")
                        FactorySync.errorNetwork = true
                    }
                }
            }
            
        }
        task.resume()
    }
}