//
//  Realm.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 24/07/15.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import UIKit
import RealmSwift


class FactoryRealm {
    
    static let realm = try! Realm()
    static let realmHistory = try! Realm(path: "\(FactorySync.path)/history.realm")
    static let realmImages = try! Realm(path: "\(FactorySync.path)/images.realm")
    static let realmFriends = try! Realm(path: "\(FactorySync.path)/friends.realm")
    static let realmDuo = try! Realm(path: "\(FactorySync.path)/duo.realm")
    static let realmNewsfeed = try! Realm(path: "\(FactorySync.path)/newsfeed.realm")
    static let realmContest = try! Realm(path: "\(FactorySync.path)/contest.realm")
    static let realmContestHistory = try! Realm(path: "\(FactorySync.path)/contestHistory.realm")
    
    class func getRealm() -> Realm {
        return realm
    }
    
    class func getRealmImages() -> Realm {
        return realmImages
    }
    
    class func getRealmHistory() -> Realm {
        return realmHistory
    }
    
    class func getRealmFriends() -> Realm {
        return realmFriends
    }
    
    class func getRealmDuo() -> Realm {
        return realmDuo
    }
    
    class func getRealmNewsfeed() -> Realm {
        return realmNewsfeed
    }
    
    class func getRealmContest() -> Realm {
        return realmContest
    }
    
    class func getRealmContestHistory() -> Realm {
        return realmContestHistory
    }
    
    class func clearUserDB() {
        do {
            try self.realmHistory.write {
                self.realmHistory.deleteAll()
            }
            
            try self.realmFriends.write {
                self.realmFriends.deleteAll()
            }
            
            try self.realmDuo.write {
                self.realmDuo.deleteAll()
            }
            
            try self.realmContestHistory.write {
                self.realmContestHistory.deleteAll()
            }
 
        } catch {
            print("error in Realm")
        }
        print("userDB cleaned")
    }
    
}