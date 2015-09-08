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
    
    func addQuestionToHistory(question: QuestionHistory) {
        
        var questionsHistory = self.realmHistory.objects(QuestionHistory)
        var updated = false
        for questionHistory in questionsHistory {
            
            if question.id == questionHistory.id {
                realmHistory.write {
                    questionHistory.success = question.success
                    questionHistory.training = question.training
                }
                println("updated")
                updated = true
                break
            }
            
        }
        if updated == false {
            realmHistory.write {
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
                realmHistory.write {
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
        var result = true
        for questionHistory in questionsHistory {
            if id == questionHistory.id && questionHistory.training == true {
                result = false
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
    
}
