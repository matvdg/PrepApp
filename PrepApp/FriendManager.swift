//
//  Duo.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 23/09/15.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import UIKit


class FriendManager {
    
    let realm = FactoryRealm.getRealmFriends()
    
    private func getFriend(code: String, callback: (NSDictionary?, String) -> Void) {
        
        let request = NSMutableURLRequest(URL: FactorySync.friendUrl!)
        request.HTTPMethod = "POST"
        let postString = "mail=\(User.currentUser!.email)&pass=\(User.currentUser!.encryptedPassword)&id=\(code)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            (data, response, error) in
            
            dispatch_async(dispatch_get_main_queue()) {
                if error != nil {
                    callback(nil, "Veuillez vérifier que vous êtes connecté à internet avec une bonne couverture cellulaire ou WiFi, puis réessayez.")
                } else {
                    
                    var err: NSError?
                    var statusCode = (response as! NSHTTPURLResponse).statusCode
                    if statusCode == 200 {
                        var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as? NSDictionary
                        
                        if let result = jsonResult {
                            if err != nil {
                                println("error : parsing JSON in getFriend")
                                callback(nil, "Veuillez vérifier que vous êtes connecté à internet avec une bonne couverture cellulaire ou WiFi, puis réessayez.")
                            } else {
                                var name = ""
                                if FactorySync.getConfigManager().loadNicknamePreference() {
                                    name = result["nickname"] as! String
                                } else {
                                    var first = result["firstName"] as! String
                                    var last = result["lastName"] as! String
                                    name = "\(first) \(last)"
                                }
                                callback(result as NSDictionary, "\(name) a été ajouté à votre liste d'amis !")
                            }
                        } else {
                            println("error : NSArray nil in getFriend")
                            callback(nil, "Veuillez vérifier que vous êtes connecté à internet avec une bonne couverture cellulaire ou WiFi, puis réessayez.")
                        }
                    } else {
                        println("header status = \(statusCode) in getFriend")
                        callback(nil, "Le code entré est invalide !")
                    }
                }
            }
            
        }
        task.resume()
    }

    private func getShuffle(callback: (NSDictionary?) -> Void) {
        
        let request = NSMutableURLRequest(URL: FactorySync.shuffleDuoUrl!)
        request.HTTPMethod = "POST"
        let postString = "mail=\(User.currentUser!.email)&pass=\(User.currentUser!.encryptedPassword)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            (data, response, error) in
            
            dispatch_async(dispatch_get_main_queue()) {
                if error != nil {
                    println("error : no connexion in getFriend")
                    callback(nil)
                } else {
                    
                    var err: NSError?
                    var statusCode = (response as! NSHTTPURLResponse).statusCode
                    if statusCode == 200 {
                        var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as? NSDictionary
                        
                        if let result = jsonResult {
                            if err != nil {
                                println("error : parsing JSON in getFriend")
                                callback(nil)
                            } else {
                                callback(result as NSDictionary)
                            }
                        } else {
                            println("error : NSArray nil in getFriend")
                            callback(nil)                        }
                    } else {
                        println("header status = \(statusCode) in getFriend")
                        callback(nil)
                    }
                }
            }
            
        }
        task.resume()
    }
    
    func saveFriend(code: String, callback: (Bool, String) -> Void) {
        self.getFriend(code, callback: { (data, message) -> Void in
            if let friend = data {
                var newFriend = Friend()
                newFriend.id = friend["id"] as! Int
                newFriend.firstName = friend["firstName"] as! String
                newFriend.lastName = friend["lastName"] as! String
                newFriend.nickname = friend["nickname"] as! String
                self.realm.write({
                    self.realm.add(newFriend, update: true)
                })
                callback(true, message)
            } else {
                callback(false, message)
            }
        })
    }
    
    func deleteFriend(friendToRemove: Friend) {
        self.realm.write({
            self.realm.delete(friendToRemove)
            println("friend removed")
        })
    }
    
    func getFriends() -> [Friend] {
        let friends = self.realm.objects(Friend)
        var result = [Friend]()
        for friend in friends {
            result.append(friend)
        }
        return result
    }
    
    
    
    

}
