//
//  QuestionManager.swift
//  PrepApp
//
//  Created by Mikael Vandeginste on 21/09/2015.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import UIKit
import RealmSwift   

class QuestionManager {
    
    var questionsToSave: Int = 0
    var questionsSaved: Int = 0
    var hasFinishedSync: Bool = false
    let realm = FactoryRealm.getRealm()
    
    func saveQuestions() {
        self.hasFinishedSync = false
        self.questionsSaved = 0
        self.questionsToSave = 0
        self.getQuestions({ (data) -> Void in
            var onlineQuestions = [Question]()
            // dictionary
            for (id, version) in data {
                let question = Question()
                question.id = (id as! String).toInt()!
                question.version = (version as! Int)
                onlineQuestions.append(question)
            }
            self.compare(onlineQuestions)
        })

    }
    
    private func parseNplaceImage(var input: String, images: String) -> String {
        
        if images != "" {
            var counter = 0
            var imagesArray: [String] = []
            imagesArray = images.componentsSeparatedByString(",")
            counter = imagesArray.count
            
            for index in 1...counter {
                input = input.stringByReplacingOccurrencesOfString("{\(index)}", withString: "<img width=\"300\" src=\"images/\(imagesArray[index-1])\"/>", options: nil, range: nil)
                input = input.stringByReplacingOccurrencesOfString("#f9f9f9", withString: "transparent", options: nil, range: nil)
            }
        }
        return input
    }
    
    private func extractImagesPaths(data: NSDictionary) -> String {
        var images = ""
        var empty = true
        for (key,value) in data {
            empty = false
            images += (value as! String)
            images += ","
        }
        if !empty {
            images = images.substringToIndex(images.endIndex.predecessor())
        }
        return images
    }
    
    private func extractAnswers(data: NSDictionary, images: String) -> List<Answer> {
        var answers = List<Answer>()
        var sortedAnswers = List<Answer>()
        for (key,value) in data {
            var answerToExtract = value as! NSDictionary
            var answer = Answer()
            answer.id = (answerToExtract["id"] as! String).toInt()!
            answer.content = parseNplaceImage((answerToExtract["content"] as! String), images: images)
            answer.correct = (answerToExtract["correct"] as! String).toBool()!
            answers.append(answer)
        }
        
        while answers.count != 0 {
            var minId = 1000000000
            var minAnswer = Answer()
            for answer in answers {
                if answer.id < minId {
                    minId = answer.id
                    minAnswer = answer
                }
            }
            sortedAnswers.append(minAnswer)
            answers.removeAtIndex(answers.indexOf(minAnswer)!)
            
        }
        return sortedAnswers
    }
    
    private func formatInfo(var input: String) -> String {
        //println("formatting infos")
        input = input.stringByReplacingOccurrencesOfString("<p>", withString: "<p style=\"font-style: italic; font-size: 12px; text-align: center;\">", options: nil, range: nil)
        return input
    }
    
    private func saveQuestion(data: NSDictionary) {
        
        let realm = Realm()
        var newQuestion: Question = Question()
        newQuestion.id =  data["id_question"] as! Int
        let id = data["id_chapter"] as! Int
        let chapter = realm.objects(Chapter).filter("id=\(id)")[0]
        println(chapter)
        var images = self.extractImagesPaths(data["images"] as! NSDictionary)
        newQuestion.chapter = chapter
        newQuestion.wording = parseNplaceImage(data["wording"] as! String, images: images)
        newQuestion.answers = self.extractAnswers(data["answers"] as! NSDictionary, images: images)
        newQuestion.calculator = data["calculator"] as! Bool
        newQuestion.info = self.formatInfo(data["info"] as! String)
        newQuestion.type = data["type"] as! Int
        newQuestion.idDuo = data["id_group_duo"] as! Int
        newQuestion.idConcours = data["id_group_duo"] as! Int
        newQuestion.correction = parseNplaceImage(data["correction"] as! String, images: images)
        newQuestion.version = data["version"] as! Int
        
        realm.write {
            realm.add(newQuestion)
        }
        self.questionsSaved++
        if self.questionsSaved == self.questionsToSave && self.questionsToSave != 0 {
            self.hasFinishedSync = true
            println("questions loaded into Realm DB")
            FactorySync.getImageManager().sync()
        }
    }
    
    private func getQuestions(callback: (NSDictionary) -> Void) {
        let request = NSMutableURLRequest(URL: FactorySync.questionsListUrl!)
        request.HTTPMethod = "POST"
        let postString = "mail=\(User.currentUser!.email)&pass=\(User.currentUser!.encryptedPassword)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            (data, response, error) in
            
            
            dispatch_async(dispatch_get_main_queue()) {
                if error != nil {
                    println("error : no connexion in getQuestions")
                    FactorySync.errorNetwork = true
                } else {
                    
                    var err: NSError?
                    var statusCode = (response as! NSHTTPURLResponse).statusCode
                    if statusCode == 200 {
                        var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as? NSDictionary
                        
                        if let result = jsonResult {
                            if err != nil {
                                println("error : parsing JSON in getQuestions")
                                FactorySync.errorNetwork = true
                            } else {
                                callback(result as NSDictionary)
                            }
                        } else {
                            println("error : NSArray nil in getQuestions")
                            FactorySync.errorNetwork = true
                        }
                        
                        
                    } else {
                        println("header status = \(statusCode) in getQuestions")
                        FactorySync.errorNetwork = true
                    }
                }
            }
            
        }
        task.resume()
    }
    
    private func getQuestion(id: Int, callback: (NSDictionary) -> Void) {
        let url = NSURL(string: "\(FactorySync.questionUrl!)\(id)")
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        let postString = "mail=\(User.currentUser!.email)&pass=\(User.currentUser!.encryptedPassword)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            (data, response, error) in
            
            dispatch_async(dispatch_get_main_queue()) {
                if error != nil {
                    println("error : no connexion in getQuestion")
                    FactorySync.errorNetwork = true
                } else {
                    
                    var err: NSError?
                    var statusCode = (response as! NSHTTPURLResponse).statusCode
                    if statusCode == 200 {
                        var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as? NSDictionary
                        
                        if let result = jsonResult {
                            if err != nil {
                                println("error : parsing JSON in getQuestion")
                                FactorySync.errorNetwork = true
                            } else {
                                callback(result as NSDictionary)
                            }
                        } else {
                            println("error : NSArray nil in getQuestion")
                            FactorySync.errorNetwork = true
                        }
                    } else {
                        println("header status = \(statusCode) in getQuestion")
                        FactorySync.errorNetwork = true
                    }
                }
            }
            
        }
        task.resume()
    }

    private func compare(onlineQuestions: [Question]){
        
        // Query a Realm
        let offlineQuestions = self.realm.objects(Question)
        
        // we check what has been removed OR updated
        var idsToRemove = [Int]()
        for offlineQuestion in offlineQuestions {
            var willBeRemoved = true
            for onlineQuestion in onlineQuestions {
                if onlineQuestion.id == offlineQuestion.id && onlineQuestion.version == offlineQuestion.version {
                    willBeRemoved = false
                }
            }
            if willBeRemoved {
                idsToRemove.append(offlineQuestion.id)
            }
        }
        self.deleteQuestions(idsToRemove)
        
        
        // we check what we have to add OR update
        var objectsToAdd = [Question]()
        for onlineQuestion in onlineQuestions {
            var willBeAdded = true
            for offlineQuestion in offlineQuestions {
                if onlineQuestion.id == offlineQuestion.id {
                    willBeAdded = false
                }
            }
            if willBeAdded {
                objectsToAdd.append(onlineQuestion)
            }
        }
        self.questionsToSave = objectsToAdd.count
        if self.questionsToSave == 0 {
            self.hasFinishedSync = true
            FactorySync.getImageManager().sync()
            println("There isn't any new question to download")
        }
        self.saveQuestions(objectsToAdd)
    }
    
    private  func saveQuestions(objectsToAdd: [Question]){
        
        for objectToAdd in objectsToAdd {
            if FactorySync.errorNetwork == false {
                self.getQuestion(objectToAdd.id, callback: { (questionData) -> Void in
                    self.saveQuestion(questionData)
                })
            }
        }
    }
    
    private func deleteQuestions(idsToRemove: [Int]){
        for idToRemove in idsToRemove {
            var objectToRemove = realm.objects(Question).filter("id=\(idToRemove)")
            self.realm.write {
                self.realm.delete(objectToRemove)
            }
        }
        
    }
}