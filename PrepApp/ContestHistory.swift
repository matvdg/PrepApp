//
//  ContestHistory.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 13/11/2015.
//  Copyright © 2015 PrepApp. All rights reserved.
//

import RealmSwift

// ContestHistory model
class ContestHistory : Contest {
    dynamic var score: Int = 0
    dynamic var emptyAnswers: Int = 0
    dynamic var succeeded: Int = 0
    dynamic var numberOfQuestions: Int = 0    
}
