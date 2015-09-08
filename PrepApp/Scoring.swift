//
//  Scoring.swift
//  PrepApp
//
//  Created by Mikael Vandeginste on 08/09/2015.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import UIKit

class Scoring {
    
    private let realmHistory = FactoryRealm.getRealmHistory()
    private let realm = FactoryRealm.getRealm()
    
    func getScore(subject: Int) -> (Int,Int,Int) {
        
        let questionsHistory = self.realmHistory.objects(QuestionHistory)
        let questions = self.realm.objects(Question)
        return (0,0,0)
    }
    
    
    private func computeLevel() {
        
    }
    
    private func computeSucceeded() {
        let questionsHistory = self.realmHistory.objects(QuestionHistory)
        var succeeded = 0
        for question in questionsHistory {
            if question.success {
                succeeded++
            }
        }
        User.currentUser!.success = succeeded

    }
    
    private func computeFailed() {
        let questionsHistory = self.realmHistory.objects(QuestionHistory)
        var failed = 0
        for question in questionsHistory {
            if !question.success {
                failed++
            }
        }
        User.currentUser!.failed = failed
    }
    
    private func computeAssiduity() {
        let questionsHistory = self.realmHistory.objects(QuestionHistory)
        var counter = 0
        for question in questionsHistory {
            counter++
        }
        User.currentUser!.assiduity = counter
        
    }
    
    func sync() {
        self.computeAssiduity()
        self.computeFailed()
        self.computeSucceeded()
        self.computeLevel()
        User.currentUser!.saveUser()
    }

}
