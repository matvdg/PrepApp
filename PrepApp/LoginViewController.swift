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

    //app methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideDebugButton(true)
        self.view!.backgroundColor = Colors.greyBackground
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "login", name: "success", object: nil)
        if (User.instantiateUserStored()){
            self.mail.text = User.currentUser!.email
            self.pass.text = "hidden"
        }
		self.designButton.layer.cornerRadius = 6
    }
	
	override func viewDidAppear(animated: Bool) {
        print(FactorySync.path)
        
        UserPreferences.loadUserPreferences()
        
		//if user already logged in persistent data, load it
        
        if User.instantiateUserStored() {
            if UserPreferences.touchId {
                UserPreferences.touchID()
            } else {
                User.authenticated = true
            }
        }
        if User.authenticated {
            self.performSegueWithIdentifier("loginDidSucceded", sender: self)
        } else {
            
            if FactorySync.debugMode {
                self.hideDebugButton(false)
                self.mail.text = "matvdg@icloud.com"
                self.pass.text = "test"
            } else {
                self.mail.text = ""
                self.pass.text = ""
            }
        }
        let value = UIInterfaceOrientation.Portrait.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")
	}
    
    //methods
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		let nextTag: NSInteger = textField.tag + 1
		// Try to find next responder
		let nextResponder: UIResponder? = textField.superview?.viewWithTag(nextTag)
		
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
        //CGU consent
        if !UserPreferences.cguConsent {
            SwiftSpinner.hide()
            self.consentCgu()
        } else {
            //online mode
            User.login(mail.text!, pass: pass.text!){
                (data, error) -> Void in
                SwiftSpinner.hide()
                if data == nil {
                    // create alert controller
                    let myAlert = UIAlertController(title: error, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                    myAlert.view.tintColor = Colors.green
                    // add "OK" button
                    myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    // show the alert
                    self.presentViewController(myAlert, animated: true, completion: nil)
                } else {
                    User.instantiateUser(data!, pass: self.pass.text!)
                    //we store the current user infos to avoid further login until he logs out
                    User.currentUser!.saveUser()
                    FactoryRealm.clearUserDB()
                    FactoryHistory.getHistory().retrieveHistory({ (result) -> Void in
                        if result {
                            self.performSegueWithIdentifier("loginDidSucceded", sender: self)
                        } else {
                            // create alert controller
                            let myAlert = UIAlertController(title: "Erreur !", message: "Échec de la connexion. Veuillez vérifier que vous êtes connecté à internet avec une bonne couverture cellulaire ou WiFi, puis réessayez.", preferredStyle: UIAlertControllerStyle.Alert)
                            myAlert.view.tintColor = Colors.green
                            // add "OK" button
                            myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                            // show the alert
                            self.presentViewController(myAlert, animated: true, completion: nil)
                        }
                    })
                }
            }
        }
    }
    
    func consentCgu() {
            // create alert controller
            let myAlert = UIAlertController(title: "CGU", message: HelpViewController.getCGU(), preferredStyle: UIAlertControllerStyle.Alert)
            myAlert.view.tintColor = Colors.green
            // add "agree/disagree" button
            myAlert.addAction(UIAlertAction(title: "J'accepte les CGU", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                UserPreferences.cguConsent = true
                UserPreferences.saveUserPreferences()
                SwiftSpinner.show("")
                self.connect()
            }))
            myAlert.addAction(UIAlertAction(title: "Je refuse les CGU", style: UIAlertActionStyle.Destructive, handler: { (action) -> Void in
                // create alert controller
                let myAlert = UIAlertController(title: "CGU", message: "Pour utiliser Prep'App, vous devez accepter les conditions générales d'utilisation", preferredStyle: UIAlertControllerStyle.Alert)
                myAlert.view.tintColor = Colors.green
                // add "OK" button
                myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                // show the alert
                self.presentViewController(myAlert, animated: true, completion: nil)
                
            }))
            // show the alert
            self.presentViewController(myAlert, animated: true, completion: nil)
    }
    
    
    //@IBOutlets
	@IBOutlet weak var designButton: UIButton!
	@IBOutlet weak var mail: UITextField!
	@IBOutlet weak var pass: UITextField!
    
    
    //@IBActions
	@IBAction func login(sender: AnyObject) {
        self.resignFirstResponder()
        self.view.endEditing(true)
        SwiftSpinner.setTitleFont(UIFont(name: "Segoe UI", size: 22.0))
        SwiftSpinner.show("")
        self.connect()
	}
    
	//debugMode
    
    @IBAction func pressDebug(sender: AnyObject) {
        
        switch sender.tag {
        case 3 :
            self.mail.text = "laurie.guillet@icloud.com"
            print("laurie.guillet@icloud.com")
        case 4:
            self.mail.text = "jean.dupont@icloud.com"
            print("jean.dupont@icloud.com")
        case 5:
            self.mail.text = "paul.bismut@icloud.com"
            print("paul.bismut@icloud.com")
        case 6:
            self.mail.text = "marc.herrero@icloud.com"
            print("marc.herrero@icloud.com")
        case 7:
            self.mail.text = "perennou.julien@gmail.com"
            print("perennou.julien@gmail.com")
        case 8:
            self.mail.text = "john.appleseed@icloud.com"
            print("john.appleseed@icloud.com")
        default:
            self.mail.text = "matvdg@icloud.com"
            print("matvdg@icloud.com")
        }

    }
    
    func hideDebugButton(hide: Bool) {
        for i in 3...8 {
            let button = view.viewWithTag(i) as! UIButton
            button.layer.cornerRadius = 6
            button.hidden = hide
        }
    }
    

}
