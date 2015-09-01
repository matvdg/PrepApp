//
//  Answer.swift
//  PrepApp
//
//  Created by Mikael Vandeginste on 31/08/2015.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import RealmSwift

// Answer model
class Answer : Object {
    dynamic var id: Int = 0
    dynamic var content: String = ""
    dynamic var correct: Bool = false
}