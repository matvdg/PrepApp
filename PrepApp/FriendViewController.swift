//
//  FriendViewController.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 14/05/15.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import UIKit

class FriendViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var friends = [Friend]()
    var pendingChallenge = [Challenge]()
    let realm = FactoryRealm.getRealmFriends()
    var selectedFriend = Friend()
    var selectedPendingChallenge = Challenge()

	@IBOutlet var menuButton: UIBarButtonItem!
    @IBOutlet weak var designShuffle: UIButton!
    @IBOutlet weak var designAdd: UIButton!
    @IBOutlet weak var designShare: UIButton!
    @IBOutlet weak var friendsTable: UITableView!
    
    @IBAction func shareCode(sender: AnyObject) {
        // create alert controller
        let myAlert = UIAlertController(title: "\(String(User.currentUser!.id).sha1())", message: "Partagez votre code à vos amis en leur envoyant un message !", preferredStyle: UIAlertControllerStyle.Alert)
        myAlert.view.tintColor = colorGreenAppButtons
                // add an buttons
        myAlert.addAction(UIAlertAction(title: "Annuler", style: UIAlertActionStyle.Default, handler: nil))
        myAlert.addAction(UIAlertAction(title: "Partager", style: .Default, handler: { (action) -> Void in
            self.share()
        }))
        
        // show the alert
        self.presentViewController(myAlert, animated: true, completion: nil)
    }
    
    var textField =  UITextField()
    
    func addTextField(textField: UITextField!){
        // add the text field and make the result global
        textField.placeholder = "Collez le code ici"
        self.textField = textField
    }
    
    func codeEntered(alert: UIAlertAction!){
        self.add(self.textField.text)
    }
    
    @IBAction func addFriend(sender: AnyObject) {
        // create alert controller
        let myAlert = UIAlertController(title: "Ajouter un ami", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        myAlert.view.tintColor = colorGreenAppButtons
        // add buttons
        myAlert.addAction(UIAlertAction(title: "Annuler", style: UIAlertActionStyle.Default, handler: nil))
        myAlert.addAction(UIAlertAction(title: "Ajouter", style: .Default, handler: self.codeEntered))
        // show the alert
        self.presentViewController(myAlert, animated: true, completion: nil)
        //add prompt
        myAlert.addTextFieldWithConfigurationHandler(self.addTextField)
    }
	
	override func viewDidLoad() {
		super.viewDidLoad()
        self.loadData()
        self.friendsTable.backgroundColor = colorGreyBackground
        self.designShare.layer.cornerRadius = 6
        self.designAdd.layer.cornerRadius = 6
        self.designShuffle.layer.cornerRadius = 6
        self.navigationController!.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Segoe UI", size: 20)!]
        self.navigationController!.navigationBar.tintColor = colorGreenAppButtons
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "logout", name: "failed", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "update", name: "update", object: nil)
		if self.revealViewController() != nil {
			menuButton.target = self.revealViewController()
			menuButton.action = "revealToggle:"
			self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
		}
	}
    
    private func loadData() {
        self.friends = FactoryDuo.getFriendManager().getFriends()
        if self.friends.isEmpty {
            var templateFriend = Friend()
            templateFriend.id = -1
            templateFriend.firstName = "Pas d'amis pour le moment"
            templateFriend.nickname = "Pas d'amis pour le moment"
            self.friends.append(templateFriend)
            
        }
        if self.pendingChallenge.isEmpty {
            var templateDuo = Challenge()
            templateDuo.id = -1
            templateDuo.firstName = "Pas de défi en attente pour le moment"
            templateDuo.nickname = "Pas de défi en attente pour le moment"
            self.pendingChallenge.append(templateDuo)
        }
        
    }
    
    private func add(code: String) {
        FactoryDuo.getFriendManager().saveFriend(code, callback: { (result, message) -> Void in
            if result {
                println(self.friends)
                if self.friends[0].id == -1 {
                    println("removing template")
                    self.friends.removeAtIndex(0)
                    self.friendsTable.deleteRowsAtIndexPaths([NSIndexPath(forItem: 0, inSection: 1)], withRowAnimation: UITableViewRowAnimation.Fade)
                }
                var counter = self.friends.count
                self.friends = FactoryDuo.getFriendManager().getFriends()
                if counter == self.friends.count {
                    
                    // create alert controller
                    let myAlert = UIAlertController(title: "Oups !", message: "L'ami a déjà été ajouté... Entrez un autre code.", preferredStyle: UIAlertControllerStyle.Alert)
                    myAlert.view.tintColor = colorGreenAppButtons
                    // add OK button
                    myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    // show the alert
                    self.presentViewController(myAlert, animated: true, completion: nil)
                } else {
                    println("ajout d'amis")
                    // create alert controller
                    let myAlert = UIAlertController(title: "Ami ajouté !", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                    myAlert.view.tintColor = colorGreenAppButtons
                    // add OK button
                    myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    // show the alert
                    let newIndexPath = NSIndexPath(forItem: 0, inSection: 1)
                    self.friendsTable.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Left)
                }
                
                
            } else {
                // create alert controller
                let myAlert = UIAlertController(title: "Erreur", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                myAlert.view.tintColor = colorGreenAppButtons
                // add OK button
                myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                // show the alert
                self.presentViewController(myAlert, animated: true, completion: nil)
            }
        })
        
    }
    
    private func share() {
        let idToShare = String(User.currentUser!.id).sha1()
        let welcome = "Bonjour, je souhaite faire un duel avec toi sur Prep'App !"
        let text = "Mon code Prep'App à rentrer dans défi duo :"
        let link = "www.prep-app.com"
        let objectsToShare: [AnyObject] = [welcome, text, idToShare, link]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityVC.excludedActivityTypes = [UIActivityTypePostToTwitter]
        activityVC.setValue("Prep'App", forKey: "subject")
        self.presentViewController(activityVC, animated: true, completion: nil)

    }
    
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
    
    // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.pendingChallenge.count
        } else {
            return self.friends.count
        }
        
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Défis en attente"
        } else {
            return "Amis"
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("pendingChallenge", forIndexPath: indexPath) as! UITableViewCell
            let pendingChallenge = self.pendingChallenge[indexPath.row]
            
            var text = ""
            if pendingChallenge.id != -1 {
                text = "Défi de "
            }
            
            if FactorySync.getConfigManager().loadNicknamePreference() {
                text += pendingChallenge.nickname
            } else {
                text += "\(pendingChallenge.firstName) \(pendingChallenge.lastName)"
            }
            cell.textLabel!.text = text
            cell.textLabel?.textColor = UIColor.blackColor()
            cell.backgroundColor = colorGreyBackground
            cell.textLabel!.adjustsFontSizeToFitWidth = false
            cell.textLabel!.adjustsFontSizeToFitWidth = true
            var formatter = NSDateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            var dateInString = formatter.stringFromDate(pendingChallenge.date)
            if pendingChallenge.id == -1 {
                cell.accessoryType = UITableViewCellAccessoryType.None
                cell.detailTextLabel!.text = ""
            } else {
                cell.detailTextLabel!.text = dateInString
            }
            cell.textLabel!.font = UIFont(name: "Segoe UI", size: 16)
            cell.tintColor = colorGreenAppButtons
            return cell

        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("friend", forIndexPath: indexPath) as! UITableViewCell
            let friend = self.friends[indexPath.row]
            if friend.id == -1 {
                cell.accessoryType = UITableViewCellAccessoryType.None
            }
            if FactorySync.getConfigManager().loadNicknamePreference() {
                cell.textLabel!.text = friend.nickname
            } else {
                cell.textLabel!.text = "\(friend.firstName) \(friend.lastName)"
            }
            cell.textLabel?.textColor = UIColor.blackColor()
            cell.backgroundColor = colorGreyBackground
            cell.textLabel!.adjustsFontSizeToFitWidth = false
            cell.textLabel!.adjustsFontSizeToFitWidth = true
            cell.textLabel!.font = UIFont(name: "Segoe UI", size: 16)
            cell.tintColor = colorGreenAppButtons
            return cell

        }
    }
    
    // Override to support editing the table view.
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            Sound.playTrack("calc")
            if indexPath.section == 0 {
                var duoToRemove = self.pendingChallenge[indexPath.row]
                self.pendingChallenge.removeAtIndex(indexPath.row)
            } else {
                var friendToRemove = self.friends[indexPath.row]
                self.friends.removeAtIndex(indexPath.row)
                if friendToRemove.id != -1 {
                    FactoryDuo.getFriendManager().deleteFriend(friendToRemove)
                }
            }
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        }
    }
    
    
    //UITableViewDelegate Methods
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            let pendingChallenge = self.pendingChallenge[indexPath.row]
            self.selectedPendingChallenge = self.pendingChallenge[indexPath.row]
            if pendingChallenge.id != -1 {
                //self.performSegueWithIdentifier("showDuo", sender: self)
            }
        } else {
            let friend = self.friends[indexPath.row]
            self.selectedFriend = self.friends[indexPath.row]
            if friend.id != -1 {
                //self.performSegueWithIdentifier("showDuo", sender: self)
            }
            
        }
        
    }
    


}
