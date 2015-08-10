//
//  Post.swift
//  PrepAppKine
//
//  Created by Mathieu Vandeginste on 22/02/15.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import Foundation

class User {
    
    static var currentUser: User?
    static var authenticated: Bool = false
	
    var firstName: String
    var lastName: String
    var email: String
    var encryptedPassword: String
    var level: Int
    var assiduity: Int
    var failed: Int
    var success: Int
    var touchId: Bool
    var sounds: Bool
    
    init(firstName :String,lastName :String,email :String,encryptedPassword :String,level : Int,assiduity : Int,failed : Int,success : Int, touchId: Bool, sounds: Bool) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.encryptedPassword = encryptedPassword
        self.level = level
        self.assiduity = assiduity
        self.failed = failed
        self.success = success
        self.touchId = touchId
        self.sounds = sounds
    }
	
	func printUser() -> String {
		return ("Niveau \(self.level) \n Assiduité \(self.assiduity) \n \(self.success) questions réussies sur \(self.success + self.failed)")
	}
	
	func changePassword(newPass: String, callback: (String?) -> Void){
		let request = NSMutableURLRequest(URL: Factory.passwordUrl!)
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
						User.currentUser?.encryptedPassword = newPass
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
	
	func saveUser() {
		//we backup the user in a string array for persistence storage
        
		var savedUser = [
            self.firstName,
            self.lastName,
            self.email,
            self.encryptedPassword,
            String(self.level),
            String(self.assiduity),
            String(self.failed),
            String(self.success),
            String(stringInterpolationSegment: self.touchId),
            String(stringInterpolationSegment: self.sounds)
        ]
		NSUserDefaults.standardUserDefaults().setObject(savedUser, forKey: "user")
		NSUserDefaults.standardUserDefaults().synchronize()
	}

	static func login(mail: String, pass: String, callback: (NSDictionary?, String?) -> Void) {
		let request = NSMutableURLRequest(URL: Factory.userUrl!)
		request.HTTPMethod = "POST"
		let encryptedPassword = pass.sha1()
		let postString = "mail=\(mail)&pass=\(encryptedPassword)"
		request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
		let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
			(data, response, error) in
			
			dispatch_async(dispatch_get_main_queue()) {
				if error != nil {
                    // pas de connexion
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
                                //erreur parsage JSON
								callback(result as NSDictionary, nil)
							}
						} else {
                            //NSDictionary optional à nil
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
			assiduity: data["assiduity"]as! Int,
            failed: data["failed"] as! Int,
			success: data["success"] as! Int,
            touchId: false,
            sounds: true
			)
        
        User.authenticated = true
	}
	
	static func instantiateUserStored() -> Bool {
		var data : [String] = []
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
                assiduity: (data[5] as String).toInt()!,
                failed: (data[6] as String).toInt()!,
                success: (data[7] as String).toInt()!,
                touchId: (data[8] as String).toBool()!,
                sounds: (data[9] as String).toBool()!)
            
			return true
		} else {
			return false
		}
	}
	
	
}





