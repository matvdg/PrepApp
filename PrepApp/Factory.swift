//
//  Factory.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 21/07/15.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import UIKit
import RealmSwift

class Factory {
    
    static var errorNetwork: Bool = false
    
    private static let imageManager = ImageManager()
    private static let chapterManager = ChapterManager()
    private static let questionManager = QuestionManager()
    private static let subjectManager = SubjectManager()
    private static let realm = FactoryRealm.getRealm()
    
    /*LOCAL OR DISTANT DB*/
    //private static let domain = NSURL(string: "http://p.com/PrepApp")
    private static let domain = NSURL(string: "http://prep-app.com")
    private static let apiUrl = NSURL(string: "\(Factory.domain!)/api")
    
    static let uploadsUrl = NSURL(string: "\(Factory.domain!)/uploads")
    static let questionUrl = NSURL(string: "\(Factory.apiUrl!)/questions/get")
    static let googleUrl = NSURL(string: "https://www.google.fr/images/srpr/logo11w.png")
    static let chapterUrl = NSURL(string: "\(Factory.apiUrl!)/chapters/get")
    static let subjectUrl = NSURL(string: "\(Factory.apiUrl!)/subjects/get")
    static let userUrl = NSURL(string: "\(Factory.apiUrl!)/user/connection")
    static let passwordUrl = NSURL(string: "\(Factory.apiUrl!)/user/changepass")
    static let imageUrl = NSURL(string: "\(Factory.apiUrl!)/uploads/get")
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
    
    //Called in SyncViewController.swift
    class func sync() {
        self.realm.write {
            self.realm.deleteAll()
        }
        println("default Realm database cleaned")
        Factory.getImageManager().sync()
        Factory.getSubjectManager().saveSubjects()
        
        // we fetch subjects then chapters then questions in order to avoid Realm bad mapping (ORM)
    }
    
    
}