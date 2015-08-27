//
//  SettingsViewController.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 14/05/15.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import UIKit
import LocalAuthentication

class SettingsViewController: UIViewController, UITextFieldDelegate {

	@IBOutlet weak var designButton: UIButton!
    @IBOutlet weak var touchIDlabel: UILabel!
    @IBOutlet weak var soundSwitch: UISwitch!
    @IBOutlet weak var touchIDswitch: UISwitch!
	@IBOutlet var menuButton: UIBarButtonItem!
	@IBOutlet weak var newPwd: UITextField!
	@IBOutlet weak var newPwdBis: UITextField!
    
	@IBAction func changePwd(sender: AnyObject) {
		changeCheckedPassword()
	}
	
    @IBAction func touchIDaction(sender: AnyObject) {
        if self.touchIDswitch.on {
            UserPreferences.touchId = true
            UserPreferences.saveUserPreferences()
            // create alert controller
            let myAlert = UIAlertController(title: "Touch ID activé", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            // add an "OK" button
            myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            // show the alert
            self.presentViewController(myAlert, animated: true, completion: nil)

        } else {
            UserPreferences.touchId = false
            UserPreferences.saveUserPreferences()
            // create alert controller
            let myAlert = UIAlertController(title: "Touch ID désactivé", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            // add an "OK" button
            myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            // show the alert
            self.presentViewController(myAlert, animated: true, completion: nil)

        }
    }
    
    @IBAction func soundAction(sender: AnyObject) {
        if self.soundSwitch.on {
            UserPreferences.sounds = true
            UserPreferences.saveUserPreferences()
            Sound.playTrack("true")
        } else {
            UserPreferences.sounds = false
            UserPreferences.saveUserPreferences()
        }
    }
    
	func changeCheckedPassword(){
		self.view.endEditing(true)
		if (newPwd.text.hasGoodLength() && newPwd.text.hasTwoNumber() && newPwd.text.hasUppercase()){
			if newPwd.text == newPwdBis.text {
				User.currentUser?.changePassword(newPwd.text.sha1(), callback: { (message) -> Void in
					// create alert controller
					let myAlert = UIAlertController(title: message!, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
					// add an "OK" button
					myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
					// show the alert
					self.presentViewController(myAlert, animated: true, completion: nil)
				})
				
			} else {
				// create alert controller
				let myAlert = UIAlertController(title: "Oups !", message: "Le nouveau mot de passe et la confirmation ne correspondent pas.", preferredStyle: UIAlertControllerStyle.Alert)
				// add an "OK" button
				myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
				// show the alert
				self.presentViewController(myAlert, animated: true, completion: nil)
			}
		} else {
			// create alert controller
			let myAlert = UIAlertController(title: "Le mot de passe est trop faible !", message: "Minimum 8 caractères dont 1 majuscule et 2 chiffres.", preferredStyle: UIAlertControllerStyle.Alert)
			// add an "OK" button
			myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
			// show the alert
			self.presentViewController(myAlert, animated: true, completion: nil)
		}
		newPwd.text = ""
		newPwdBis.text = ""
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
            self.resignFirstResponder()
			self.changeCheckedPassword()
		}
		return false
		// We do not want UITextField to insert line-breaks.
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()
        UserPreferences.loadUserPreferences()
        self.navigationController!.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Segoe UI", size: 20)!]
        self.navigationController!.navigationBar.tintColor = colorGreenAppButtons
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "logout", name: "failed", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "update", name: "update", object: nil)
		designButton.layer.cornerRadius = 6
		if self.revealViewController() != nil {
			menuButton.target = self.revealViewController()
			menuButton.action = "revealToggle:"
			self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
		}
        self.soundSwitch.setOn(UserPreferences.sounds, animated: true)
        
        var authenticationObject = LAContext()
        var authenticationError: NSError?
        
        authenticationObject.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: &authenticationError)
        
        if authenticationError != nil {
            //println("TouchID not available in this device")
            self.touchIDlabel.hidden = true
            self.touchIDswitch.hidden = true
            
        } else {
            //println("TouchID available")
            self.touchIDlabel.hidden = false
            self.touchIDswitch.hidden = false
            self.touchIDswitch.setOn(UserPreferences.touchId, animated: true)
            
        }

	}
	
	override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
		self.view.endEditing(true)
	}
    
    func logout() {
        println("logging out")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func update() {
        // create alert controller
        let myAlert = UIAlertController(title: "Une mise à jour des questions est disponible", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        // add an "later" button
        myAlert.addAction(UIAlertAction(title: "Plus tard", style: UIAlertActionStyle.Default, handler: nil))
        // add an "update" button
        myAlert.addAction(UIAlertAction(title: "Mettre à jour maintenant", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        // show the alert
        self.presentViewController(myAlert, animated: true, completion: nil)
    }

}
