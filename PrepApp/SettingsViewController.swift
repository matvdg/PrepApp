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
            User.currentUser!.touchId = true
            User.currentUser!.saveUser()
            // create alert controller
            let myAlert = UIAlertController(title: "Touch ID activé", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            // add an "OK" button
            myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            // show the alert
            self.presentViewController(myAlert, animated: true, completion: nil)

        } else {
            User.currentUser!.touchId = false
            User.currentUser!.saveUser()
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
            User.currentUser!.sounds = true
            User.currentUser!.saveUser()
            Sound.playTrack("true")
        } else {
            Sound.playTrack("false")
            User.currentUser!.sounds = false
            User.currentUser!.saveUser()
            
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
			changeCheckedPassword()
		}
		return false
		// We do not want UITextField to insert line-breaks.
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		designButton.layer.cornerRadius = 6
		if self.revealViewController() != nil {
			menuButton.target = self.revealViewController()
			menuButton.action = "revealToggle:"
			self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
		}
        self.soundSwitch.setOn(User.currentUser!.sounds, animated: true)
        
        var authenticationObject = LAContext()
        var authenticationError: NSError?
        
        authenticationObject.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: &authenticationError)
        
        if authenticationError != nil {
            println("TouchID not available in this device")
            self.touchIDlabel.hidden = true
            self.touchIDswitch.hidden = true
            
        } else {
            println("TouchID available")
            self.touchIDlabel.hidden = false
            self.touchIDswitch.hidden = false
            self.touchIDswitch.setOn(User.currentUser!.touchId, animated: true)
            
        }

	}
    
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController!.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Segoe UI", size: 20)!]
        println("viewAppear")
        if User.authenticated == false {
            NSUserDefaults.standardUserDefaults().removeObjectForKey("user")
            NSUserDefaults.standardUserDefaults().synchronize()
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
	
	override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
		self.view.endEditing(true)
	}

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
