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
    var statusCode = 0
    var hasFinishedSync: Bool = false
    var hasFinishedComputeSize: Bool = false
    let realm = FactoryRealm.getRealm()
    
    
    func saveQuestions() {
        self.hasFinishedSync = false
        self.questionsSaved = 0
        self.questionsToSave = 0
        self.getQuestions({ (data) -> Void in
            var onlineQuestions = [Question]()
            // dictionary
            for (id, version) in data! {
                let question = Question()
                question.id = (id as! String).toInt()!
                question.version = (version as! String).toInt()!
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
        
        
        realm.write {
            realm.add(newQuestion)
        }
    }
    
    private func getQuestions(callback: (NSDictionary?) -> Void) {
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
        self.computeSize(objectsToAdd)
        self.fetchImages(objectsToAdd)
        
    }
    
    private func computeSize(objectsToAdd: [Image]) {
        self.sizeToDownload = 0
        for objectToAdd in objectsToAdd {
            self.sizeToDownload += objectToAdd.size
        }
        self.numberOfImagesToDownload = objectsToAdd.count
        //println("Size of images to download = \(self.sizeToDownload/1000) KB")
        self.hasFinishedComputeSize = true
        if self.sizeToDownload == 0 {
            self.hasFinishedSync = true
            println("Nothing new to upload (images)")
        }
    }
    
    private  func fetchImages(objectsToAdd: [Image]){
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            for objectToAdd in objectsToAdd {
                if FactorySync.errorNetwork == false {
                    let url = NSURL(string: "\(FactorySync.uploadsUrl!)/\(objectToAdd.id).png")
                    self.saveFile(url!, imageName: "/\(objectToAdd.id).png", objectToAdd: objectToAdd)
                }
            }
        }
        
    }
    
    private func saveFile(url: NSURL, imageName: String, objectToAdd: Image){
        
        let realmImages = Realm(path: "\(FactorySync.path)/images.realm")
        let timeout: NSTimeInterval = 30
        let urlRequest = NSURLRequest(URL: url, cachePolicy:
            NSURLRequestCachePolicy.UseProtocolCachePolicy,timeoutInterval: timeout)
        NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            
            if error != nil {
                if FactorySync.errorNetwork == false {
                    FactorySync.errorNetwork = true
                    println(error)
                }
                
            } else {
                if !FactorySync.errorNetwork {
                    self.sizeDownloaded += data.length
                    //println("size downloaded = \(self.sizeDownloaded/1000)KB/\(self.sizeToDownload/1000)KB")
                    
                    let imagesPath = FactorySync.path + "/images"
                    NSFileManager.defaultManager().createDirectoryAtPath(imagesPath, withIntermediateDirectories: false, attributes: nil, error: nil)
                    let imagePath = imagesPath + imageName
                    if let fetchedImage = UIImage(data: data) {
                        
                        NSFileManager.defaultManager().createFileAtPath(imagePath, contents: data, attributes: nil)
                        self.numberOfImagesDownloaded++
                        //println("image \(self.numberOfImagesDownloaded)/\(self.numberOfImagesToDownload) downloaded")
                        //image saved in directory, we updrade Realm DB
                        self.realm.write {
                            self.realm.add(objectToAdd)
                        }
                    }
                } else {
                    println("FactorySync stopped sync due to error in ImageManager")
                }
            }
            
            if self.numberOfImagesDownloaded == self.numberOfImagesToDownload && self.numberOfImagesToDownload != 0 {
                self.sizeDownloaded = self.sizeToDownload
                //println("size downloaded = \(self.sizeDownloaded/1000)KB/\(self.sizeToDownload/1000)KB")
                self.hasFinishedSync = true
                println("images downloaded")
            }
        }
    }
    
    private func deleteQuestions(idsToRemove: [Int]){
        for idToRemove in idsToRemove {
            var objectToRemove = realm.objects(Image).filter("id=\(idToRemove)")
            self.realm.write {
                self.realm.delete(objectToRemove)
            }
            self.removeFile("/\(idToRemove).png")
        }
        
    }
    
    private func removeFile(imageName: String){
        let path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        let imagesPath = path + "/images"
        let imagePath = imagesPath + imageName
        println(imagePath)
        NSFileManager.defaultManager().removeItemAtPath(imagePath, error: nil)
        
    }

    
   
}