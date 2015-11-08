//
//  News.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 08/11/2015.
//  Copyright © 2015 PrepApp. All rights reserved.
//

import RealmSwift

// News model
class News : Object {
    dynamic var id: Int = 0
    dynamic var idAuthor: Int = 0
    dynamic var firstName: String = ""
    dynamic var lastName: String = ""
    dynamic var role: Int = 0
    dynamic var title: String = ""
    dynamic var content: String = ""
    dynamic var date: NSDate = NSDate()
}