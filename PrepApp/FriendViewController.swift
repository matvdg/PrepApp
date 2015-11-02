//
//  FriendViewController.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 14/05/15.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import UIKit

class FriendViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //properties
    var friends = [Friend]()
    var pendingDuos = [PendingDuo]()
    let realm = FactoryRealm.getRealmFriends()
    var textField =  UITextField()

    //@IBOutlet
	@IBOutlet var menuButton: UIBarButtonItem!
    @IBOutlet weak var designShuffle: UIButton!
    @IBOutlet weak var designAdd: UIButton!
    @IBOutlet weak var designShare: UIButton!
    @IBOutlet weak var friendsTable: UITableView!
    
    //@IBAction
    @IBAction func shareCode(sender: AnyObject) {
        // create alert controller
        let myAlert = UIAlertController(title: "\(String(User.currentUser!.id).sha1())", message: "Partagez votre code à vos amis en leur envoyant un message !", preferredStyle: UIAlertControllerStyle.Alert)
        myAlert.view.tintColor = colorGreen
                // add an buttons
        myAlert.addAction(UIAlertAction(title: "Annuler", style: UIAlertActionStyle.Default, handler: nil))
        myAlert.addAction(UIAlertAction(title: "Partager", style: .Default, handler: { (action) -> Void in
            self.share()
        }))
        
        // show the alert
        self.presentViewController(myAlert, animated: true, completion: nil)
    }
    
    @IBAction func addFriend(sender: AnyObject) {
        // create alert controller
        let myAlert = UIAlertController(title: "Ajouter un ami", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        myAlert.view.tintColor = colorGreen
        // add buttons
        myAlert.addAction(UIAlertAction(title: "Annuler", style: UIAlertActionStyle.Default, handler: nil))
        myAlert.addAction(UIAlertAction(title: "Ajouter", style: .Default, handler: self.codeEntered))
        // show the alert
        self.presentViewController(myAlert, animated: true, completion: nil)
        //add prompt
        myAlert.addTextFieldWithConfigurationHandler(self.addTextField)
    }
    
    @IBAction func shuffleFriend(sender: AnyObject) {
        FactoryDuo.getFriendManager().shuffleDuo { (friend, error) -> Void in
            if let shuffledFriend = friend {
                var textTodisplay = " "
                if FactorySync.getConfigManager().loadNicknamePreference() {
                    textTodisplay += "\(shuffledFriend.nickname)"
                } else {
                    textTodisplay += "\(shuffledFriend.firstName) \(shuffledFriend.lastName)"
                }
                // create alert controller
                let myAlert = UIAlertController(title: "Lancer le défi ?", message: "Vous êtes sur le point de lancer un défi à \(textTodisplay), le défi va commencer tout de suite, vous aurez besoin de 20 minutes. ", preferredStyle: UIAlertControllerStyle.Alert)
                myAlert.view.tintColor = colorGreen
                // add an buttons
                myAlert.addAction(UIAlertAction(title: "Annuler", style: UIAlertActionStyle.Default, handler: nil))
                myAlert.addAction(UIAlertAction(title: "GO !", style: .Default, handler: { (action) -> Void in
                    self.challenge(shuffledFriend.id)
                }))
                // show the alert
                self.presentViewController(myAlert, animated: true, completion: nil)

            } else {
                // create alert controller
                let myAlert = UIAlertController(title: "Oups !", message: error, preferredStyle: UIAlertControllerStyle.Alert)
                myAlert.view.tintColor = colorGreen
                // add an buttons
                myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                // show the alert
                self.presentViewController(myAlert, animated: true, completion: nil)
            }
        }
    }
    
    //app methods
    override func viewDidLoad() {
        super.viewDidLoad()
        SwiftSpinner.show("Mise à jour des défis...")
        SwiftSpinner.setTitleFont(UIFont(name: "Segoe UI", size: 22.0))
        //sync
        FactoryHistory.getHistory().sync()
        self.view!.backgroundColor = colorGreyBackground
        self.loadData()
        self.friendsTable.backgroundColor = colorGreyBackground
        self.designShare.layer.cornerRadius = 6
        self.designAdd.layer.cornerRadius = 6
        self.designShuffle.layer.cornerRadius = 6
        self.navigationController!.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Segoe UI", size: 20)!]
        self.navigationController!.navigationBar.tintColor = colorGreen
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "logout", name: "failed", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "update", name: "update", object: nil)
        if self.revealViewController() != nil {
            self.menuButton.target = self.revealViewController()
            self.menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }

    func logout() {
        print("logging out")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func update() {
        // create alert controller
        let myAlert = UIAlertController(title: "Une mise à jour des questions est disponible", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        myAlert.view.tintColor = colorGreen
        // add an "later" button
        myAlert.addAction(UIAlertAction(title: "Plus tard", style: UIAlertActionStyle.Default, handler: nil))
        // add an "update" button
        myAlert.addAction(UIAlertAction(title: "Mettre à jour maintenant", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        // show the alert
        self.presentViewController(myAlert, animated: true, completion: nil)
    }
    
    
    //methods
    private func loadData() {
        
        //loading pendingDuos
        FactoryDuo.getDuoManager().savePendingDuos({ (result) -> Void in
            if result {
                self.pendingDuos = FactoryDuo.getDuoManager().getPendingDuos()
                print("pendingDuos synced")
            } else {
                print("offline pendingDuos")
            }
            self.pendingDuos = FactoryDuo.getDuoManager().getPendingDuos()
            self.templating()
            self.friendsTable.reloadData()
            SwiftSpinner.hide()
        })

        
        //loading friends
        FactoryDuo.getFriendManager().saveFriends { (result) -> Void in
            if result {
                print("friendsList synced")
            } else {
                print("offline friendsList")
                
            }
            self.friends = FactoryDuo.getFriendManager().getFriends()
            self.templating()
            self.friendsTable.reloadData()
        }
        
    }
    
    func templating(){
        if self.friends.isEmpty {
            let templateFriend = Friend()
            templateFriend.id = -1
            templateFriend.firstName = "Pas d'amis pour le moment"
            templateFriend.nickname = "Pas d'amis pour le moment"
            self.friends.append(templateFriend)
            
        }
        if self.pendingDuos.isEmpty {
            let templateDuo = PendingDuo()
            templateDuo.id = -1
            templateDuo.firstName = "Pas de défi en attente pour le moment"
            templateDuo.nickname = "Pas de défi en attente pour le moment"
            self.pendingDuos.append(templateDuo)
        }

    }
    
    func addTextField(textField: UITextField!){
        // add the text field and make the result global
        textField.placeholder = "Collez le code ici"
        self.textField = textField
    }
    
    func codeEntered(alert: UIAlertAction!){
        self.add(self.textField.text!)
    }
    
    private func add(code: String) {
        FactoryDuo.getFriendManager().saveFriend(code, callback: { (result, message) -> Void in
            if result {
                if self.friends[0].id == -1 {
                    self.friends.removeAtIndex(0)
                    self.friendsTable.deleteRowsAtIndexPaths([NSIndexPath(forItem: 0, inSection: 1)], withRowAnimation: UITableViewRowAnimation.Fade)
                }
                let counter = self.friends.count
                self.friends = FactoryDuo.getFriendManager().getFriends()
                //println(self.friends)
                if counter == self.friends.count {
                    // create alert controller
                    let myAlert = UIAlertController(title: "Oups !", message: "L'ami a déjà été ajouté... Entrez un autre code.", preferredStyle: UIAlertControllerStyle.Alert)
                    myAlert.view.tintColor = colorGreen
                    // add OK button
                    myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    // show the alert
                    self.presentViewController(myAlert, animated: true, completion: nil)
                } else {
                    // create alert controller
                    let myAlert = UIAlertController(title: "Ami ajouté", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                    myAlert.view.tintColor = colorGreen
                    // add OK button
                    myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    // show the alert
                    self.presentViewController(myAlert, animated: true, completion: nil)
                    let newIndexPath = NSIndexPath(forRow: self.friends.count-1, inSection: 1)
                    self.friendsTable.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Left)
                }
            } else {
                // create alert controller
                let myAlert = UIAlertController(title: "Erreur", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                myAlert.view.tintColor = colorGreen
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
    
    private func challenge(friend: Int) {
        print("requesting duo")
        FactoryDuo.getDuoManager().requestDuo(friend, callback: { (result, error) -> Void in
            if error != nil {
                let myAlert = UIAlertController(title: "Oups !", message: error, preferredStyle: UIAlertControllerStyle.Alert)
                myAlert.view.tintColor = colorGreen
                // add an buttons
                myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                // show the alert
                self.presentViewController(myAlert, animated: true, completion: nil)
                
            } else {
                print("Launching challenge number \(result!)")
                //self.performSegueWithIdentifier("showDuo", sender: self)
            }
        })
    }
    
    
    // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.pendingDuos.count
        } else {
            return self.friends.count
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("pendingChallenge", forIndexPath: indexPath) 
            let pendingDuo = self.pendingDuos[indexPath.row]
            
            var text = ""
            if pendingDuo.id != -1 {
                text = "Défi de "
            }
            
            if FactorySync.getConfigManager().loadNicknamePreference() {
                text += pendingDuo.nickname
            } else {
                text += "\(pendingDuo.firstName) \(pendingDuo.lastName)"
            }
            cell.textLabel!.text = text
            cell.textLabel?.textColor = UIColor.blackColor()
            cell.backgroundColor = colorGreyBackground
            cell.textLabel!.adjustsFontSizeToFitWidth = false
            cell.textLabel!.adjustsFontSizeToFitWidth = true
            let formatter = NSDateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            let dateInString = formatter.stringFromDate(pendingDuo.date)
            if pendingDuo.id == -1 {
                cell.accessoryType = UITableViewCellAccessoryType.None
                cell.detailTextLabel!.text = ""
            } else {
                cell.detailTextLabel!.text = dateInString
                cell.accessoryView = UIImageView(image: UIImage(named: "challenge"))
            }
            cell.textLabel!.font = UIFont(name: "Segoe UI", size: 16)
            cell.tintColor = colorGreen
            return cell

        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("friend", forIndexPath: indexPath) 
            let friend = self.friends[indexPath.row]
            if friend.id == -1 {
                cell.accessoryType = UITableViewCellAccessoryType.None
                cell.detailTextLabel!.text = ""
            } else {
                cell.detailTextLabel!.text = friend.awardPoints.toStringPoints()
                cell.accessoryView = UIImageView(image: UIImage(named: "challenge"))
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
            cell.tintColor = colorGreen
            return cell

        }
    }
    
    // Override to support editing the table view.
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            Sound.playTrack("notif")
            if indexPath.section == 1 {
                let friendToRemove = self.friends[indexPath.row]
                self.friends.removeAtIndex(indexPath.row)
                FactoryDuo.getFriendManager().deleteFriend(friendToRemove)
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
                if self.friends.isEmpty {
                    //create template
                    self.templating()
                    let newIndexPath = NSIndexPath(forItem: 0, inSection: 1)
                    self.friendsTable.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Left)
                }
                self.friendsTable.reloadData()
                
            }
        }
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        if indexPath.section == 0 {
            return UITableViewCellEditingStyle.None
        } else {
            let friend = self.friends[indexPath.row]
            if friend.id == -1 {
                return UITableViewCellEditingStyle.None
            } else {
                return UITableViewCellEditingStyle.Delete
            }
        }
    }
    
    
    //UITableViewDelegate Methods
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            let pendingDuos = self.pendingDuos[indexPath.row]
            if pendingDuos.id != -1 {
                //self.performSegueWithIdentifier("showDuo", sender: self)
            }
        } else {
            let friend = self.friends[indexPath.row]
            if friend.id != -1 {
                var textTodisplay = " "
                if FactorySync.getConfigManager().loadNicknamePreference() {
                    textTodisplay += "\(friend.nickname)"
                } else {
                    textTodisplay += "\(friend.firstName) \(friend.lastName)"
                }
                // create alert controller
                let myAlert = UIAlertController(title: "Lancer le défi ?", message: "Vous êtes sur le point de lancer un défi à \(textTodisplay), le défi va commencer tout de suite, vous aurez besoin de 20 minutes. ", preferredStyle: UIAlertControllerStyle.Alert)
                myAlert.view.tintColor = colorGreen
                // add an buttons
                myAlert.addAction(UIAlertAction(title: "Annuler", style: UIAlertActionStyle.Default, handler: nil))
                myAlert.addAction(UIAlertAction(title: "GO !", style: .Default, handler: { (action) -> Void in
                    self.challenge(friend.id)
                }))
                // show the alert
                self.presentViewController(myAlert, animated: true, completion: nil)
            }
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRectMake(0, 0, tableView.bounds.size.width, 30))
        headerView.backgroundColor = colorGreen
        
        let headerLabel = UILabel(frame: CGRectMake(15, 0, tableView.bounds.size.width, 20))
        headerLabel.backgroundColor = UIColor.clearColor()
        headerLabel.shadowOffset = CGSizeMake(0,2)
        headerLabel.textColor = UIColor.whiteColor()
        headerLabel.font = UIFont(name: "Segoe UI", size: 16)
        if section == 0 {
            headerLabel.text = "Défis en attente"
        } else {
            headerLabel.text = "Amis"
        }
        headerView.addSubview(headerLabel)
        return headerView
    }
    


}
