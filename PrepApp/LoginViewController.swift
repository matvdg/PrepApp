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
		designButton.layer.cornerRadius = 6
    }
	
	override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
		self.view.endEditing(true)
	}
	
	override func viewDidAppear(animated: Bool) {
		//offline mode = if user already logged in persistent data, load it
		if (User.instantiateUserStored()){
            if User.currentUser!.touchId {
                var authenticationObject = LAContext()
                var authenticationError: NSError?
                
                authenticationObject.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: &authenticationError)
                
                if authenticationError != nil {
                    println("TouchID not available in this device")
                    self.mail.text = ""
                    self.pass.text = ""
                } else {
                    println("TouchID available")
                    authenticationObject.evaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, localizedReason: "Posez votre doigt pour vous authentifier avec Touch ID", reply: { (complete:Bool, error: NSError!) -> Void in
                        if error != nil {
                            // There's an error. User likely pressed cancel.
                            println(error.localizedDescription)
                            self.mail.text = ""
                            self.pass.text = ""
                        } else {
                            // There's no error, the authentication completed successfully
                            if complete {
                                println("authentication successful")
                                self.mail.text = User.currentUser!.email
                                self.pass.text = "hidden"
                                self.performSegueWithIdentifier("loginDidSucceded", sender: self)
                            } else {
                               println("authentication failed")
                                // create alert controller
                                let myAlert = UIAlertController(title: " Erreur Touch ID", message:"L'authentification Touch ID a échoué" , preferredStyle: UIAlertControllerStyle.Alert)
                                // add an "OK" button
                                myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                                // show the alert
                                self.presentViewController(myAlert, animated: true, completion: nil)
                                self.mail.text = ""
                                self.pass.text = ""
                            }
                        }
                    })
                }

            } else {
                self.mail.text = User.currentUser!.email
                self.pass.text = "hidden"
                //self.performSegueWithIdentifier("loginDidSucceded", sender: self)
                //without sync // test mode
                self.performSegueWithIdentifier("testMode", sender: self)
                println(Factory.path)
            }
		}
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
		connect()
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
				// add an "OK" button
				myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
				// show the alert
				self.presentViewController(myAlert, animated: true, completion: nil)
			} else {
				User.instantiateUser(data!, pass: self.pass.text)
				//we store the current user infoss to avoid further login until he logs out
				User.currentUser!.saveUser()
				self.performSegueWithIdentifier("loginDidSucceded", sender: self)
			}
		}

	}
    
	@IBOutlet weak var designButton: UIButton!
	@IBOutlet weak var mail: UITextField!
	@IBOutlet weak var pass: UITextField!
	@IBAction func login(sender: AnyObject) {
		self.connect()
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

	

}
