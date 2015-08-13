//
//  History.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 11/08/15.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import UIKit


class History{
    
    static let realmHistory = FactoryRealm.getRealmHistory()
    
    class func addQuestionToHistory(question: QuestionHistory) {
        
        let questionsHistory = self.realmHistory.objects(QuestionHistory)
        var updated = false
        for questionHistory in questionsHistory {
            
            if question.id == questionHistory.id {
                realmHistory.write {
                    questionHistory.success = question.success
                }
                //println("updated")
                updated = true
                break
            }
            
        }
        if updated == false {
            realmHistory.write {
                self.realmHistory.add(question)
            }
            //println("added")
        }


    }
    
    class func isQuestionNew(id: Int)-> Bool {
        let questionsHistory = self.realmHistory.objects(QuestionHistory)
        var result = true
        for questionHistory in questionsHistory {
            if id == questionHistory.id {
                result = false
                break
            }
        }
        return result

    }
    
    class func isQuestionDone(id: Int)-> Bool {
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
    
    class func isQuestionSuccess(id: Int)-> Bool {
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
    
    class func isQuestionFail(id: Int)-> Bool {
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
    
}
