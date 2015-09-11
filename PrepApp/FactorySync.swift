//
//  FactorySync.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 21/07/15.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import UIKit
import RealmSwift

class FactorySync {
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /*DEV (LOCAL) OR PROD (ONLINE) */
    static var production: Bool = true
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    static var errorNetwork: Bool = false
    static var offlineMode: Bool = false
    
    
    private static let imageManager = ImageManager()
    private static let chapterManager = ChapterManager()
    private static let questionManager = QuestionManager()
    private static let subjectManager = SubjectManager()
    private static let versionManager = VersionManager()
    private static let realm = FactoryRealm.getRealm()
    
    /*LOCAL OR DISTANT DB*/
    //private static let domain = NSURL(string: "http://p.com/PrepApp")
    private static let domain = NSURL(string: "http://prep-app.com")
    private static let apiUrl = NSURL(string: "\(FactorySync.domain!)/api")
    
    static let uploadsUrl = NSURL(string: "\(FactorySync.domain!)/uploads")
    static let questionUrl = NSURL(string: "\(FactorySync.apiUrl!)/questions/get")
    static let chapterUrl = NSURL(string: "\(FactorySync.apiUrl!)/chapters/get")
    static let subjectUrl = NSURL(string: "\(FactorySync.apiUrl!)/subjects/get")
    static let userUrl = NSURL(string: "\(FactorySync.apiUrl!)/user/connection")
    static let passwordUrl = NSURL(string: "\(FactorySync.apiUrl!)/user/changepass")
    static let imageUrl = NSURL(string: "\(FactorySync.apiUrl!)/uploads/get")
    static let versionUrl = NSURL(string: "\(FactorySync.apiUrl!)/version/get")
    
    static let path: String = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
    
    
    class func getImageManager() -> ImageManager {
        return self.imageManager
    }
    
    class func getQuestionManager() -> QuestionManager {
        return self.questionManager
    }
    
    class func getChapterManager() -> ChapterManager {
        return self.chapterManager
    }
    
    class func getSubjectManager() -> SubjectManager {
        return self.subjectManager
    }
    
    class func getVersionManager() -> VersionManager {
        return self.versionManager
    }
    
    //Called in SyncViewController.swift
    class func sync() {
        println("syncing")
        FactorySync.getImageManager().hasFinishedSync == false
        FactorySync.getQuestionManager().hasFinishedSync == false
        self.realm.write {
            self.realm.deleteAll()
        }
        println("default Realm database cleaned")
        FactorySync.getSubjectManager().saveSubjects()
        // we fetch subjects then chapters then questions in order to avoid Realm bad mapping (ORM)
        FactorySync.getImageManager().sync()
        //we save the new version number
    }
}