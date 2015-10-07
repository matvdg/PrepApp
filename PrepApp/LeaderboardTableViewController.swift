//
//  LeaderboardTableViewController.swift
//  PrepApp
//
//  Created by Mikael Vandeginste on 15/09/2015.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import UIKit

class LeaderboardTableViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate  {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    var friends = [Friend]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //sync
        FactoryHistory.getHistory().sync()
        self.view!.backgroundColor = colorGreyBackground
        self.loadLeaderboard()
        self.navigationController!.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Segoe UI", size: 20)!]
        self.navigationController!.navigationBar.tintColor = colorGreen
        if self.revealViewController() != nil {
            self.menuButton.target = self.revealViewController()
            self.menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }

        self.title = "Classement"
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "logout", name: "failed", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "update", name: "update", object: nil)
    }
    
    func loadLeaderboard() {
        FactoryHistory.getScoring().loadLeaderboard { (data) -> Void in
            if let leaderboard = data {
                self.friends = leaderboard
                self.tableView.reloadData()
            } else {
                let myAlert = UIAlertController(title: "Erreur", message: "Échec de la connexion. Veuillez vérifier que vous êtes connecté à internet avec une bonne couverture cellulaire ou WiFi, puis réessayez." , preferredStyle: UIAlertControllerStyle.Alert)
                myAlert.view.tintColor = colorGreen
                myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                myAlert.addAction(UIAlertAction(title: "Réessayer", style: .Default, handler: { (action) -> Void in
                    self.loadLeaderboard()
                }))
                // show the alert
                self.presentViewController(myAlert, animated: true, completion: nil)
                
            }
        }

    }
    func logout() {
        println("logging out")
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

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.friends.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("friend", forIndexPath: indexPath) as! UITableViewCell
        let friend = self.friends[indexPath.row]
        var textTodisplay = "#\(indexPath.row+1) "
        if FactorySync.getConfigManager().loadNicknamePreference() {
            textTodisplay += "\(friend.nickname)"
        } else {
            textTodisplay += "\(friend.firstName) \(friend.lastName)"
        }
        cell.textLabel!.text = textTodisplay
        cell.textLabel?.textColor = UIColor.blackColor()
        cell.backgroundColor = colorGreyBackground
        cell.textLabel!.adjustsFontSizeToFitWidth = false
        cell.textLabel!.adjustsFontSizeToFitWidth = true
        cell.textLabel!.font = UIFont(name: "Segoe UI", size: 16)
        cell.tintColor = colorGreen
        cell.backgroundColor = colorGreyBackground
        cell.detailTextLabel!.text = friend.awardPoints.toStringPoints()
        cell.detailTextLabel!.font = UIFont(name: "Segoe UI", size: 16)
        cell.detailTextLabel!.textColor = colorGreen
        cell.textLabel!.adjustsFontSizeToFitWidth = true
        cell.detailTextLabel!.adjustsFontSizeToFitWidth = true
        cell.tintColor = colorGreen
        
        if friend.id == User.currentUser!.id {
            cell.backgroundColor = colorGreenLogo
            cell.detailTextLabel!.textColor = UIColor.whiteColor()
            cell.textLabel?.textColor = UIColor.whiteColor()            
        }

        return cell
    }
    
    
    //UITableViewDelegate Methods
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }

}
