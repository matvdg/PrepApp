//
//  FriendViewController.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 14/05/15.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import UIKit

class DuoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //properties
    var friends = [Friend]()
    var pendingDuos = [PendingDuo]()
    var resultsDuo = [ResultDuo]()
    var selectedResultDuo = ResultDuo()
    let realm = FactoryRealm.getRealm()
    var textField =  UITextField()
    var pullToRefresh =  UIRefreshControl()
    var idDuo = 0
    var lastName = ""
    var firstName = ""
    var nickname = ""
    
    var refreshIsNeeded = false

    //@IBOutlet
	@IBOutlet var menuButton: UIBarButtonItem!
    @IBOutlet weak var designShuffle: UIButton!
    @IBOutlet weak var designAdd: UIButton!
    @IBOutlet weak var designShare: UIButton!
    @IBOutlet weak var duoTable: UITableView!
    
    //@IBAction
    @IBAction func shareCode(sender: AnyObject) {
        // create alert controller
        let myAlert = UIAlertController(title: "\(String(User.currentUser!.id).sha1())", message: "Partagez votre code à vos amis en leur envoyant un message !", preferredStyle: UIAlertControllerStyle.Alert)
        myAlert.view.tintColor = Colors.green
                // add buttons
        myAlert.addAction(UIAlertAction(title: "Annuler", style: UIAlertActionStyle.Cancel, handler: nil))
        myAlert.addAction(UIAlertAction(title: "Partager", style: .Default, handler: { (action) -> Void in
            SwiftSpinner.setTitleFont(UIFont(name: "Segoe UI", size: 22.0))
            SwiftSpinner.show("")
            self.share()
        }))
        
        // show the alert
        self.presentViewController(myAlert, animated: true, completion: nil)
    }
    
    @IBAction func addFriend(sender: AnyObject) {
        // create alert controller
        let myAlert = UIAlertController(title: "Ajouter un ami", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        myAlert.view.tintColor = Colors.green
        // add buttons
        myAlert.addAction(UIAlertAction(title: "Annuler", style: UIAlertActionStyle.Cancel, handler: nil))
        myAlert.addAction(UIAlertAction(title: "Ajouter", style: .Default, handler: self.add))
        //add prompt
        myAlert.addTextFieldWithConfigurationHandler(self.addTextField)
        // show the alert
        self.presentViewController(myAlert, animated: true, completion: nil)
    }
    
    @IBAction func shuffleFriend(sender: AnyObject) {
        SwiftSpinner.setTitleFont(UIFont(name: "Segoe UI", size: 22.0))
        SwiftSpinner.show("")
        FactoryDuo.getFriendManager().shuffleDuo { (friend, error) -> Void in
            SwiftSpinner.hide()
            if let shuffledFriend = friend {
                var textTodisplay = " "
                if FactorySync.getConfigManager().loadNicknamePreference() {
                    textTodisplay += "\(shuffledFriend.nickname)"
                } else {
                    textTodisplay += "\(shuffledFriend.firstName) \(shuffledFriend.lastName)"
                }
                print("Shuffled friendId = \(shuffledFriend.id)")
                // create alert controller
                let myAlert = UIAlertController(title: "Lancer le défi ?", message: "Vous êtes sur le point de lancer un défi à\(textTodisplay), le défi va commencer tout de suite, vous aurez besoin de \(FactorySync.getConfigManager().loadDuration()) minutes. Attention ! Vous devrez disposer d'une connexion internet pour envoyer vos résultats.", preferredStyle: UIAlertControllerStyle.Alert)
                myAlert.view.tintColor = Colors.green
                // add buttons
                myAlert.addAction(UIAlertAction(title: "Annuler", style: UIAlertActionStyle.Cancel, handler: nil))
                myAlert.addAction(UIAlertAction(title: "Oui", style: .Destructive, handler: { (action) -> Void in
                    self.challenge(shuffledFriend)
                }))
                // show the alert
                self.presentViewController(myAlert, animated: true, completion: nil)

            } else {
                // create alert controller
                let myAlert = UIAlertController(title: "Oups !", message: error, preferredStyle: UIAlertControllerStyle.Alert)
                myAlert.view.tintColor = Colors.green
                // add buttons
                myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                // show the alert
                self.presentViewController(myAlert, animated: true, completion: nil)
            }
        }
    }
    
    //app methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pullToRefresh.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.pullToRefresh.tintColor = Colors.green
        self.duoTable?.addSubview(pullToRefresh)
        SwiftSpinner.setTitleFont(UIFont(name: "Segoe UI", size: 22.0))
        SwiftSpinner.show("")
        //sync
        FactoryHistory.getHistory().sync()
        self.view!.backgroundColor = Colors.greyBackground
        self.loadData()
        self.duoTable.backgroundColor = Colors.greyBackground
        self.designShare.layer.cornerRadius = 6
        self.designAdd.layer.cornerRadius = 6
        self.designShuffle.layer.cornerRadius = 6
        self.navigationController!.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Segoe UI", size: 20)!]
        self.navigationController!.navigationBar.tintColor = Colors.greenLogo
        self.title = "Défi duo"
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "logout", name: "failed", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "update", name: "update", object: nil)
        if self.revealViewController() != nil {
            self.menuButton.target = self.revealViewController()
            self.menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        } else {
            self.menuButton.image = UIImage(named: "home")
            self.menuButton.target = self
            self.menuButton.action = "dismiss"
        }
    }
    
    func dismiss() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        if self.refreshIsNeeded {
            SwiftSpinner.setTitleFont(UIFont(name: "Segoe UI", size: 22.0))
            SwiftSpinner.show("")
            self.loadData()
        } else {
            self.refreshIsNeeded = true
        }
    }

    func logout() {
        print("logging out")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func update() {
        // create alert controller
        let myAlert = UIAlertController(title: "Une mise à jour des questions est disponible", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        myAlert.view.tintColor = Colors.green
        // add "later" button
        myAlert.addAction(UIAlertAction(title: "Plus tard", style: UIAlertActionStyle.Cancel, handler: nil))
        // add "update" button
        myAlert.addAction(UIAlertAction(title: "Mettre à jour maintenant", style: UIAlertActionStyle.Destructive, handler: { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        // show the alert
        self.presentViewController(myAlert, animated: true, completion: nil)
    }
    
    
    //methods
    private func loadData() {
        
        //loading pendingDuos
        FactoryDuo.getDuoManager().getPendingDuos({ (pendingDuos) -> Void in
            self.pendingDuos = pendingDuos
            //loading friends
            FactoryDuo.getFriendManager().getFriends { (friends) -> Void in
                self.friends = friends
                //loading ResultsDuo popup notification
                FactoryDuo.getDuoManager().getResultsDuo { (resultsDuo, notification) -> Void in
                    self.resultsDuo = resultsDuo
                    if notification {
                        // create alert controller
                        let myAlert = UIAlertController(title: "Nouveaux résultats disponibles", message: "Consultez la liste des résultats ! Vous pouvez supprimer des résultats de défi en glissant vers la gauche.", preferredStyle: UIAlertControllerStyle.Alert)
                        myAlert.view.tintColor = Colors.green
                        // add buttons
                        myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                        // show the alert
                        self.presentViewController(myAlert, animated: true, completion: nil)
                    }
                    self.templating()
                    self.duoTable.reloadData()
                    // tell refresh control it can stop showing up now
                    if self.pullToRefresh.refreshing
                    {
                        self.pullToRefresh.endRefreshing()
                    }
                    SwiftSpinner.hide()
                }
            }
        })
    }
    
    func templating(){
        if self.friends.isEmpty {
            let templateFriend = Friend()
            templateFriend.id = -1
            templateFriend.firstName = "Aucun ami pour le moment"
            templateFriend.nickname = "Aucun ami pour le moment"
            self.friends.append(templateFriend)
            
        }
        if self.pendingDuos.isEmpty {
            let templateDuo = PendingDuo()
            templateDuo.id = -1
            templateDuo.firstName = "Aucun défi pour le moment"
            templateDuo.nickname = "Aucun défi pour le moment"
            self.pendingDuos.append(templateDuo)
        }
        if self.resultsDuo.isEmpty {
            let templateDuo = ResultDuo()
            templateDuo.idDuo = -1
            self.resultsDuo.append(templateDuo)
        }

    }
    
    func addTextField(textField: UITextField!){
        // add the text field and make the result global
        textField.placeholder = "Collez le code ici"
        self.textField = textField
    }
    
    func add(alert: UIAlertAction!) {
        SwiftSpinner.setTitleFont(UIFont(name: "Segoe UI", size: 22.0))
        SwiftSpinner.show("")
        FactoryDuo.getFriendManager().saveFriend(self.textField.text!, callback: { (result, message) -> Void in
            SwiftSpinner.hide()
            if result {
                if self.friends[0].id == -1 {
                    self.friends.removeAtIndex(0)
                    self.duoTable.deleteRowsAtIndexPaths([NSIndexPath(forItem: 0, inSection: 1)], withRowAnimation: UITableViewRowAnimation.Fade)
                }
                let counter = self.friends.count
                self.friends = FactoryDuo.getFriendManager().getFriendsFromDB()
                if counter == self.friends.count {
                    // create alert controller
                    let myAlert = UIAlertController(title: "Oups !", message: "L'ami a déjà été ajouté... Entrez un autre code.", preferredStyle: UIAlertControllerStyle.Alert)
                    myAlert.view.tintColor = Colors.green
                    // add OK button
                    myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    // show the alert
                    self.presentViewController(myAlert, animated: true, completion: nil)
                } else {
                    // create alert controller
                    let myAlert = UIAlertController(title: "Ami ajouté", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                    myAlert.view.tintColor = Colors.green
                    // add OK button
                    myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    // show the alert
                    self.presentViewController(myAlert, animated: true, completion: nil)
                    let newIndexPath = NSIndexPath(forRow: self.friends.count-1, inSection: 1)
                    self.duoTable.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Left)
                }
            } else {
                // create alert controller
                let myAlert = UIAlertController(title: "Erreur", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                myAlert.view.tintColor = Colors.green
                // add OK button
                myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                // show the alert
                self.presentViewController(myAlert, animated: true, completion: nil)
            }
        })
    }
    
    private func share() {
        let idToShare = String(User.currentUser!.id).sha1()
        let objectsToShare: [AnyObject] = [idToShare]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityVC.excludedActivityTypes = [UIActivityTypePostToTwitter]
        activityVC.setValue("Mon code Prep'App", forKey: "subject")
        self.presentViewController(activityVC, animated: true, completion: nil)
        SwiftSpinner.hide()
    }
    
    private func challenge(friend: Friend) {
        print("requesting duo")
        FactoryDuo.getDuoManager().requestDuo(friend.id, callback: { (result, error) -> Void in
            if error != nil {
                let myAlert = UIAlertController(title: "Oups !", message: error, preferredStyle: UIAlertControllerStyle.Alert)
                myAlert.view.tintColor = Colors.green
                // add "OK" button
                myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                // show the alert
                self.presentViewController(myAlert, animated: true, completion: nil)
                
            } else {
                self.idDuo = result!
                self.lastName = friend.lastName
                self.firstName = friend.firstName
                self.nickname = friend.nickname
                print("Launching challenge number \(result!)")
                self.performSegueWithIdentifier("showDuo", sender: self)
            }
        })
    }
    
    func refresh(sender:AnyObject) {
        self.loadData()
    }

    
    // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.pendingDuos.count
        } else if section == 1 {
            return self.friends.count
        } else {
            return self.resultsDuo.count
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
            cell.backgroundColor = Colors.greyBackground
            cell.textLabel!.adjustsFontSizeToFitWidth = false
            cell.textLabel!.adjustsFontSizeToFitWidth = true
            //fetching expiration
            let offsetComponents = NSDateComponents()
            offsetComponents.minute = 24*60 - FactorySync.getConfigManager().loadDuration()
            let initDate = pendingDuo.date
            let expirationDate = NSCalendar.currentCalendar().dateByAddingComponents(offsetComponents, toDate: initDate, options: NSCalendarOptions(rawValue: 0))!
            //formatting
            let formatter = NSDateFormatter()
            formatter.dateFormat = "EEEE à H:mm"
            let dateInString = "Expire \(formatter.stringFromDate(expirationDate))"
            if pendingDuo.id == -1 {
                cell.accessoryType = UITableViewCellAccessoryType.None
                cell.detailTextLabel!.text = ""
            } else {
                cell.detailTextLabel!.text = dateInString
                cell.accessoryView = UIImageView(image: UIImage(named: "challenge"))
            }
            cell.textLabel!.font = UIFont(name: "Segoe UI", size: 16)
            cell.tintColor = Colors.green
            return cell
        } else if indexPath.section == 1 {
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
            cell.backgroundColor = Colors.greyBackground
            cell.textLabel!.adjustsFontSizeToFitWidth = false
            cell.textLabel!.adjustsFontSizeToFitWidth = true
            cell.textLabel!.font = UIFont(name: "Segoe UI", size: 16)
            cell.tintColor = Colors.green
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("resultDuo", forIndexPath: indexPath)
            let resultDuo = self.resultsDuo[indexPath.row]
            if resultDuo.idDuo == -1 {
                cell.accessoryType = UITableViewCellAccessoryType.None
                cell.textLabel!.text = "Aucun résultat pour le moment"
            } else {
                cell.accessoryView = UIImageView(image: UIImage(named: "results"))
                cell.textLabel!.text = "Défi VS "
                if resultDuo.resultDuo.first!.id == User.currentUser!.id {
                    //you're player A, we display B
                    if FactorySync.getConfigManager().loadNicknamePreference() {
                        cell.textLabel!.text! += resultDuo.resultDuo.last!.nickname
                    } else {
                        cell.textLabel!.text! += "\(resultDuo.resultDuo.last!.firstName) \(resultDuo.resultDuo.last!.lastName)"
                    }
                } else {
                    //you're player B, we display A
                    if FactorySync.getConfigManager().loadNicknamePreference() {
                        cell.textLabel!.text! += resultDuo.resultDuo.first!.nickname
                    } else {
                        cell.textLabel!.text! += "\(resultDuo.resultDuo.first!.firstName) \(resultDuo.resultDuo.first!.lastName)"
                    }
                }
            }
            cell.textLabel?.textColor = UIColor.blackColor()
            cell.backgroundColor = Colors.greyBackground
            cell.textLabel!.adjustsFontSizeToFitWidth = false
            cell.textLabel!.adjustsFontSizeToFitWidth = true
            cell.textLabel!.font = UIFont(name: "Segoe UI", size: 16)
            cell.tintColor = Colors.green
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
                    self.duoTable.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Left)
                }
                self.duoTable.reloadData()
            } else if indexPath.section == 2 {
                let resultDuoToRemove = self.resultsDuo[indexPath.row]
                self.resultsDuo.removeAtIndex(indexPath.row)
                FactoryDuo.getDuoManager().deleteResultDuo(resultDuoToRemove)
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
                if self.resultsDuo.isEmpty {
                    //create template
                    self.templating()
                    let newIndexPath = NSIndexPath(forItem: 0, inSection: 2)
                    self.duoTable.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Left)
                }
                self.duoTable.reloadData()
            }
        }
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        if indexPath.section == 0 {
            return UITableViewCellEditingStyle.None
        } else if indexPath.section == 1 {
            let friend = self.friends[indexPath.row]
            if friend.id == -1 {
                return UITableViewCellEditingStyle.None
            } else {
                return UITableViewCellEditingStyle.Delete
            }
        } else {
            let resultDuo = self.resultsDuo[indexPath.row]
            if resultDuo.idDuo == -1 {
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
            let pendingDuo = self.pendingDuos[indexPath.row]
            if pendingDuo.id != -1 {
                var textTodisplay = " "
                if FactorySync.getConfigManager().loadNicknamePreference() {
                    textTodisplay += "\(pendingDuo.nickname)"
                } else {
                    textTodisplay += "\(pendingDuo.firstName) \(pendingDuo.lastName)"
                }
                // create alert controller
                let myAlert = UIAlertController(title: "Répondre au défi ?", message: "Vous êtes sur le point de répondre au défi de\(textTodisplay), le défi va commencer tout de suite, vous aurez besoin de \(FactorySync.getConfigManager().loadDuration()) minutes. Attention ! Vous devrez disposer d'une connexion internet pour envoyer vos résultats. ", preferredStyle: UIAlertControllerStyle.Alert)
                myAlert.view.tintColor = Colors.green
                // add buttons
                myAlert.addAction(UIAlertAction(title: "Annuler", style: UIAlertActionStyle.Cancel, handler: nil))
                myAlert.addAction(UIAlertAction(title: "Oui", style: .Destructive, handler: { (action) -> Void in
                    self.idDuo = pendingDuo.id
                    self.lastName = pendingDuo.lastName
                    self.firstName = pendingDuo.firstName
                    self.nickname = pendingDuo.nickname
                    print("Launching challenge number \(pendingDuo.id)")
                    self.pendingDuos.removeAtIndex(indexPath.row)
                    FactoryDuo.getDuoManager().deletePendingDuo(pendingDuo)
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
                    self.performSegueWithIdentifier("showDuo", sender: self)
                }))
                // show the alert
                self.presentViewController(myAlert, animated: true, completion: nil)
            }
        } else if indexPath.section == 1 {
            let friend = self.friends[indexPath.row]
            if friend.id != -1 {
                var textTodisplay = " "
                if FactorySync.getConfigManager().loadNicknamePreference() {
                    textTodisplay += "\(friend.nickname)"
                } else {
                    textTodisplay += "\(friend.firstName) \(friend.lastName)"
                }
                // create alert controller
                let myAlert = UIAlertController(title: "Lancer le défi ?", message: "Vous êtes sur le point de lancer un défi à votre ami(e)\(textTodisplay), le défi va commencer tout de suite, vous aurez besoin de \(FactorySync.getConfigManager().loadDuration()) minutes. ", preferredStyle: UIAlertControllerStyle.Alert)
                myAlert.view.tintColor = Colors.green
                // add buttons
                myAlert.addAction(UIAlertAction(title: "Annuler", style: UIAlertActionStyle.Cancel, handler: nil))
                myAlert.addAction(UIAlertAction(title: "GO !", style: .Default, handler: { (action) -> Void in
                    self.challenge(friend)
                }))
                // show the alert
                self.presentViewController(myAlert, animated: true, completion: nil)
            }
        } else {
            let resultDuo = self.resultsDuo[indexPath.row]
            if resultDuo.idDuo != -1 {
                self.selectedResultDuo = resultDuo
                self.performSegueWithIdentifier("showResultsDuo", sender: self)
            }
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRectMake(0, 0, tableView.bounds.size.width, 44))
        headerView.backgroundColor = Colors.green
        
        let headerLabel = UILabel(frame: CGRectMake(15, 0, tableView.bounds.size.width, 44))
        headerLabel.backgroundColor = UIColor.clearColor()
        headerLabel.shadowOffset = CGSizeMake(0,2)
        headerLabel.textColor = UIColor.whiteColor()
        headerLabel.font = UIFont(name: "Segoe UI", size: 20)
        if section == 0 {
            headerLabel.text = "En attente"
        } else if section == 1{
            headerLabel.text = "Amis"
        } else {
             headerLabel.text = "Résultats"
        }
        headerView.addSubview(headerLabel)
        return headerView
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let QDVC = segue.destinationViewController as? QuestionDuoViewController {
            // Pass the selected object to the new view controller.
            QDVC.idDuo = self.idDuo
            QDVC.lastName = self.lastName
            QDVC.firstName = self.firstName
            QDVC.nickname = self.nickname
        }
        
        if let ResultsDuoVC = segue.destinationViewController as? ResultsDuoViewController {
            // Pass the selected object to the new view controller.
            ResultsDuoVC.resultDuo = self.selectedResultDuo
        }
    }
}
