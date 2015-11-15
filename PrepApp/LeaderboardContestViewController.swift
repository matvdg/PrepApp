//
//  LeaderboardContestViewController.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 12/11/2015.
//  Copyright © 2015 PrepApp. All rights reserved.
//

import UIKit

class LeaderboardContestViewController: UITableViewController {
    
    var leaderboard = ContestLeaderboard()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //sync
        FactoryHistory.getHistory().sync()
        self.view!.backgroundColor = colorGreyBackground
        self.navigationController!.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Segoe UI", size: 20)!]
        self.navigationController!.navigationBar.tintColor = colorGreen        
        self.title = self.leaderboard.name
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "logout", name: "failed", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "update", name: "update", object: nil)
    }
    
    func logout() {
        print("logging out")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func update() {
        // create alert controller
        let myAlert = UIAlertController(title: "Une mise à jour des questions est disponible", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        myAlert.view.tintColor = colorGreen
        // add "later" button
        myAlert.addAction(UIAlertAction(title: "Plus tard", style: UIAlertActionStyle.Cancel, handler: nil))
        // add "update" button
        myAlert.addAction(UIAlertAction(title: "Mettre à jour maintenant", style: UIAlertActionStyle.Destructive, handler: { (action) -> Void in
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
        return self.leaderboard.players.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("contestPlayer", forIndexPath: indexPath)
        let contestPlayer = self.leaderboard.players[indexPath.row]
        cell.textLabel?.textColor = UIColor.blackColor()
        cell.backgroundColor = colorGreyBackground
        cell.textLabel!.adjustsFontSizeToFitWidth = false
        cell.textLabel!.adjustsFontSizeToFitWidth = true
        cell.textLabel!.font = UIFont(name: "Segoe UI", size: 16)
        cell.backgroundColor = colorGreyBackground
        cell.detailTextLabel!.text = contestPlayer.points.toStringPoints()
        cell.detailTextLabel!.font = UIFont(name: "Segoe UI", size: 16)
        cell.detailTextLabel!.textColor = colorGreen
        cell.textLabel!.adjustsFontSizeToFitWidth = true
        cell.detailTextLabel!.adjustsFontSizeToFitWidth = true
        cell.tintColor = colorGreen
        var textTodisplay = ""
        switch indexPath.row {
        case 0:
            //cell.backgroundColor = colorAwardPoints
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
            //cell.detailTextLabel!.textColor = UIColor.whiteColor()r
            cell.imageView?.image = UIImage(named: "bronzemedal")
        default:
            cell.imageView?.image = nil
            textTodisplay = " #\(indexPath.row+1)    "
        }
        if FactorySync.getConfigManager().loadNicknamePreference() {
            textTodisplay += "\(contestPlayer.nickname)"
        } else {
            textTodisplay += "\(contestPlayer.firstName) \(contestPlayer.lastName)"
        }
        cell.textLabel!.text = textTodisplay
        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 10)
        if contestPlayer.id == User.currentUser!.id {
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
