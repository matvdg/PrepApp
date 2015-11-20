//
//  ContestManager.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 11/11/2015.
//  Copyright © 2015 PrepApp. All rights reserved.
//

import UIKit

class ContestManager {
    
    private var realm = FactoryRealm.getRealm()

    
    //API
    private func retrieveContests(callback: (NSArray?) -> Void) {
        let request = NSMutableURLRequest(URL: FactorySync.contestUrl!)
        request.HTTPMethod = "POST"
        request.timeoutInterval = NSTimeInterval(5)
        let postString = "mail=\(User.currentUser!.email)&pass=\(User.currentUser!.encryptedPassword)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            (data, response, error) in
            
            dispatch_async(dispatch_get_main_queue()) {
                if error != nil {
                    print("retrieveContests offline")
                    callback(nil)
                } else {
                    let statusCode = (response as! NSHTTPURLResponse).statusCode
                    if statusCode == 200 {
                        let jsonResult = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSArray
                        
                        if let result = jsonResult {
                            callback(result)
                        } else {
                            print("error : NSArray nil in retrieveContests")
                            callback(nil)
                        }
                    } else {
                        print("header status = \(statusCode) in retrieveContests")
                        callback(nil)
                    }
                }
            }
        }
        task.resume()
    }
    
    private func retrieveDataContestLeaderboards(callback: (NSArray?, Bool) -> Void) {
        let request = NSMutableURLRequest(URL: FactorySync.retrieveContestLeaderboardsUrl!)
        request.HTTPMethod = "POST"
        request.timeoutInterval = NSTimeInterval(5)
        let postString = "mail=\(User.currentUser!.email)&pass=\(User.currentUser!.encryptedPassword)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            (data, response, error) in
            
            dispatch_async(dispatch_get_main_queue()) {
                if error != nil {
                    print("retrieveContestLeaderboards offline")
                    callback(nil, false)
                } else {
                    let statusCode = (response as! NSHTTPURLResponse).statusCode
                    if statusCode == 200 {
                        let jsonResult = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSArray
                        
                        if let result = jsonResult {
                            callback(result, true)
                        } else {
                            print("error : NSArray nil in retrieveContestLeaderboards")
                            callback(nil, false)
                        }
                    } else {
                        print("no leaderboard available yet")
                        callback(nil, true)
                    }
                }
            }
        }
        task.resume()
    }
    
    ///callback array of ContestLeaderboard from API
    private func retrieveContestLeaderboards(callback: ([ContestLeaderboard]?) -> Void) {
        self.retrieveDataContestLeaderboards { (data, online) -> Void in
            if online { //online even if empty
                var result = [ContestLeaderboard]()
                if let array = data {
                    for element in array {
                        if let dico = element as? NSDictionary {
                            let id = dico["id"] as! Int
                            let name = dico["name"] as! String
                            let board = dico["leaderboard"] as! NSArray
                            var players = [ContestPlayer]()
                            for playerData in board {
                                if let player = playerData as? NSDictionary {
                                    let newPlayer = ContestPlayer()
                                    newPlayer.firstName = player["firstName"] as! String
                                    newPlayer.lastName = player["lastName"] as! String
                                    newPlayer.nickname = player["nickname"] as! String
                                    newPlayer.points = player["points"] as! Float
                                    players.append(newPlayer)
                                }
                            }
                            result.append(ContestLeaderboard(value: [
                                "id" : id,
                                "name" : name,
                                "players" : players ]))
                        }
                    }
                }
                callback(result)
            } else { //offline or error
                callback(nil)
            }
        }
    }

    func sendResultsContest(idContest: Int, points: Float, callback: (Bool, String) -> Void) {
        let request = NSMutableURLRequest(URL: FactorySync.sendContestResultsUrl!)
        request.HTTPMethod = "POST"
        request.timeoutInterval = NSTimeInterval(5)
        let postString = "mail=\(User.currentUser!.email)&pass=\(User.currentUser!.encryptedPassword)&idContest=\(idContest)&points=\(points)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            (data, response, error) in
            
            dispatch_async(dispatch_get_main_queue()) {
                if error != nil {
                    callback(false, "Échec de la connexion. Veuillez vérifier que vous êtes connecté à internet avec une bonne couverture cellulaire ou WiFi, puis réessayez.")
                } else {
                    let statusCode = (response as! NSHTTPURLResponse).statusCode
                    if statusCode == 200 {
                        callback(true, "Résultats envoyés avec succès au serveur")
                    } else {
                        print("header status = \(statusCode) in sendResultsContest")
                        callback(true, "Vous avez dépassé la date de fin de concours. Vous ne pouvez pas envoyer vos résultats ni recevoir d'AwardPoints en bonus. Veuillez vérifier la date et l'heure de votre appareil pour éviter de rencontrer à nouveau ce problème.")
                    }
                }
            }
        }
        task.resume()
    }

    
    //REALM
    
    ///callback array of Contest from Realm if offline, from API if online (+backup to RealmDB)
    func getContests(callback: ([Contest]) -> Void) {
        
        self.retrieveContests { (data) -> Void in
            var result = [Contest]()
            if let contests = data {
                //online
                try! self.realm.write({
                    self.realm.delete(self.realm.objects(Contest))
                })
                for content in contests {
                    if let contest = content as? NSDictionary {
                        let newContest = Contest()
                        newContest.id = contest["id"] as! Int
                        newContest.duration = contest["duration"] as! Int
                        newContest.name = contest["name"] as! String
                        var description = ""
                        //"<body style=\"background-color: transparent;\">"
                        description += contest["description"] as! String
                        //description += "</body>"
                        newContest.content = description
                        newContest.goodAnswer = contest["goodAnswer"] as! Float
                        newContest.wrongAnswer = contest["wrongAnswer"] as! Float
                        newContest.noAnswer = contest["noAnswer"] as! Float
                        newContest.begin = NSDate(timeIntervalSince1970: NSTimeInterval(contest["begin"] as! Int))
                        newContest.end = NSDate(timeIntervalSince1970: NSTimeInterval(contest["end"] as! Int))
                        try! self.realm.write({
                            self.realm.add(newContest)
                        })
                        result.append(newContest)
                    }
                }
            } else {
                //offline
                print("contests offline")
                let contests = self.realm.objects(Contest)
                for contest in contests {
                    result.append(contest)
                }
            }
            callback(result)
        }
    }
    
    ///callback array of ContestLeaderboard from Realm if offline, from API if online (+backup to RealmDB)
    func getContestLeaderboards(callback: ([ContestLeaderboard]) -> Void) {
        self.retrieveContestLeaderboards { (data) -> Void in
            var result = [ContestLeaderboard]()
            if let contestLeaderboards = data {
                //online
                try! self.realm.write({
                    self.realm.delete(self.realm.objects(ContestLeaderboard))
                    self.realm.delete(self.realm.objects(ContestPlayer))
                })
                for contestLeaderboard in contestLeaderboards {
                    result.append(contestLeaderboard)
                    try! self.realm.write({
                        self.realm.add(contestLeaderboard)
                    })
                }
            } else {
                //offline
                print("contestLearderboards offline")
                let contestLeaderboards = self.realm.objects(ContestLeaderboard)
                for contestLeaderboard in contestLeaderboards {
                    result.append(contestLeaderboard)
                }
            }
            callback(result)
        }
    }

    ///save resultsContest to RealmDB ContestHistory
    func saveResultsContest(contest: Contest, score: Int, emptyAnswers: Int, succeeded: Int, numberOfQuestions: Int ) {
        let resultsContest = ContestHistory()
        resultsContest.id = contest.id
        resultsContest.duration = contest.duration
        resultsContest.name = contest.name
        resultsContest.content = contest.content
        resultsContest.goodAnswer = contest.goodAnswer
        resultsContest.noAnswer = contest.noAnswer
        resultsContest.wrongAnswer = contest.wrongAnswer
        resultsContest.begin = contest.begin
        resultsContest.end = contest.end
        resultsContest.score = score
        resultsContest.emptyAnswers = emptyAnswers
        resultsContest.succeeded = succeeded
        resultsContest.numberOfQuestions = numberOfQuestions
        do {
            try self.realm.write({
                self.realm.add(resultsContest)
            })
        } catch {
            print(error)
        }
        
    }
    
    ///get a resultContest from local RealmDB
    func getResultContest(id: Int) -> ContestHistory? {
        if !realm.objects(ContestHistory).filter("id = \(id)").isEmpty {
            return realm.objects(ContestHistory).filter("id = \(id)").first
        } else {
            return nil
        }
    }
    
    ///get resultContests from local RealmDB
    func getResultContests() -> [ContestHistory] {
        var result = [ContestHistory]()
        let contestsHistory = self.realm.objects(ContestHistory)
        for contestHistory in contestsHistory {
            result.append(contestHistory)
        }
        return result
    }
    
}