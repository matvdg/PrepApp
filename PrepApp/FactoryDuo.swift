//
//  FactoryDuo.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 24/09/15.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

class FactoryDuo {
    
    static let friendManager = FriendManager()
    
    class func getFriendManager() -> FriendManager {
        return friendManager
    }
    
    
}