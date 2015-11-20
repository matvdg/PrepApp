//
//  History.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 11/08/15.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import UIKit

class History {
    
    private let realm = FactoryRealm.getRealm()
    
    var syncHistoryNeeded = true
    
    func addQuestionToHistory(question: QuestionHistory) {
        self.syncHistoryNeeded = true
        let questionsHistory = self.realm.objects(QuestionHistory)
        var updated = false
        
        for questionHistory in questionsHistory {
            
            if question.id == questionHistory.id {
                if !questionHistory.training {
                    question.doubleAssiduity = true
                    print("double assiduity")
                }
                try! self.realm.write {
                    questionHistory.success = question.success
                    questionHistory.training = question.training
                    questionHistory.doubleAssiduity = question.doubleAssiduity
                    print("updated")
                }
                updated = true
                break
            }
            
        }
        if updated == false { //firstTime in DB
            try! self.realm.write {
                question.firstSuccess = question.success
                question.weeksBeforeExam = FactorySync.getConfigManager().loadWeeksBeforeExam()
                self.realm.add(question)
            }
            print("added")
        }


    }
    
    func updateQuestionMark(question: QuestionHistory) {
        self.syncHistoryNeeded = true
        let questionsHistory = self.realm.objects(QuestionHistory)
        for questionHistory in questionsHistory {
            
            if question.id == questionHistory.id {
                try! self.realm.write {
                    questionHistory.marked = question.marked
                }
                break
            }
        }
    }
    
    func isQuestionNew(id: Int)-> Bool {
        return !self.isQuestionDone(id)
    }
    
    func isContestNew(id: Int)-> Bool {
        if !realm.objects(Question).filter("idContest = \(id)").isEmpty {
            let questionFromContest = realm.objects(Question).filter("idContest = \(id)").first
            let questionsHistory = self.realm.objects(QuestionHistory)
            var result = true
            for questionHistory in questionsHistory {
                if questionFromContest!.id == questionHistory.id {
                    result = false
                    break
                }
            }
            return result
        }
        return false
    }
    
    func isQuestionNewInTraining(id: Int)-> Bool {
        let questionsHistory = self.realm.objects(QuestionHistory)
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
        let questionsHistory = self.realm.objects(QuestionHistory)
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
        let questionsHistory = self.realm.objects(QuestionHistory)
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
        let questionsHistory = self.realm.objects(QuestionHistory)
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
        let questionsHistory = self.realm.objects(QuestionHistory)
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
        let questionsHistory = self.realm.objects(QuestionHistory)
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
    
    func syncHistory(callback: (Bool) -> Void) {
        let questionsHistory = self.realm.objects(QuestionHistory)
        
        var post: [NSMutableDictionary] = []
        for question in questionsHistory {
            let questionHistory = NSMutableDictionary()
            questionHistory["idQuestion"] = question.id
            questionHistory["training"] = question.training
            questionHistory["success"] = question.success
            questionHistory["firstSuccess"] = question.firstSuccess
            questionHistory["marked"] = question.marked
            questionHistory["doubleAssiduity"] = question.doubleAssiduity
            questionHistory["weeksBeforeExam"] = question.weeksBeforeExam
            
            post.append(questionHistory)
        }
        let json = try? NSJSONSerialization.dataWithJSONObject(post, options: NSJSONWritingOptions(rawValue: 0))
        let history = NSString(data: json!, encoding: NSUTF8StringEncoding)
        //print("History = \(history!)")
        self.updateHistory(history!, callback: { (result) -> Void in
            callback(result)
        })
    }
    
    private func updateHistory(history: NSString, callback: (Bool) -> Void){
        let request = NSMutableURLRequest(URL: FactorySync.updateHistoryUrl!)
        request.HTTPMethod = "POST"
        request.timeoutInterval = NSTimeInterval(5)
        let postString = "mail=\(User.currentUser!.email)&pass=\(User.currentUser!.encryptedPassword)&history=\(history)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            (data, response, error) in
            dispatch_async(dispatch_get_main_queue()) {
                if error == nil {
                    let statusCode = (response as! NSHTTPURLResponse).statusCode
                    if statusCode == 200 {
                        callback(true)
                    } else {
                        callback(false)
                    }
                } else {
                    callback(false)
                }
            }
        }
        task.resume()
    }
    
    func retrieveHistory(callback: (Bool) -> Void){
        self.getHistory { (data) -> Void in
            if let history = data {
                for questionHistory in history {
                    if let question = questionHistory as? NSDictionary {
                        let historyQuestion = QuestionHistory()
                        historyQuestion.id = question["idQuestion"] as! Int
                        historyQuestion.training = question["training"] as! Bool
                        historyQuestion.success = question["success"] as! Bool
                        historyQuestion.firstSuccess = question["firstSuccess"] as! Bool
                        historyQuestion.marked =  question["marked"] as! Bool
                        historyQuestion.doubleAssiduity = question["doubleAssiduity"] as! Bool
                        historyQuestion.weeksBeforeExam = question["weeksBeforeExam"] as! Int
                        try! self.realm.write({
                            self.realm.add(historyQuestion)
                        })
                    } else {
                        callback(false)
                        break
                    }
                }
                callback(true)
            } else {
                callback(false)
            }
        }
    }
    
    private func getHistory(callback: (NSArray?) -> Void) {
        let url = NSURL(string: "\(FactorySync.retrieveHistoryUrl!)")
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        request.timeoutInterval = NSTimeInterval(5)
        let postString = "mail=\(User.currentUser!.email)&pass=\(User.currentUser!.encryptedPassword)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            (data, response, error) in
            
            dispatch_async(dispatch_get_main_queue()) {
                if error != nil {
                    print("error : no connexion in getHistory")
                    callback(nil)
                } else {
                    let statusCode = (response as! NSHTTPURLResponse).statusCode
                    if statusCode == 200 {
                        do {
                            //print(postString)
                            let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                            if let array = jsonResult as? NSArray {
                                //print(array)
                                callback(array as NSArray)
                            } else {
                                print("error : couldn't cast into NSArray in getHistory")
                            }
                        } catch let error as NSError {
                            print(error.localizedDescription)
                            print("error : couldn't serialize JSON in getHistory")
                        }
                        
                        
                    } else {
                        print("header status = \(statusCode) in getHistory")
                        callback(nil)
                    }
                }
            }
            
        }
        task.resume()
    }
    
    func sync() {
        //syncing if necessary
        if FactoryHistory.getHistory().syncHistoryNeeded {
            FactoryHistory.getHistory().syncHistory { (result) -> Void in
                if result {
                    User.currentUser!.updateLevel(User.currentUser!.level)
                    User.currentUser!.updateAwardPoints(User.currentUser!.awardPoints)
                    FactoryHistory.getHistory().syncHistoryNeeded = false
                }
            }
        }
    }

}
