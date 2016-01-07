//
//  LeaderboardTableViewController.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 15/09/2015.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import UIKit

class LeaderboardTableViewController: UITableViewController  {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    var friends = [Friend]()
    var pullToRefresh =  UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pullToRefresh.tintColor = Colors.green
        self.pullToRefresh.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView?.addSubview(pullToRefresh)
        SwiftSpinner.setTitleFont(UIFont(name: "Segoe UI", size: 22.0))
        SwiftSpinner.show("")
        //sync
        FactoryHistory.getHistory().sync()
        self.view!.backgroundColor = Colors.greyBackground
        self.loadLeaderboard()
        self.navigationController!.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Segoe UI", size: 20)!]
        self.navigationController!.navigationBar.tintColor = Colors.greenLogo
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
                // tell refresh control it can stop showing up now
                if self.pullToRefresh.refreshing
                {
                    self.pullToRefresh.endRefreshing()
                }
                self.tableView.reloadData()
                SwiftSpinner.hide()
            } else {
                SwiftSpinner.hide()
                // tell refresh control it can stop showing up now
                if self.pullToRefresh.refreshing
                {
                    self.pullToRefresh.endRefreshing()
                }
                let myAlert = UIAlertController(title: "Erreur", message: "Échec de la connexion. Veuillez vérifier que vous êtes connecté à internet avec une bonne couverture cellulaire ou WiFi, puis réessayez." , preferredStyle: UIAlertControllerStyle.Alert)
                myAlert.view.tintColor = Colors.green
                myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
                myAlert.addAction(UIAlertAction(title: "Réessayer", style: .Default, handler: { (action) -> Void in
                    self.loadLeaderboard()
                }))
                // show the alert
                self.presentViewController(myAlert, animated: true, completion: nil)
                
            }
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
    func refresh(sender:AnyObject) {
        self.loadLeaderboard()
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.friends.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("friend", forIndexPath: indexPath) 
        let friend = self.friends[indexPath.row]
        cell.textLabel?.textColor = UIColor.blackColor()
        cell.backgroundColor = Colors.greyBackground
        cell.textLabel!.adjustsFontSizeToFitWidth = false
        cell.textLabel!.font = UIFont(name: "Segoe UI", size: 16)
        cell.backgroundColor = Colors.greyBackground
        cell.detailTextLabel!.text = friend.awardPoints.toStringPoints()
        cell.detailTextLabel!.font = UIFont(name: "Segoe UI", size: 16)
        cell.detailTextLabel!.textColor = Colors.green
        cell.textLabel!.adjustsFontSizeToFitWidth = true
        cell.detailTextLabel!.adjustsFontSizeToFitWidth = true
        cell.tintColor = Colors.green
        var textTodisplay = ""
        switch indexPath.row {
        case 0:
            //cell.backgroundColor = Colors.awardPoints
            //cell.textLabel?.textColor = UIColor.whiteColor()
            //cell.detailTextLabel!.textColor = UIColor.whiteColor()
            cell.imageView?.image = UIImage(named: "goldcup")
        case 1:
            //cell.backgroundColor = colorSilver
            //cell.textLabel?.textColor = UIColor.whiteColor()
            //cell.detailTextLabel!.textColor = UIColor.whiteColor()
            cell.imageView?.image = UIImage(named: "silvermedal")
        case 2:
            //cell.backgroundColor = colorBronze
            //cell.textLabel?.textColor = UIColor.whiteColor()
            //cell.detailTextLabel!.textColor = UIColor.whiteColor()
            cell.imageView?.image = UIImage(named: "bronzemedal")
        default:
            cell.imageView?.image = nil
            textTodisplay = " #\(indexPath.row+1)    "
        }
        if FactorySync.getConfigManager().loadNicknamePreference() {
            textTodisplay += "\(friend.nickname)"
        } else {
            textTodisplay += "\(friend.firstName) \(friend.lastName)"
        }
        cell.textLabel!.text = textTodisplay
        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 10)
        if friend.id == User.currentUser!.id {
            cell.backgroundColor = Colors.greenLogo
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
