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
                if !questionHistory.training {
                    question.assiduityDouble = true
                    println("double assiduity")
                }
                realmHistory.write {
                    questionHistory.success = question.success
                    questionHistory.training = question.training
                    questionHistory.assiduityDouble = question.assiduityDouble
                    println("updated")
                }
                updated = true
                break
            }
            
        }
        if updated == false { //firstTime in DB
            realmHistory.write {
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
    
}
