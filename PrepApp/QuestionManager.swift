//
//  QuestionManager.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 20/07/15.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import UIKit
import RealmSwift


class QuestionManager: NSObject, NSURLConnectionDelegate, NSURLConnectionDataDelegate {
    
    var data = NSMutableData()
    var sizeDownloaded: Int = 0
    var sizeToDownload: Int = -1
    var questionsToSave: Int = 0
    var questionsSaved: Int = 0
    var statusCode = 0
    var hasFinishedSync: Bool = false
    var hasFinishedComputeSize: Bool = false
    
    
    func saveQuestions() {
        self.data = NSMutableData()
        self.hasFinishedSync = false
        self.hasFinishedComputeSize = false
        self.sizeDownloaded = 0
        self.sizeToDownload = -1
        self.questionsSaved = 0
        self.questionsToSave = 0
        self.getQuestions()
    }
    
    private func parseNplaceImage(var input: String, images: String) -> String {
        
        if images != "" {
            var counter = 0
            var imagesArray: [String] = []
            imagesArray = images.componentsSeparatedByString(",")
            counter = imagesArray.count
            
            for index in 1...counter {
                input = input.stringByReplacingOccurrencesOfString("{\(index)}", withString: "<img width=\"\(SyncViewController.widthImage)\" src=\"images/\(getImageByIndex(index, imagesArray: imagesArray))\"/>", options: nil, range: nil)
                input = input.stringByReplacingOccurrencesOfString("#f9f9f9", withString: "transparent", options: nil, range: nil)
            }
        }
        return input
    }
    
    private func getImageByIndex(index: Int, imagesArray: [String]) -> String {
        return imagesArray[index-1]
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
        newQuestion.imagesQuestion = data["images_question"] as! String
        newQuestion.imagesCorrection = data["images_correction"] as! String
        newQuestion.chapter = chapter
        newQuestion.wording = parseNplaceImage(data["wording"] as! String, images: newQuestion.imagesQuestion)
        newQuestion.answerOne = parseNplaceImage(data["answer_1"] as! String, images: newQuestion.imagesQuestion)
        newQuestion.answerTwo = parseNplaceImage(data["answer_2"] as! String, images: newQuestion.imagesQuestion)
        newQuestion.answerThree = parseNplaceImage(data["answer_3"] as! String, images: newQuestion.imagesQuestion)
        newQuestion.answerFour = parseNplaceImage(data["answer_4"] as! String, images: newQuestion.imagesQuestion)
        newQuestion.answerFive = parseNplaceImage(data["answer_5"] as! String, images: newQuestion.imagesQuestion)
        newQuestion.answerSix = parseNplaceImage(data["answer_6"] as! String, images: newQuestion.imagesQuestion)
        newQuestion.goodAnswers = data["good_answers"] as! String
        newQuestion.calculator = data["calculator"] as! Bool
        newQuestion.info = self.formatInfo(data["info"] as! String)
        newQuestion.type = data["type"] as! Int
        newQuestion.idDuo = data["id_group_duo"] as! Int
        newQuestion.idConcours = data["id_group_duo"] as! Int
        newQuestion.correction = parseNplaceImage(data["correction"] as! String, images: newQuestion.imagesCorrection)
        
    
        realm.write {
            realm.add(newQuestion)
        }
    }
    
    private func getQuestions() {
        let request = NSMutableURLRequest(URL: Factory.questionUrl!)
        request.HTTPMethod = "POST"
        let postString = "mail=\(User.currentUser!.email)&pass=\(User.currentUser!.encryptedPassword)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        var connection: NSURLConnection = NSURLConnection(request: request, delegate: self, startImmediately: true)!
    }
    
    /* delegate methods */
    func connection(connection: NSURLConnection, didReceiveData data: NSData){
        if !Factory.errorNetwork {
            self.sizeDownloaded = self.data.length
            self.hasFinishedComputeSize = true
            //println("Size of questions downloaded = \(self.sizeDownloaded/1000) KB / \(self.sizeToDownload/1000) KB")
            self.data.appendData(data)
        } else {
            connection.cancel()
            println("Factory stopped sync due to error in QuestionManager > didReceiveData")
        }
    
    }

    func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        println("error : no connexion in getQuestions")
        Factory.errorNetwork = true
        connection.cancel()
    }

    func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse) {
        statusCode = (response as! NSHTTPURLResponse).statusCode
        var headers = (response as! NSHTTPURLResponse).allHeaderFields
        for (key,value) in headers {
            if key as! String == "Content-Length" {
                self.sizeToDownload = (value as! String).toInt()!
            }
        }
        //println("Size of questions to download = \(self.sizeToDownload/1000) KB")
        
        
    }

    func connectionDidFinishLoading(connection: NSURLConnection){
        if !Factory.errorNetwork {
            self.sizeDownloaded = self.sizeToDownload
            //println("Size of questions downloaded = \(self.sizeDownloaded/1000) KB / \(self.sizeToDownload/1000) KB")
            println("questions downloaded")
            var err: NSError?
            if statusCode == 200 {
                var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as? NSArray
                
                if let result = jsonResult {
                    if err != nil {
                        connection.cancel()
                        println("error : parsing JSON in getQuestions")
                        Factory.errorNetwork = true
                    } else {
                        self.questionsToSave = (result as NSArray).count
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                            for question in result as NSArray {
                                self.questionsSaved++
                                if !Factory.errorNetwork {
                                    self.saveQuestion(question as! NSDictionary)
                                }
                                //println("\(self.questionsSaved) / \(self.questionsToSave) questions traitées")
                            }
                            self.hasFinishedSync = true
                            println("questions loaded into Realm DB")
                        }
                    }
                } else {
                    connection.cancel()
                    println("error : NSArray nil in getQuestions")
                    Factory.errorNetwork = true
                }
                
                
            } else {
                connection.cancel()
                println("error : != 200 in getQuestions")
                Factory.errorNetwork = true
            }

        } else {
            connection.cancel()
            println("Factory stopped sync due to error in QuestionManager > connectionDidFinishLoading")
        }
        
    }
}

            
            
            

