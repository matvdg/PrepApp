//
//  PendingDuo.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 25/09/15.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import RealmSwift

// Pending Duo model
class PendingDuo : Object {
    dynamic var id: Int = 0
    dynamic var senderId: Int = 0
    dynamic var firstName: String = ""
    dynamic var lastName: String = ""
    dynamic var nickname: String = ""
    dynamic var date: NSDate = NSDate()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}