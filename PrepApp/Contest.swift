//
//  Contest
//  PrepApp
//
//  Created by Mathieu Vandeginste on 25/09/15.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import RealmSwift

// Contest model
class Contest : Object {
    dynamic var id: Int = 0
    dynamic var duration: Int = 0
    dynamic var name: String = ""
    dynamic var content: String = ""
    dynamic var goodAnswer: Float = 0
    dynamic var noAnswer: Float = 0
    dynamic var wrongAnswer: Float = 0
    dynamic var begin: NSDate = NSDate()
    dynamic var end: NSDate = NSDate()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}