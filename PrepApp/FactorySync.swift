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
    private static let configManager = ConfigManager()
    private static let realm = FactoryRealm.getRealm()
    
    /*APIs*/
    //private static let domain = NSURL(string: "http://prep-app.com")
    private static let domain = NSURL(string: "http://192.168.1.30/PrepApp")
    private static let apiUrl = NSURL(string: "\(FactorySync.domain!)/api")
    
    //UPLOADS (images)
    static let uploadsUrl = NSURL(string: "\(FactorySync.domain!)/uploads")
    
    //CONFIG
    static let configUrl = NSURL(string: "\(FactorySync.apiUrl!)/configs/")
    
    //QUESTIONS
    static let questionUrl = NSURL(string: "\(FactorySync.apiUrl!)/questions/")
    static let questionMarkedUrl = NSURL(string: "\(FactorySync.apiUrl!)/questions/mark/")
    static let chapterUrl = NSURL(string: "\(FactorySync.apiUrl!)/chapters/")
    static let subjectUrl = NSURL(string: "\(FactorySync.apiUrl!)/subjects/")
    static let imageUrl = NSURL(string: "\(FactorySync.apiUrl!)/uploads/")

    //DUO
    static let friendUrl = NSURL(string: "\(FactorySync.apiUrl!)/friend/find/")
    static let shuffleDuoUrl = NSURL(string: "\(FactorySync.apiUrl!)/friend/shuffle/")
    static let updateFriendsUrl = NSURL(string: "\(FactorySync.apiUrl!)/friend/update/")
    static let duoUrl = NSURL(string: "\(FactorySync.apiUrl!)/duo/")
    
    //CONTEST
    static let contestUrl = NSURL(string: "\(FactorySync.apiUrl!)/contest/")
    
    //FEEDBACK
    static let feedbackUrl = NSURL(string: "\(FactorySync.apiUrl!)/feedback/")
    
    //LEADERBOARD
    static let leaderboardUrl = NSURL(string: "\(FactorySync.apiUrl!)/leaderboard/")
    
    //USER APIs
    static let userUrl = NSURL(string: "\(FactorySync.apiUrl!)/user/connection/")
    static let passwordUrl = NSURL(string: "\(FactorySync.apiUrl!)/user/update/pass/")
    static let nicknameUrl = NSURL(string: "\(FactorySync.apiUrl!)/user/update/nickname/")
    static let levelUrl = NSURL(string: "\(FactorySync.apiUrl!)/user/update/level/")
    static let awardPointsUrl = NSURL(string: "\(FactorySync.apiUrl!)/user/update/awardPoints/")
    static let historyUrl = NSURL(string: "\(FactorySync.apiUrl!)/user/update/history/")
    static let retrieveHistoryUrl = NSURL(string: "\(FactorySync.apiUrl!)/user/retrieve/history/")
    
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
    
    class func getConfigManager() -> ConfigManager {
        return self.configManager
    }
    
    //Called in SyncViewController.swift
    class func sync() {
        println("syncing")
        FactorySync.getImageManager().hasFinishedSync == false
        FactorySync.getQuestionManager().hasFinishedSync == false
        FactorySync.getSubjectManager().saveSubjects()
        // we fetch subjects then chapters then questions then images in order to avoid Realm bad mapping (ORM)
    }
}