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
    
    func saveChapters() {
        self.getChapters({ (chapters) -> Void in
            for chapter in chapters! {
                self.saveChapter(chapter as! NSDictionary)
            }
            println("chapters downloaded")
            //Factory.getQuestionManager().saveQuestions()
            
        })
        
    }
    
    private func saveChapter(data: NSDictionary) {
        
        var newChapter = Chapter()
        newChapter.id = data["id"] as! Int
        let id = data["id_subject"] as! Int
        let subject = realm.objects(Subject).filter("id=\(id)")[0]
        newChapter.subject = subject
        newChapter.number = data["number"] as! Int
        newChapter.name = data["name"] as! String
        
        self.realm.write {
            self.realm.add(newChapter)
        } 
    }
    
    private func getChapters(callback: (NSArray?) -> Void) {
        let request = NSMutableURLRequest(URL: Factory.chapterUrl!)
        request.HTTPMethod = "POST"
        let postString = "mail=\(User.currentUser!.email)&pass=\(User.currentUser!.encryptedPassword)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            (data, response, error) in
            
            dispatch_async(dispatch_get_main_queue()) {
                if error != nil {
                    println("error : no connexion in getChapters")
                    Factory.errorNetwork = true
                } else {
                    
                    var err: NSError?
                    var statusCode = (response as! NSHTTPURLResponse).statusCode
                    if statusCode == 200 {
                        var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as? NSArray
                        
                        if let result = jsonResult {
                            if err != nil {
                                println("error : parsing JSON in getChapters")
                                Factory.errorNetwork = true
                            } else {
                                callback(result as NSArray)
                            }
                        } else {
                            println("error : NSArray nil in getChapters")
                            Factory.errorNetwork = true
                        }
                        
                        
                    } else {
                        println("error : != 200 in getChapters")
                        Factory.errorNetwork = true
                    }
                    
                }
            }
        }
        task.resume()
        
        
    }
    
    
}