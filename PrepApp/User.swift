//
//  Post.swift
//  PrepAppKine
//
//  Created by Mathieu Vandeginste on 22/02/15.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import UIKit

class User {
    
    static var currentUser: User?
    static var authenticated: Bool = false
	
    var firstName: String
    var lastName: String
    var email: String
    var encryptedPassword: String
    var level: Int
    var awardPoints: Int
    var nickname: String
    
    init(
        firstName: String,
        lastName: String,
        email: String,
        encryptedPassword: String,
        level: Int,
        awardPoints: Int,
        nickname: String) {
            
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.encryptedPassword = encryptedPassword
        self.level = level
        self.awardPoints = awardPoints
        self.nickname = nickname
    }
	
	func changePassword(newPass: String, callback: (String?) -> Void){
		let request = NSMutableURLRequest(URL: FactorySync.passwordUrl!)
		request.HTTPMethod = "POST"
		let postString = "mail=\(User.currentUser!.email)&pass=\(User.currentUser!.encryptedPassword)&new_pass=\(newPass)"
		request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
		let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
			(data, response, error) in
			dispatch_async(dispatch_get_main_queue()) {
				if error != nil {
					callback("Échec de la connexion. Vérifier la connexion Internet et réessayer.")
				} else {
					var err: NSError?
					var statusCode = (response as! NSHTTPURLResponse).statusCode
					if statusCode == 200 {
						User.currentUser!.encryptedPassword = newPass
						User.currentUser!.saveUser()
						callback("Mot de passe changé avec succès.")
					} else {
						callback("Erreur de connexion, veuillez réessayer ultérieurement.")
					}
				}
			}
		}
		task.resume()
	}
    
    func changeNickname(newNickname: String, callback: (String?) -> Void){
        let request = NSMutableURLRequest(URL: FactorySync.nicknameUrl!)
        request.HTTPMethod = "POST"
        let postString = "mail=\(User.currentUser!.email)&pass=\(User.currentUser!.encryptedPassword)&nickname=\(newNickname)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            (data, response, error) in
            dispatch_async(dispatch_get_main_queue()) {
                if error != nil {
                    callback("Échec de la connexion. Vérifier la connexion Internet et réessayer.")
                } else {
                    var err: NSError?
                    var statusCode = (response as! NSHTTPURLResponse).statusCode
                    if statusCode == 200 {
                        User.currentUser!.nickname = newNickname
                        User.currentUser!.saveUser()
                        callback("Pseudo changé avec succès.")
                    } else {
                        callback("Erreur de connexion, veuillez réessayer ultérieurement.")
                    }
                }
            }
        }
        task.resume()
    }
    
    func updateLevel(newLevel: Int){
        let request = NSMutableURLRequest(URL: FactorySync.levelUrl!)
        request.HTTPMethod = "POST"
        let postString = "mail=\(User.currentUser!.email)&pass=\(User.currentUser!.encryptedPassword)&level=\(newLevel)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            (data, response, error) in
            dispatch_async(dispatch_get_main_queue()) {
                if error == nil {
                    var err: NSError?
                    var statusCode = (response as! NSHTTPURLResponse).statusCode
                    if statusCode == 200 {
                        User.currentUser!.level = newLevel
                        User.currentUser!.saveUser()
                        println("level synced")
                    }
                }
            }
        }
        task.resume()
    }

    func updateAwardPoints(newAwardPoints: Int){
        let request = NSMutableURLRequest(URL: FactorySync.awardPointsUrl!)
        request.HTTPMethod = "POST"
        let postString = "mail=\(User.currentUser!.email)&pass=\(User.currentUser!.encryptedPassword)&awardPoints=\(newAwardPoints)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            (data, response, error) in
            dispatch_async(dispatch_get_main_queue()) {
                if error == nil {
                    var err: NSError?
                    var statusCode = (response as! NSHTTPURLResponse).statusCode
                    if statusCode == 200 {
                        User.currentUser?.awardPoints = newAwardPoints
                        User.currentUser!.saveUser()
                        println("awardPoints synced")
                    }
                }
            }
        }
        task.resume()
    }

	func saveUser() {
		//we backup the user in a string array for persistence storage
		var savedUser = [
            self.firstName,
            self.lastName,
            self.email,
            self.encryptedPassword,
            String(self.level),
            String(self.awardPoints),
            self.nickname
        ]
		NSUserDefaults.standardUserDefaults().setObject(savedUser, forKey: "user")
		NSUserDefaults.standardUserDefaults().synchronize()
	}

	static func login(mail: String, pass: String, callback: (NSDictionary?, String?) -> Void) {
		let request = NSMutableURLRequest(URL: FactorySync.userUrl!)
		request.HTTPMethod = "POST"
		let encryptedPassword = pass.sha1()
		let postString = "mail=\(mail)&pass=\(encryptedPassword)"
		request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
		let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
			(data, response, error) in
			
			dispatch_async(dispatch_get_main_queue()) {
				if error != nil {
                    // no connexion
					callback(nil, "Échec de la connexion. Vérifier la connexion Internet et réessayer.")
				} else {
					var err: NSError?
					var statusCode = (response as! NSHTTPURLResponse).statusCode
					if statusCode == 200 {
						var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as? NSDictionary
						
						if let result = jsonResult {
							if err != nil {
								callback(nil, "Erreur lors de la récupération, veuillez réessayer.")
							} else {
								callback(result as NSDictionary, nil)
							}
						} else {
                            //NSDictionary optional to nil
							callback(nil, "Erreur lors de la récupération, veuillez réessayer.")
						}
						
					} else {
                        //!= 200
						callback(nil, "Email ou mot de passe incorrects, veuillez réessayer.")
					}
				}
			}
		}
		task.resume()
	}
	
	static func instantiateUser(data: NSDictionary, pass:String) {
		//we instantiate the user retrieved in the distant DB into the  dictionary
		currentUser = User(
			firstName: data["first_name"] as! String,
			lastName: data["last_name"] as! String,
			email: data["mail"] as! String,
			encryptedPassword: pass.sha1() as String,
			level: data["level"] as! Int,
            awardPoints: data["award_points"] as! Int,
            nickname: data["nickname"] as! String
        )
        
        User.authenticated = true
	}
	
	static func instantiateUserStored() -> Bool {
		var data : [String] = []
        UserPreferences.loadUserPreferences()
		//we instantiate the user retrieved in the local Persistence Storage
		if var storedUser : AnyObject = NSUserDefaults.standardUserDefaults().objectForKey("user") {
			for (var i=0; i < storedUser.count; i++) {
				data.append(storedUser[i] as! String)
			}
            
            User.currentUser = User(
                firstName: data[0] as String,
                lastName: data[1] as String,
                email: data[2] as String,
                encryptedPassword: data[3] as String,
                level: (data[4] as String).toInt()!,
                awardPoints: (data[5] as String).toInt()!,
                nickname: data[6] as String
            )
			return true
		} else {
			return false
		}
	}
	
    

}





