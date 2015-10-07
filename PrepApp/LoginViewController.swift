//
//  LoginViewController.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 06/05/15.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import UIKit
import LocalAuthentication

class LoginViewController: UIViewController, UITextFieldDelegate {
	

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view!.backgroundColor = colorGreyBackground
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "login", name: "success", object: nil)
        if (User.instantiateUserStored()){
            self.mail.text = User.currentUser!.email
            self.pass.text = "hidden"
        }
		self.designButton.layer.cornerRadius = 6
    }

	override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
		self.view.endEditing(true)
	}
	
	override func viewDidAppear(animated: Bool) {
		//if user already logged in persistent data, load it
        println(FactorySync.path)
        if (User.instantiateUserStored()){
            if (UserPreferences.touchId) {
                UserPreferences.touchID()
            } else {
                User.authenticated = true
            }
        }
        if User.authenticated {
            self.performSegueWithIdentifier("loginDidSucceded", sender: self)
        } else {
            if FactorySync.debugMode {
                self.mail.text = "marc.herrero@icloud.com"
                self.pass.text = "Malaisie41"
            } else {
                self.mail.text = ""
                self.pass.text = ""
            }
        }
        let value = UIInterfaceOrientation.Portrait.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")
	}
	
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		var nextTag: NSInteger = textField.tag + 1
		// Try to find next responder
		var nextResponder: UIResponder? = textField.superview?.viewWithTag(nextTag)
		
	  if ((nextResponder) != nil) {
		// Found next responder, so set it.
		nextResponder!.becomeFirstResponder()
	  } else {
		// Not found, so remove keyboard.
        textField.resignFirstResponder()
		self.connect()
	  }
	  return false
		// We do not want UITextField to insert line-breaks.
	}
	
	func connect() {
		//online mode
		User.login(mail.text, pass: pass.text){
			(data, error) -> Void in
			
			if data == nil {
				// create alert controller
				let myAlert = UIAlertController(title: error, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                myAlert.view.tintColor = colorGreen
				// add an "OK" button
				myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
				// show the alert
				self.presentViewController(myAlert, animated: true, completion: nil)
			} else {
				User.instantiateUser(data!, pass: self.pass.text)
				//we store the current user infoss to avoid further login until he logs out
				User.currentUser!.saveUser()
                FactoryHistory.getHistory().retrieveHistory({ (result) -> Void in
                    if result {
                        self.performSegueWithIdentifier("loginDidSucceded", sender: self)
                    } else {
                        // create alert controller
                        let myAlert = UIAlertController(title: "Erreur !", message: "Échec de la connexion. Veuillez vérifier que vous êtes connecté à internet avec une bonne couverture cellulaire ou WiFi, puis réessayez.", preferredStyle: UIAlertControllerStyle.Alert)
                        myAlert.view.tintColor = colorGreen
                        // add an "OK" button
                        myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                        // show the alert
                        self.presentViewController(myAlert, animated: true, completion: nil)

                    }
                })
				
			}
		}

	}
    
	@IBOutlet weak var designButton: UIButton!
	@IBOutlet weak var mail: UITextField!
	@IBOutlet weak var pass: UITextField!
	@IBAction func login(sender: AnyObject) {
		self.connect()
	}
	

}
