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
    
    //questions/chapters/subjects
    static let realm = try! Realm()
    
    class func getRealm() -> Realm {
        return realm
    }
    
    
    class func clearUserDB() {
        do {
            try self.realm.write {
                self.realm.delete(self.realm.objects(QuestionHistory))
                self.realm.delete(self.realm.objects(Friend))
                self.realm.delete(self.realm.objects(PendingDuo))
                self.realm.delete(self.realm.objects(ContestHistory))
            }
        } catch {
            print("error in Realm")
        }
        print("userDB cleaned")
    }
    
}