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
    
    static let realm = Realm()
    static let realmImages = Realm(path: "\(Factory.path)/images.realm")
    
    class func getRealm() -> Realm {
        return realm
    }
    
    class func getRealmImages() -> Realm {
        return realmImages
    }
    
}