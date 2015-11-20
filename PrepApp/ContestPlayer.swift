//
//  ContestPlayer.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 12/11/2015.
//  Copyright © 2015 PrepApp. All rights reserved.
//

import RealmSwift

// ContestPlayer model
class ContestPlayer : Object {
    
    dynamic var firstName: String = ""
    dynamic var lastName: String = ""
    dynamic var nickname: String = ""
    dynamic var points: Float = 0
    
}