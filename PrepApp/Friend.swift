//
//  Friend.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 23/09/15.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import RealmSwift

// Friend model
class Friend : Object {
    dynamic var id: Int = 0
    dynamic var firstName: String = ""
    dynamic var lastName: String = ""
    dynamic var nickname: String = ""
    dynamic var awardPoint: Int = 0
    
    override static func primaryKey() -> String? {
        return "id"
    }
}