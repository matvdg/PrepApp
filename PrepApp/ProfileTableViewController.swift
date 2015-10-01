//
//  ProfileTableViewController.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 30/09/15.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import UIKit
import LocalAuthentication

class ProfileTableViewController: UITableViewController {
    
    var settings = ["Modifier votre pseudo", "Modifier votre mot de passe", "Bruitages", "Touch ID"]
    
    var nickname = UITextField()
    var password = UITextField()
    var confirmationPassword = UITextField()
    
    @IBOutlet weak var menuButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadSettings()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "update", name: "update", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "logout", name: "failed", object: nil)
        
        if self.revealViewController() != nil {
            self.menuButton.target = self.revealViewController()
            self.menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        self.navigationController!.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Segoe UI", size: 20)!]
        self.navigationController!.navigationBar.tintColor = colorGreenAppButtons
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.settings.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("setting", forIndexPath: indexPath) as! UITableViewCellSetting
        cell.textLabel?.textColor = UIColor.blackColor()
        cell.textLabel!.text = self.settings[indexPath.row]
        cell.backgroundColor = UIColor.clearColor()
        cell.textLabel!.adjustsFontSizeToFitWidth = false
        cell.textLabel!.font = UIFont(name: "Segoe UI", size: 16)
        cell.tintColor = colorGreenAppButtons
        cell.switcher.layer.zPosition = 10
        cell.switcher.tintColor = colorGreenAppButtons
        
        switch self.settings[indexPath.row] {
            case "Modifier votre pseudo":
                cell.switcher.hidden = true
                cell.tintColor = colorGreenAppButtons
                cell.accessoryView = UIImageView(image: UIImage(named: "nickname"))
            case "Modifier votre mot de passe":
                cell.switcher.hidden = true
                cell.tintColor = colorGreenAppButtons
                cell.accessoryView = UIImageView(image: UIImage(named: "key"))
            case "Touch ID":
                cell.switcher.setOn(UserPreferences.touchId, animated: true)
                cell.accessoryType = UITableViewCellAccessoryType.None
                cell.switcher.addTarget(self, action: "touchIDSwitch", forControlEvents: UIControlEvents.TouchUpInside)
            case "Bruitages":
                cell.switcher.setOn(UserPreferences.sounds, animated: true)
                cell.accessoryType = UITableViewCellAccessoryType.None
                cell.switcher.addTarget(self, action: "soundSwitch", forControlEvents: UIControlEvents.TouchUpInside)

            default:
                println("error")
        }
        return cell
    }
    
    //UITableViewDelegate Methods
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if self.settings[indexPath.row] == "Modifier votre pseudo" {
            self.changeNickname()
        } else if self.settings[indexPath.row] == "Modifier votre mot de passe" {
            self.changePassword()
        }
    }

    
    //Methods
    func logout() {
        println("logging out")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func update() {
        // create alert controller
        let myAlert = UIAlertController(title: "Une mise à jour des questions est disponible", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        myAlert.view.tintColor = colorGreenAppButtons
        // add an "later" button
        myAlert.addAction(UIAlertAction(title: "Plus tard", style: UIAlertActionStyle.Default, handler: nil))
        // add an "update" button
        myAlert.addAction(UIAlertAction(title: "Mettre à jour maintenant", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        // show the alert
        self.presentViewController(myAlert, animated: true, completion: nil)
    }
    
    private func loadSettings() {
        //loading settings preferences
        UserPreferences.loadUserPreferences()
        
        //Touch ID
        var authenticationObject = LAContext()
        var authenticationError: NSError?
        authenticationObject.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: &authenticationError)
        if authenticationError != nil {
            //println("TouchID not available in this device")
            self.settings.removeAtIndex(find(self.settings,"Touch ID")!)
        }
        
        //Nickname
        if !FactorySync.getConfigManager().loadNicknamePreference() {
            self.settings.removeAtIndex(find(self.settings,"Modifier votre pseudo")!)
        }
    }
    
    //Nickname Methods
    func addNickname(textField: UITextField!){
        // add the text field and make the result global
        textField.placeholder = User.currentUser!.nickname
        self.nickname = textField
    }
    
    func changeNickname() {
        // create alert controller
        let myAlert = UIAlertController(title: "Modifier votre pseudo", message: "Taper votre nouveau pseudonyme ou votre prénom/nom, si vous le souhaitez.", preferredStyle: UIAlertControllerStyle.Alert)
        myAlert.view.tintColor = colorGreenAppButtons
        // add buttons
        myAlert.addAction(UIAlertAction(title: "Annuler", style: UIAlertActionStyle.Default, handler: nil))
        myAlert.addAction(UIAlertAction(title: "Modifier", style: UIAlertActionStyle.Default, handler: self.sendNickname))
        // show the alert
        self.presentViewController(myAlert, animated: true, completion: nil)
        //add prompt
        myAlert.addTextFieldWithConfigurationHandler(self.addNickname)
    }
    
    func sendNickname(alert: UIAlertAction!) {
        if self.nickname.text != "" {
            User.currentUser!.changeNickname(self.nickname.text, callback: { (message) -> Void in
                // create alert controller
                let myAlert = UIAlertController(title: message!, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                myAlert.view.tintColor = colorGreenAppButtons
                // add an "OK" button
                myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                // show the alert
                self.presentViewController(myAlert, animated: true, completion: nil)
            })
            
        } else {
            // create alert controller
            let myAlert = UIAlertController(title: "Oups !", message: "Le pseudo ne peut être vide.", preferredStyle: UIAlertControllerStyle.Alert)
            myAlert.view.tintColor = colorGreenAppButtons
            // add an "OK" button
            myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            // show the alert
            self.presentViewController(myAlert, animated: true, completion: nil)
        }
        
    
    }
    
    //Password Methods
    func addPassword(textField: UITextField!){
        // add the text field and make the result global
        textField.placeholder = "Nouveau mot de passe"
        self.password = textField
    }
    
    func addConfirmationPassword(textField: UITextField!){
        // add the text field and make the result global
        textField.placeholder = "Confirmation"
        self.confirmationPassword = textField
    }
    
    func changePassword() {
        // create alert controller
        let myAlert = UIAlertController(title: "Modifier votre mot de passe", message: "Minimum huit caractères dont une majuscule et deux chiffres.", preferredStyle: UIAlertControllerStyle.Alert)
        myAlert.view.tintColor = colorGreenAppButtons
        // add buttons
        myAlert.addAction(UIAlertAction(title: "Annuler", style: UIAlertActionStyle.Default, handler: nil))
        myAlert.addAction(UIAlertAction(title: "Modifier", style: .Default, handler: self.sendPassword))
        // show the alert
        self.presentViewController(myAlert, animated: true, completion: nil)
        //add prompts
        myAlert.addTextFieldWithConfigurationHandler(self.addPassword)
        myAlert.addTextFieldWithConfigurationHandler(self.addConfirmationPassword)
    }
    
    private func sendPassword(alert: UIAlertAction!) {
        if (self.password.text.hasGoodLength() && self.password.text.hasTwoNumber() && self.password.text.hasUppercase()){
            if self.password.text == self.confirmationPassword.text {
                User.currentUser?.changePassword(self.password.text.sha1(), callback: { (message) -> Void in
                    // create alert controller
                    let myAlert = UIAlertController(title: message!, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                    myAlert.view.tintColor = colorGreenAppButtons
                    // add an "OK" button
                    myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    // show the alert
                    self.presentViewController(myAlert, animated: true, completion: nil)
                })
                
            } else {
                // create alert controller
                let myAlert = UIAlertController(title: "Oups !", message: "Le nouveau mot de passe et la confirmation ne correspondent pas.", preferredStyle: UIAlertControllerStyle.Alert)
                myAlert.view.tintColor = colorGreenAppButtons
                // add an "OK" button
                myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                // show the alert
                self.presentViewController(myAlert, animated: true, completion: nil)
            }
        } else {
            // create alert controller
            let myAlert = UIAlertController(title: "Le mot de passe est trop faible !", message: "Minimum 8 caractères dont 1 majuscule et 2 chiffres.", preferredStyle: UIAlertControllerStyle.Alert)
            myAlert.view.tintColor = colorGreenAppButtons
            // add an "OK" button
            myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            // show the alert
            self.presentViewController(myAlert, animated: true, completion: nil)
        }
    }
    
    //Touch ID Methods
    func touchIDSwitch() {
        let cell = self.tableView!.cellForRowAtIndexPath(NSIndexPath(forRow: find(self.settings,"Touch ID")!, inSection: 0)) as! UITableViewCellSetting
        if cell.switcher!.on {
            UserPreferences.touchId = true
            UserPreferences.saveUserPreferences()
            // create alert controller
            let myAlert = UIAlertController(title: "Touch ID activé", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            myAlert.view.tintColor = colorGreenAppButtons
            // add an "OK" button
            myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            // show the alert
            self.presentViewController(myAlert, animated: true, completion: nil)
            
        } else {
            UserPreferences.touchId = false
            UserPreferences.saveUserPreferences()
            // create alert controller
            let myAlert = UIAlertController(title: "Touch ID désactivé", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            myAlert.view.tintColor = colorGreenAppButtons
            // add an "OK" button
            myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            // show the alert
            self.presentViewController(myAlert, animated: true, completion: nil)
            
        }
    }
    
    //Sounds Methods
    func soundSwitch() {
        let cell = self.tableView!.cellForRowAtIndexPath(NSIndexPath(forRow: find(self.settings,"Bruitages")!, inSection: 0)) as! UITableViewCellSetting
        if cell.switcher!.on {
            UserPreferences.sounds = true
            UserPreferences.saveUserPreferences()
            Sound.playTrack("calc")
        } else {
            UserPreferences.sounds = false
            UserPreferences.saveUserPreferences()
        }
    }

    

}
