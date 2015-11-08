//
//  FriendManager.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 23/09/15.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import UIKit


class FriendManager {
    
    let realm = FactoryRealm.getRealmFriends()
    
    //API
    private func findFriend(code: String, callback: (NSDictionary?, String) -> Void) {
        
        let request = NSMutableURLRequest(URL: FactorySync.findFriendUrl!)
        request.HTTPMethod = "POST"
        let postString = "mail=\(User.currentUser!.email)&pass=\(User.currentUser!.encryptedPassword)&id=\(code)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            (data, response, error) in
            
            dispatch_async(dispatch_get_main_queue()) {
                if error != nil {
                    callback(nil, "Veuillez vérifier que vous êtes connecté à internet avec une bonne couverture cellulaire ou WiFi, puis réessayez.")
                } else {
                    let statusCode = (response as! NSHTTPURLResponse).statusCode
                    if statusCode == 200 {
                        let jsonResult = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                        
                        if let result = jsonResult {
                            var name = ""
                            if FactorySync.getConfigManager().loadNicknamePreference() {
                                name = result["nickname"] as! String
                            } else {
                                let first = result["firstName"] as! String
                                let last = result["lastName"] as! String
                                name = "\(first) \(last)"
                            }
                            print(result)
                            callback(result as NSDictionary, "\(name) a été ajouté à votre liste d'amis !")
                        } else {
                            print("error : NSArray nil in getFriend")
                            callback(nil, "Veuillez vérifier que vous êtes connecté à internet avec une bonne couverture cellulaire ou WiFi, puis réessayez.")
                        }
                    } else {
                        print("header status = \(statusCode) in getFriend")
                        callback(nil, "Le code entré est invalide !")
                    }
                }
            }
            
        }
        task.resume()
    }

    private func getShuffle(callback: (NSDictionary?, String?) -> Void) {
        
        let request = NSMutableURLRequest(URL: FactorySync.shuffleFriendUrl!)
        request.HTTPMethod = "POST"
        let postString = "mail=\(User.currentUser!.email)&pass=\(User.currentUser!.encryptedPassword)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            (data, response, error) in
            
            dispatch_async(dispatch_get_main_queue()) {
                if error != nil {
                    print("error : no connexion in getFriend")
                    callback(nil,"Échec de la connexion. Veuillez vérifier que vous êtes connecté à internet avec une bonne couverture cellulaire ou WiFi, puis réessayez." )
                } else {
                    let statusCode = (response as! NSHTTPURLResponse).statusCode
                    if statusCode == 200 {
                        let jsonResult = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                        
                        if let result = jsonResult {
                            callback(result as NSDictionary, nil)
                        } else {
                            print("error : NSArray nil in getFriend")
                            callback(nil, "Échec de la connexion. Veuillez vérifier que vous êtes connecté à internet avec une bonne couverture cellulaire ou WiFi, puis réessayez.")
                        }
                    } else {
                        print("header status = \(statusCode) in getFriend")
                        callback(nil, "Il n'y a plus de défi disponible, veuillez réessayer ultérieurement")
                    }
                }
            }
            
        }
        task.resume()
    }
    
    func shuffleDuo(callback: (Friend?, String?) -> Void) {
        self.getShuffle { (data, error) -> Void in
            if let friend = data {
                let shuffledFriend = Friend()
                shuffledFriend.id = friend["id"] as! Int
                shuffledFriend.firstName = friend["firstName"] as! String
                shuffledFriend.lastName = friend["lastName"] as! String
                shuffledFriend.nickname = friend["nickname"] as! String
                shuffledFriend.awardPoints = friend["awardPoints"] as! Int
                callback(shuffledFriend, nil)
            } else {
                callback(nil, error)
            }
        }
    }
    
    private func retrieveFriends(callback: (NSArray?) -> Void) {
        let request = NSMutableURLRequest(URL: FactorySync.retrieveFriendsUrl!)
        request.HTTPMethod = "POST"
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
                            print("error : NSArray nil in getFriend")
                            callback(nil)
                        }
                    } else {
                        print("header status = \(statusCode) in getFriend")
                        callback(nil)
                    }
                }
            }
            
        }
        task.resume()
    }

    func syncFriendsList(callback: (Bool) -> Void) {
        let friendList = self.realm.objects(Friend)
        var post: [Int] = []
        for friend in friendList {
            post.append(friend.id)
        }
        let json = try? NSJSONSerialization.dataWithJSONObject(post, options: NSJSONWritingOptions(rawValue: 0))
        let friendsList = NSString(data: json!, encoding: NSUTF8StringEncoding)
        self.updateFriends(friendsList!, callback: { (result) -> Void in
            callback(result)
        })
    }
    
    private func updateFriends(friendsList: NSString, callback: (Bool) -> Void){
        let request = NSMutableURLRequest(URL: FactorySync.updateFriendsUrl!)
        request.HTTPMethod = "POST"
        let postString = "mail=\(User.currentUser!.email)&pass=\(User.currentUser!.encryptedPassword)&friends=\(friendsList)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            (data, response, error) in
            dispatch_async(dispatch_get_main_queue()) {
                if error == nil {
                    let statusCode = (response as! NSHTTPURLResponse).statusCode
                    if statusCode == 200 {
                        callback(true)
                    } else {
                        print(statusCode)
                        callback(false)
                    }
                } else {
                    print(error)
                    callback(false)
                }
            }
        }
        task.resume()
    }

    
    //REALM
    func saveFriend(code: String, callback: (Bool, String) -> Void) {
        self.findFriend(code, callback: { (data, message) -> Void in
            if let friend = data {
                let newFriend = Friend()
                newFriend.id = friend["id"] as! Int
                newFriend.firstName = friend["firstName"] as! String
                newFriend.lastName = friend["lastName"] as! String
                newFriend.nickname = friend["nickname"] as! String
                newFriend.awardPoints = friend["awardPoints"] as! Int
                try! self.realm.write({
                    self.realm.add(newFriend, update: true)
                })
                callback(true, message)
            } else {
                callback(false, message)
            }
        })
    }
    
    func saveFriends(callback: (Bool) -> Void) {
        self.retrieveFriends({ (data) -> Void in
            if let friendList = data {
                try! self.realm.write({ () -> Void in
                    self.realm.deleteAll()
                })
                for data in friendList {
                    if let friend = data as? NSDictionary {
                        let newFriend = Friend()
                        newFriend.id = friend["id"] as! Int
                        newFriend.firstName = friend["firstName"] as! String
                        newFriend.lastName = friend["lastName"] as! String
                        newFriend.nickname = friend["nickname"] as! String
                        newFriend.awardPoints = friend["awardPoints"] as! Int
                        try! self.realm.write({
                            self.realm.add(newFriend, update: true)
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
    
    func deleteFriend(friendToRemove: Friend) {
        try! self.realm.write({
            self.realm.delete(friendToRemove)
            print("friend removed")
        })
        self.syncFriendsList { (result) -> Void in
            if result {
                print("friendsList synced")
            } else {
                print("error syncing friendsList")
            }
        }
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
