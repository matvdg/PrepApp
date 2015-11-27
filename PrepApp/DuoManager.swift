//
//  DuoManager.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 23/09/15.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import UIKit


class DuoManager {
    
    private let realm = FactoryRealm.getRealm()
    
    //API
    func requestDuo(idFriend: Int, callback: (Int?, String?) -> Void) {
        let request = NSMutableURLRequest(URL: FactorySync.requestDuoUrl!)
        request.HTTPMethod = "POST"
        request.timeoutInterval = NSTimeInterval(5)
        let postString = "mail=\(User.currentUser!.email)&pass=\(User.currentUser!.encryptedPassword)&idFriend=\(idFriend)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            (data, response, error) in
            
            dispatch_async(dispatch_get_main_queue()) {
                if error != nil {
                    callback(nil, "Échec de la connexion. Veuillez vérifier que vous êtes connecté à internet avec une bonne couverture cellulaire ou WiFi, puis réessayez.")
                } else {
                    let statusCode = (response as! NSHTTPURLResponse).statusCode
                    if statusCode == 200 {
                        let jsonResult = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as? NSInteger
                        
                        if let result = jsonResult {
                            callback(result as Int, nil)
                        } else {
                            print("error casting json")
                            callback(nil, "Échec de la connexion. Veuillez vérifier que vous êtes connecté à internet avec une bonne couverture cellulaire ou WiFi, puis réessayez.")
                        }

                        
                    } else {
                        print("header status = \(statusCode) in requestDuo")
                        callback(nil, "Il n'y a pas de défi disponible avec cet ami, veuillez réessayer ultérieurement ou essayer avec d'autres amis.")
                    }
                }
            }
            
        }
        task.resume()
    }
    
    func sendResultsDuo(idDuo: Int, success: Int, callback: (Bool, String) -> Void) {
        let request = NSMutableURLRequest(URL: FactorySync.sendDuoResultsUrl!)
        request.HTTPMethod = "POST"
        request.timeoutInterval = NSTimeInterval(5)
        let postString = "mail=\(User.currentUser!.email)&pass=\(User.currentUser!.encryptedPassword)&idDuo=\(idDuo)&success=\(success)"
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
                        print("header status = \(statusCode) in requestDuo")
                        callback(true, "Vous avez dépassé le délai de 24h. Vous ne pouvez pas envoyer vos résultats ni recevoir d'AwardPoints en bonus. Veuillez vérifier la date et l'heure de votre appareil pour éviter de rencontrer à nouveau ce problème.")
                    }
                }
            }
        }
        task.resume()
    }

    private func retrievePendingDuos(callback: (NSArray?) -> Void) {
        let request = NSMutableURLRequest(URL: FactorySync.pendingDuoUrl!)
        request.HTTPMethod = "POST"
        request.timeoutInterval = NSTimeInterval(5)
        let postString = "mail=\(User.currentUser!.email)&pass=\(User.currentUser!.encryptedPassword)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            (data, response, error) in
            
            dispatch_async(dispatch_get_main_queue()) {
                if error != nil {
                    print(error!)
                    callback(nil)
                } else {
                    
                    let statusCode = (response as! NSHTTPURLResponse).statusCode
                    if statusCode == 200 {
                        let jsonResult = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSArray
                        
                        if let result = jsonResult {
                            callback(result)
                        } else {
                            print("error : NSArray nil in getPendingDuos")
                            callback(nil)
                        }
                    } else {
                        print("header status = \(statusCode) in getPendingDuos")
                        callback(nil)
                    }
                }
            }
            
        }
        task.resume()
    }
    
    private func retrieveDataResultsDuo(callback: (NSDictionary?, Bool) -> Void) {
        let request = NSMutableURLRequest(URL: FactorySync.retrieveDuoResultsUrl!)
        request.HTTPMethod = "POST"
        request.timeoutInterval = NSTimeInterval(5)
        let postString = "mail=\(User.currentUser!.email)&pass=\(User.currentUser!.encryptedPassword)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            (data, response, error) in
            
            dispatch_async(dispatch_get_main_queue()) {
                if error != nil {
                    print("retrieveDataResultsDuo offline")
                    callback(nil, false)
                } else {
                    let statusCode = (response as! NSHTTPURLResponse).statusCode
                    if statusCode == 200 {
                        let jsonResult = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                        if let result = jsonResult {
                            callback(result, true)
                        } else {
                            print("error : NSArray nil in retrieveDataResultsDuo")
                            callback(nil, false)
                        }
                    } else {
                        callback(nil, false)
                    }
                }
            }
        }
        task.resume()
    }
    
    private func retrieveResultsDuo(callback: ([ResultDuo]?) -> Void) {
        self.retrieveDataResultsDuo { (data, notification) -> Void in
            if notification { //online even if empty
                var result = [ResultDuo]()
                if let dico = data {
                    for (id,value) in dico {
                        let idDuo = Int(id as! String)!
                        var results = [Result]()
                        if let array = value as? NSArray {
                            for element in array {
                                if let dicoResult = element as? NSDictionary {
                                    let newResult = Result()
                                    newResult.id = dicoResult["id"] as! Int
                                    newResult.firstName = dicoResult["firstName"] as! String
                                    newResult.lastName = dicoResult["lastName"] as! String
                                    newResult.nickname = dicoResult["nickname"] as! String
                                    newResult.score = dicoResult["score"] as! Int
                                    results.append(newResult)
                                }
                            }
                            result.append(
                                ResultDuo(value: [
                                    "idDuo" : idDuo,
                                    "resultDuo" : results ]))
                        }
                    }
                }
                callback(result)
            } else { //offline or error or nothing new
                callback(nil)
            }
        }
    }

    
    //REALM
    private func savePendingDuos(callback: (Bool) -> Void) {
        self.retrievePendingDuos({ (data) -> Void in
            if let pendingDuos = data {
                try! self.realm.write({ () -> Void in
                    self.realm.delete(self.realm.objects(PendingDuo))
                })
                for data in pendingDuos {
                    if let pendingDuoData = data as? NSDictionary {
                        let pendingDuo = PendingDuo()
                        pendingDuo.id = pendingDuoData["id"] as! Int
                        pendingDuo.senderId = pendingDuoData["senderId"] as! Int
                        pendingDuo.firstName = pendingDuoData["firstName"] as! String
                        pendingDuo.lastName = pendingDuoData["lastName"] as! String
                        pendingDuo.nickname = pendingDuoData["nickname"] as! String
                        pendingDuo.date = NSDate(timeIntervalSince1970: NSTimeInterval(pendingDuoData["date"] as! Int))
                        try! self.realm.write({
                            self.realm.add(pendingDuo, update: true)
                        })
                        
                    } else {
                        callback(false)
                    }
                }
                callback(true)
                
            } else {
                callback(false)
            }
        })
    }
    
    private func getPendingDuosFromDB() -> [PendingDuo] {
        let pendingDuos = self.realm.objects(PendingDuo)
        var result = [PendingDuo]()
        for pendingDuo in pendingDuos {
            //fetching expiration
            let offsetComponents = NSDateComponents()
            offsetComponents.minute = 24*60 - FactorySync.getConfigManager().loadDuration()
            let initDate = pendingDuo.date
            let expirationDate = NSCalendar.currentCalendar().dateByAddingComponents(offsetComponents, toDate: initDate, options: NSCalendarOptions(rawValue: 0))!
            let comparison = NSCalendar.currentCalendar().compareDate(NSDate(), toDate: expirationDate, toUnitGranularity: NSCalendarUnit.Second)
            if comparison == NSComparisonResult.OrderedAscending {
                result.append(pendingDuo)
            }
        }
        return result
    }
    
    ///callback array of PendingDuo from Realm if offline, from API if online (+backup to RealmDB)
    func getPendingDuos(callback: ([PendingDuo]) -> Void) {
        self.savePendingDuos { (result) -> Void in
            callback(self.getPendingDuosFromDB())
        }
    }
    
     ///delete a PendingDuo from RealmDB
    func deletePendingDuo(pendindDuoToRemove: PendingDuo) {
        try! self.realm.write({
            self.realm.delete(pendindDuoToRemove)
            print("pendindDuo removed")
        })
    }
    
    ///delete a ResultDuo from RealmDB
    func deleteResultDuo(resultDuoToRemove: ResultDuo) {
        try! self.realm.write({
            let resultA = resultDuoToRemove.resultDuo.first!
            let resultB = resultDuoToRemove.resultDuo.last!
            self.realm.delete(resultDuoToRemove)
            self.realm.delete(resultA)
            self.realm.delete(resultB)
            print("resultDuo removed")
        })
    }
    
    ///callback array of ResultsDuo from Realm if offline, from API if online (+backup to RealmDB) AND Bool if notification needed
    func getResultsDuo(callback: ([ResultDuo], Bool) -> Void) {
        self.retrieveResultsDuo { (data) -> Void in
            var result = [ResultDuo]()
            if let resultsDuo = data {
                //new results = notification to send
                for resultDuo in resultsDuo {
                    result.append(resultDuo)
                    try! self.realm.write({
                        self.realm.add(resultDuo)
                    })
                }
                callback(result, true)
            } else {
                //offline or error or nothing new so we fetch old results from Realm DB
                let resultsDuo = self.realm.objects(ResultDuo)
                for resultDuo in resultsDuo {
                    result.append(resultDuo)
                }
                callback(result, false)
            }
        }
    }
    
    //mark a resultDuo as read to avoid crediting AP again
    func updateResultDuo(resultDuoToUpdate: ResultDuo) {
        let resultsDuo = self.realm.objects(ResultDuo)
        for resultDuo in resultsDuo {
            if resultDuo.idDuo == resultDuoToUpdate.idDuo {
                try! self.realm.write {
                    resultDuo.firstTime = false
                }
                break
            }
        }
    }


}
