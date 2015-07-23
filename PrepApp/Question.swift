//
//  Question.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 23/07/15.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import RealmSwift

// Question model
class Question : Object {
    dynamic var id: Int = 0
    dynamic var chapter: Chapter?
    dynamic var wording: String = ""
    dynamic var imagesQuestion: String = ""
    dynamic var answerOne: String = ""
    dynamic var answerTwo: String = ""
    dynamic var answerThree: String = ""
    dynamic var answerFour: String = ""
    dynamic var answerFive: String = ""
    dynamic var answerSix: String = ""
    dynamic var goodAnswers: String = ""
    dynamic var calculator: Bool = true
    dynamic var info: String = ""
    dynamic var type: Int = 0
    dynamic var idDuo: Int = 0
    dynamic var idConcours: Int = 0
    dynamic var correction: String = ""
    dynamic var imagesCorrection: String = ""
    
}