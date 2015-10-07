//
//  DuoManager.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 23/09/15.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import UIKit


class DuoManager {
    
    let realm = FactoryRealm.getRealmDuo()
    
    /*//DUO
    static let retrieveResultsDuoUrl = NSURL(string: "\(FactorySync.apiUrl!)/duo/results/")
    static let sendResultsDuoUrl = NSURL(string: "\(FactorySync.apiUrl!)/duo/results/send")*/
    
    //API
    func requestDuo(idFriend: Int, callback: (Int?, String?) -> Void) {
        let request = NSMutableURLRequest(URL: FactorySync.requestDuoUrl!)
        request.HTTPMethod = "POST"
        let postString = "mail=\(User.currentUser!.email)&pass=\(User.currentUser!.encryptedPassword)&idFriend=\(idFriend)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            (data, response, error) in
            
            dispatch_async(dispatch_get_main_queue()) {
                if error != nil {
                    callback(nil, "Échec de la connexion. Veuillez vérifier que vous êtes connecté à internet avec une bonne couverture cellulaire ou WiFi, puis réessayez.")
                } else {
                    
                    var err: NSError?
                    var statusCode = (response as! NSHTTPURLResponse).statusCode
                    if statusCode == 200 {
                        var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &err) as? NSInteger
                        
                        if let result = jsonResult {
                            if err != nil {
                                println(err)
                                callback(nil, "Échec de la connexion. Veuillez vérifier que vous êtes connecté à internet avec une bonne couverture cellulaire ou WiFi, puis réessayez.")
                            } else {
                                callback(result as Int, nil)
                            }
                        } else {
                            println("error casting json")
                            callback(nil, "Échec de la connexion. Veuillez vérifier que vous êtes connecté à internet avec une bonne couverture cellulaire ou WiFi, puis réessayez.")
                        }

                        
                    } else {
                        println("header status = \(statusCode) in requestDuo")
                        callback(nil, "Il n'y a pas de défi disponible avec cet ami, veuillez réessayer ultérieurement ou essayer avec d'autres amis.")
                    }
                }
            }
            
        }
        task.resume()
    }
    
    private func getPendingDuos(callback: (NSArray?) -> Void) {
        let request = NSMutableURLRequest(URL: FactorySync.pendingDuoUrl!)
        request.HTTPMethod = "POST"
        let postString = "mail=\(User.currentUser!.email)&pass=\(User.currentUser!.encryptedPassword)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            (data, response, error) in
            
            dispatch_async(dispatch_get_main_queue()) {
                if error != nil {
                    println(error)
                    callback(nil)
                } else {
                    
                    var err: NSError?
                    var statusCode = (response as! NSHTTPURLResponse).statusCode
                    if statusCode == 200 {
                        var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as? NSArray
                        
                        if let result = jsonResult {
                            if err != nil {
                                println("error : parsing JSON in getPendingDuos")
                                println(err)
                                callback(nil)
                            } else {
                                callback(result)
                            }
                        } else {
                            println("error : NSArray nil in getPendingDuos")
                            callback(nil)
                        }
                    } else {
                        println("header status = \(statusCode) in getPendingDuos")
                        callback(nil)
                    }
                }
            }
            
        }
        task.resume()
    }
    
    //REALM
    func savePendingDuos(callback: (Bool) -> Void) {
        self.getPendingDuos({ (data) -> Void in
            if let pendingDuos = data {
                self.realm.write({ () -> Void in
                    self.realm.deleteAll()
                })
                for data in pendingDuos {
                    if let pendingDuoData = data as? NSDictionary {
                        var pendingDuo = PendingDuo()
                        pendingDuo.id = pendingDuoData["id"] as! Int
                        pendingDuo.senderId = pendingDuoData["senderId"] as! Int
                        pendingDuo.firstName = pendingDuoData["firstName"] as! String
                        pendingDuo.lastName = pendingDuoData["lastName"] as! String
                        pendingDuo.nickname = pendingDuoData["nickname"] as! String
                        pendingDuo.date = NSDate(timeIntervalSince1970: NSTimeInterval(pendingDuoData["date"] as! Int))
                        self.realm.write({
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
    
    func getPendingDuos() -> [PendingDuo] {
        let pendingDuos = self.realm.objects(PendingDuo)
        var result = [PendingDuo]()
        for pendingDuo in pendingDuos {
            result.append(pendingDuo)
        }
        return result
    }

}
