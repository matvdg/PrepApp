//
//  ContestLeaderboard.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 12/11/2015.
//  Copyright © 2015 PrepApp. All rights reserved.
//

import RealmSwift

// ContestLeaderboard model
class ContestLeaderboard : Object {
    dynamic var name: String = ""
    let leaderboard = List<ContestPlayer>()
    dynamic var end: NSDate = NSDate()
}