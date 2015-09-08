//
//  Scoring.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 08/09/2015.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import UIKit
import RealmSwift

class Scoring {
    
    private let realmHistory = FactoryRealm.getRealmHistory()
    private let realm = FactoryRealm.getRealm()
    
    func getScore(subject: Int) -> (Int,Int,Int) {
        
        let questionsHistory = self.realmHistory.objects(QuestionHistory)
        var questionsToCompute = List<QuestionHistory>()
        var succeeded = 0
        var percent = 0
        var todo = 0
        
        //fetching the appropriate questions
        for questionHistory in questionsHistory {
            let question = self.realm.objects(Question).filter("id = \(questionHistory.id)")[0]
            if question.chapter!.subject!.id == subject {
                questionsToCompute.append(questionHistory)
            }
        }
        
        for question in questionsToCompute {
            if question.success {
                succeeded++
            }
        }
        
        switch subject {
        case 1 : //biology
            (percent, todo) = self.computePercentLevel(6, succeeded: succeeded)
        case 2 : //physics
            (percent, todo) = self.computePercentLevel(2, succeeded: succeeded)
        case 3 : //chemistry
            (percent, todo) = self.computePercentLevel(1, succeeded: succeeded)
        default :
            println("error")
        }
        return (percent, succeeded, todo)
    }
    
    private func computePercentLevel(ratio: Int, succeeded: Int) -> (Int,Int) {
        var currentLevel = User.currentUser!.level + 1
        var units: Int = succeeded / ratio
        var percent = 0
        var todo = 0
        var unitsNeededForNextLevel = computeUnitsNeededForNextLevel(currentLevel)
        if units < unitsNeededForNextLevel { //we haven't reached yet the level
            var nextStep = (unitsNeededForNextLevel * ratio)
            todo = nextStep - succeeded
            var unitsNeededForPreviousLevel = computeUnitsNeededForNextLevel(currentLevel-1)
            var previousStep = (unitsNeededForPreviousLevel * ratio)
            var totalToSucceedForThisLevel = nextStep - previousStep
            percent = (totalToSucceedForThisLevel - todo) * 100 / totalToSucceedForThisLevel
        } else { //we are above the required level
            percent = 100
            todo = 0
        }
        return (percent, todo)
    }
    
    private func computeUnitsNeededForNextLevel(level: Int) -> Int {
        return (level+1) * (level) / 2
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
        User.currentUser!.saveUser()
    }

}
