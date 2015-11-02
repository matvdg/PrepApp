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
                subject.id = Int((id as! String))!
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
                    print("error : no connexion in getSubjects")
                    FactorySync.errorNetwork = true
                } else {
                    let statusCode = (response as! NSHTTPURLResponse).statusCode
                    if statusCode == 200 {
                        let jsonResult = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                        
                        if let result = jsonResult {
                            callback(result as NSDictionary)
                        } else {
                            print("error : NSArray nil in getSubjects")
                            FactorySync.errorNetwork = true
                        }
                        
                        
                    } else {
                        print("header status = \(statusCode) in getSubjects")
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
            print("subjects: nothing new to sync")
            FactorySync.getChapterManager().saveChapters()
        }
        
    }
    
    private func deleteSubjects(idsToRemove: [Int]){
        for idToRemove in idsToRemove {
            if FactorySync.errorNetwork == false {
                let objectToRemove = realm.objects(Subject).filter("id=\(idToRemove)")
                try! self.realm.write {
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
                            try! self.realm.write {
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
                    let newSubject = Subject()
                    newSubject.id =  subjectData["id"] as! Int
                    newSubject.name = subjectData["name"] as! String
                    newSubject.version = subjectData["version"] as! Int
                    //TODO: receive rario & time per Questions computed
                    newSubject.ratio = subjectData["questionsPerExam"] as! Int
                    newSubject.timePerQuestion = subjectData["examDuration"] as! Int
                    try! self.realm.write {
                        self.realm.add(newSubject)
                        print(newSubject)
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
                    print("error : no connexion in getSubject")
                    FactorySync.errorNetwork = true
                } else {
                    
                    let statusCode = (response as! NSHTTPURLResponse).statusCode
                    if statusCode == 200 {
                        let jsonResult = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                        
                        
                        if let result = jsonResult {
                            callback(result as NSDictionary)
                            self.counter--
                            if self.counter == 0 {
                                print("subjects downloaded")
                                FactorySync.getChapterManager().saveChapters()
                            }
                            
                        } else {
                            print("error : NSArray nil in getSubject")
                            FactorySync.errorNetwork = true
                        }
                    } else {
                        print("header status = \(statusCode) in getSubject")
                        FactorySync.errorNetwork = true
                    }
                }
            }
            
        }
        task.resume()
    }
}