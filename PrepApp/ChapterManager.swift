//
//  ChapterManager.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 21/07/15.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//


import UIKit
import RealmSwift


class ChapterManager {
    
    let realm = FactoryRealm.getRealm()
    var counter = 0
    
    func saveChapters() {
        self.counter = 0
        self.getChapters({ (data) -> Void in
            var onlineChapters = [Chapter]()
            // dictionary
            for (id, version) in data {
                let chapter = Chapter()
                chapter.id = Int((id as! String))!
                chapter.version = (version as! Int)
                onlineChapters.append(chapter)
            }
            self.compare(onlineChapters)
        })
    }
    
    private func getChapters(callback: (NSDictionary) -> Void) {
        let request = NSMutableURLRequest(URL: FactorySync.chapterUrl!)
        request.HTTPMethod = "POST"
        let postString = "mail=\(User.currentUser!.email)&pass=\(User.currentUser!.encryptedPassword)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            (data, response, error) in
            
            
            dispatch_async(dispatch_get_main_queue()) {
                if error != nil {
                    print("error : no connexion in getChapters")
                    FactorySync.errorNetwork = true
                } else {
                    let statusCode = (response as! NSHTTPURLResponse).statusCode
                    if statusCode == 200 {
                        let jsonResult = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                        
                        if let result = jsonResult {
                            callback(result as NSDictionary)
                        } else {
                            print("error : NSArray nil in getChapters")
                            FactorySync.errorNetwork = true
                        }
                        
                        
                    } else {
                        print("header status = \(statusCode) in getChapters")
                        FactorySync.errorNetwork = true
                    }
                }
            }
            
        }
        task.resume()
    }
    
    private func compare(onlineChapters: [Chapter]){
        
        // Query a Realm
        let offlineChapters = self.realm.objects(Chapter)
        
        // we check what has been removed
        var idsToRemove = [Int]()
        for offlineChapter in offlineChapters {
            var willBeRemoved = true
            for onlineChapter in onlineChapters {
                if onlineChapter.id == offlineChapter.id {
                    willBeRemoved = false
                }
            }
            if willBeRemoved {
                idsToRemove.append(offlineChapter.id)
            }
        }
        self.deleteChapters(idsToRemove)
        
        // we check what has been updated
        var idsToUpdate = [Int]()
        for offlineChapter in offlineChapters {
            var willBeUpdated = true
            for onlineChapter in onlineChapters {
                if onlineChapter.id == offlineChapter.id && onlineChapter.version == offlineChapter.version {
                    willBeUpdated = false
                }
            }
            if willBeUpdated {
                idsToUpdate.append(offlineChapter.id)
            }
        }
        self.updateChapters(idsToUpdate)
        self.counter += idsToUpdate.count
        
        // we check what we have to add
        var idsToAdd = [Int]()
        for onlineChapter in onlineChapters {
            var willBeAdded = true
            for offlineChapter in offlineChapters {
                if onlineChapter.id == offlineChapter.id {
                    willBeAdded = false
                }
            }
            if willBeAdded {
                idsToAdd.append(onlineChapter.id)
            }
        }
        self.saveChapters(idsToAdd)
        self.counter += idsToAdd.count
        if self.counter == 0 {
            print("chapters: nothing new to sync")
            FactorySync.getQuestionManager().saveQuestions()
        }
    }
    
    private func deleteChapters(idsToRemove: [Int]){
        for idToRemove in idsToRemove {
            if FactorySync.errorNetwork == false {
                let objectToRemove = realm.objects(Chapter).filter("id=\(idToRemove)")
                try! self.realm.write {
                    self.realm.delete(objectToRemove)
                }
            }
        }
    }
    
    private func updateChapters(idsToUpdate: [Int]){
        for idToUpdate in idsToUpdate {
            if FactorySync.errorNetwork == false {
                self.getChapter(idToUpdate, callback: { (chapterData) -> Void in
                    let chapters = self.realm.objects(Chapter)
                    for chapter in chapters {
                        if chapter.id == idToUpdate {
                            try! self.realm.write {
                                chapter.name = chapterData["name"] as! String
                                let id = chapterData["idSubject"] as! Int
                                chapter.number = chapterData["number"] as! Int
                                let subject = self.realm.objects(Subject).filter("id=\(id)")[0]
                                chapter.subject = subject
                                chapter.version = chapterData["version"] as! Int
                            }
                        }
                    }
                })
            }
        }
    }
    
    private  func saveChapters(idsToAdd: [Int]){
        for idToAdd in idsToAdd {
            if FactorySync.errorNetwork == false {
                self.getChapter(idToAdd, callback: { (chapterData) -> Void in
                    let newChapter = Chapter()
                    newChapter.id =  chapterData["id"] as! Int
                    newChapter.name = chapterData["name"] as! String
                    newChapter.number = chapterData["number"] as! Int
                    newChapter.version = chapterData["version"] as! Int
                    let id = chapterData["idSubject"] as! Int
                    let subject = self.realm.objects(Subject).filter("id=\(id)")[0]
                    newChapter.subject = subject
                    try! self.realm.write {
                        self.realm.add(newChapter)
                    }
                })
            }
        }
    }
    
    private func getChapter(id: Int, callback: (NSDictionary) -> Void) {
        let url = NSURL(string: "\(FactorySync.chapterUrl!)\(id)")
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        let postString = "mail=\(User.currentUser!.email)&pass=\(User.currentUser!.encryptedPassword)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            (data, response, error) in
            
            dispatch_async(dispatch_get_main_queue()) {
                if error != nil {
                    print("error : no connexion in getChapter")
                    FactorySync.errorNetwork = true
                } else {
                    let statusCode = (response as! NSHTTPURLResponse).statusCode
                    if statusCode == 200 {
                        let jsonResult = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                        
                        if let result = jsonResult {
                            callback(result as NSDictionary)
                            self.counter--
                            if self.counter == 0 {
                                print("chapters downloaded")
                                FactorySync.getQuestionManager().saveQuestions()
                            }
                        } else {
                            print("error : NSArray nil in getChapter")
                            FactorySync.errorNetwork = true
                        }
                    } else {
                        print("header status = \(statusCode) in getChapter")
                        FactorySync.errorNetwork = true
                    }
                }
            }
            
        }
        task.resume()
    }
}