//
//  ResultDuo.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 07/11/2015.
//  Copyright © 2015 PrepApp. All rights reserved.
//

import RealmSwift

// Result model
class Result: Object {
    dynamic var id: Int = 0
    dynamic var firstName: String = ""
    dynamic var lastName: String = ""
    dynamic var nickname: String = ""
    dynamic var score: Int = 0
}

// ResultDuo model
class ResultDuo: Object {
    dynamic var idDuo: Int = 0
    dynamic var firstTime: Bool = true
    let resultDuo = List<Result>()
}