//
//  History.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 11/08/15.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import UIKit


class History {
    
    private let realmHistory = FactoryRealm.getRealmHistory()
    private let realm = FactoryRealm.getRealm()
    
    func addQuestionToHistory(question: QuestionHistory) {
        
        var questionsHistory = self.realmHistory.objects(QuestionHistory)
        var updated = false
        
        for questionHistory in questionsHistory {
            
            if question.id == questionHistory.id {
                if !questionHistory.training {
                    question.doubleAssiduity = true
                    println("double assiduity")
                }
                self.realmHistory.write {
                    questionHistory.success = question.success
                    questionHistory.training = question.training
                    questionHistory.doubleAssiduity = question.doubleAssiduity
                    println("updated")
                }
                updated = true
                break
            }
            
        }
        if updated == false { //firstTime in DB
            self.realmHistory.write {
                question.firstSuccess = question.success
                question.weeksBeforeExam = FactorySync.getConfigManager().loadWeeksBeforeExam()
                self.realmHistory.add(question)
            }
            println("added")
        }


    }
    
    func updateQuestionMark(question: QuestionHistory) {
        let questionsHistory = self.realmHistory.objects(QuestionHistory)
        var updated = false
        for questionHistory in questionsHistory {
            
            if question.id == questionHistory.id {
                self.realmHistory.write {
                    questionHistory.marked = question.marked
                }
                //println("updated")
                updated = true
                break
            }
        }
    }
    
    func isQuestionNew(id: Int)-> Bool {
        return !self.isQuestionDone(id)
    }
    
    func isQuestionNewInTraining(id: Int)-> Bool {
        let questionsHistory = self.realmHistory.objects(QuestionHistory)
        var result = true //all questions are by default new
        for questionHistory in questionsHistory {
            if id == questionHistory.id && questionHistory.training == true {
                result = false //if there is a question in history with training mark, it's not new
                break
            }
        }
        return result
    }
    
    func isQuestionDone(id: Int)-> Bool {
        let questionsHistory = self.realmHistory.objects(QuestionHistory)
        var result = false
        for questionHistory in questionsHistory {
            if id == questionHistory.id {
                result = true
                break
            }
        }
        return result
        
    }
    
    func isQuestionSuccessed(id: Int)-> Bool {
        let questionsHistory = self.realmHistory.objects(QuestionHistory)
        var result = false
        for questionHistory in questionsHistory {
            if id == questionHistory.id && questionHistory.success  {
                result = true
                break
            }
        }
        return result
    }
    
    func isQuestionFailed(id: Int)-> Bool {
        let questionsHistory = self.realmHistory.objects(QuestionHistory)
        var result = false
        for questionHistory in questionsHistory {
            if id == questionHistory.id && !questionHistory.success {
                result = true
                break
            }
        }
        return result
    }
    
    func isQuestionMarked(id: Int)-> Bool {
        let questionsHistory = self.realmHistory.objects(QuestionHistory)
        var result = false
        for questionHistory in questionsHistory {
            if id == questionHistory.id && questionHistory.marked {
                result = true
                break
            }
        }
        return result
    }
    
    func getMarkedQuestions() -> ([Question],[Bool]) {
        let questionsHistory = self.realmHistory.objects(QuestionHistory)
        let questions = self.realm.objects(Question)
        var isTraining = [Bool]()
        var markedQuestions = [Question]()
        for questionHistory in questionsHistory {
            if questionHistory.marked {
                for question in questions {
                    if question.id == questionHistory.id {
                        markedQuestions.append(question)
                        isTraining.append(questionHistory.training)
                    }
                }
                
            }
        }
        return (markedQuestions,isTraining)
    }
    
    func syncHistory() {
        let questionsHistory = self.realmHistory.objects(QuestionHistory)
        
        var post: [NSMutableDictionary] = []
        for question in questionsHistory {
            var questionHistory = NSMutableDictionary()
            questionHistory["idQuestion"] = question.id
            questionHistory["success"] = question.firstSuccess
            questionHistory["doubleAssiduity"] = question.doubleAssiduity
            questionHistory["weeksBeforeExam"] = question.weeksBeforeExam
            post.append(questionHistory)
        }
        let json = NSJSONSerialization.dataWithJSONObject(post, options: NSJSONWritingOptions(0), error: nil)
        let history = NSString(data: json!, encoding: NSUTF8StringEncoding)
        //println(history!)
        self.postHistory(history!)
    }
    
    private func postHistory(history: NSString){
        let request = NSMutableURLRequest(URL: FactorySync.historyUrl!)
        request.HTTPMethod = "POST"
        let postString = "mail=\(User.currentUser!.email)&pass=\(User.currentUser!.encryptedPassword)&history=\(history)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            (data, response, error) in
            dispatch_async(dispatch_get_main_queue()) {
                if error == nil {
                    var err: NSError?
                    var statusCode = (response as! NSHTTPURLResponse).statusCode
                    if statusCode == 200 {
                        println("history sync success")
                    } else {
                        println("history sync failed")
                    }
                }
            }
        }
        task.resume()
    }

    
    
    
}
