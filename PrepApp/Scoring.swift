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
            if question.firstSuccess {
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
    
    func getSucceeded() -> Int {
        let questionsHistory = self.realmHistory.objects(QuestionHistory)
        var succeeded = 0
        for question in questionsHistory {
            if question.firstSuccess {
                succeeded++
            }
        }
        return succeeded

    }
    
    func getFailed() -> Int {
        let questionsHistory = self.realmHistory.objects(QuestionHistory)
        var failed = 0
        for question in questionsHistory {
            if !question.firstSuccess {
                failed++
            }
        }
        return failed
    }
    
    func getAssiduity() -> Int {
        let questionsHistory = self.realmHistory.objects(QuestionHistory)
        var counter = 0
        for question in questionsHistory {
            counter++
            if question.assiduityDouble {
                counter++
            }
        }
        return counter
    }
    
    func getPerf(subject: Int) -> [Double] {
        let questionsHistory = self.realmHistory.objects(QuestionHistory)
        var questionsToCompute: [Int:[QuestionHistory]] = [:]
        var performances: [Int:Int] = [:]
        var result: [Double] = []
        var succeeded = 0
        var counter = 0
        var maxWeek = 0
        
        //fetching the appropriate questions
        for questionHistory in questionsHistory {
            let question = self.realm.objects(Question).filter("id = \(questionHistory.id)")[0]
            if question.chapter!.subject!.id == subject {
                if let entry = questionsToCompute[questionHistory.weeksBeforeExam] {
                    questionsToCompute[questionHistory.weeksBeforeExam]!.append(questionHistory)
                } else {
                    questionsToCompute[questionHistory.weeksBeforeExam] = [questionHistory]
                }
            }
        }
        //fetching the perf...
        for (week,questions) in questionsToCompute {
            for question in questions {
                if question.firstSuccess {
                    succeeded++
                }
                counter++
                if week > maxWeek {
                    maxWeek = week
                }
            }
            performances[week] = Int(succeeded * 100 / counter)
            succeeded = 0
            counter = 0
        }
        //sorting...
        while performances.count != 0 {
            for (week, performance) in performances {
                if week == maxWeek {
                    result.append(Double(performance))
                    performances.removeValueForKey(week)
                }
            }
            maxWeek--

        }
        return result
    }
    
    func getQuestionsAnswered() -> [Double] {
        let questionsHistory = self.realmHistory.objects(QuestionHistory)
        var questionsToCompute: [Int:[QuestionHistory]] = [:]
        var questionsAnsweredDic: [Int:Int] = [:]
        var result: [Double] = []
        var maxWeek = 0
        var questionsAnswered = 0
        
        //fetching the appropriate questions
        for questionHistory in questionsHistory {
            if let entry = questionsToCompute[questionHistory.weeksBeforeExam] {
                questionsToCompute[questionHistory.weeksBeforeExam]!.append(questionHistory)
            } else {
                questionsToCompute[questionHistory.weeksBeforeExam] = [questionHistory]
            }
        }
        
        for (week,questions) in questionsToCompute {
            for question in questions {
                questionsAnswered++
                
                if week > maxWeek {
                    maxWeek = week
                }
            }
            questionsAnsweredDic[week] = questionsAnswered
            questionsAnswered = 0
        }
        
        //sorting...
        while questionsAnsweredDic.count != 0 {
            for (week, value) in questionsAnsweredDic {
                if week == maxWeek {
                    result.append(Double(value))
                    questionsAnsweredDic.removeValueForKey(week)
                }
            }
            maxWeek--
            
        }
        return result
    }
    
    func getWeeksBeforeExam () -> [String] {
        let questionsHistory = self.realmHistory.objects(QuestionHistory)
        var weeks: [Int] = []
        var result: [String] = []
        var maxWeek = 0
        var index = 0
        
        //fetching the appropriate questions
        for questionHistory in questionsHistory {
            if find(weeks,questionHistory.weeksBeforeExam) == nil {
                weeks.append(questionHistory.weeksBeforeExam)
            }
        }
        //sorting...
        while weeks.count != 0 {
            for week in weeks {
                if week > maxWeek {
                    maxWeek = week
                    index = find(weeks, week)!
                }
            }
            result.append(String(maxWeek))
            weeks.removeAtIndex(index)
            maxWeek = 0
            
            
        }
        return result

    }
    
    private func computeUnitsNeededForNextLevel(level: Int) -> Int {
        return (level+1) * (level) / 2
    }
    
    private func computePercentLevel(ratio: Int, succeeded: Int) -> (Int,Int) {
        var currentLevel = User.currentUser!.level
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
}
