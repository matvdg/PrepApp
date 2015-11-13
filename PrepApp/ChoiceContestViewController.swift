//
//  ChoiceContestViewController.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 12/11/2015.
//  Copyright © 2015 PrepApp. All rights reserved.
//

import UIKit

class ChoiceContestViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //properties
    var contests = [Contest]()
    var contestsLeaderboard = [ContestLeaderboard]()
    let realm = FactoryRealm.getRealmFriends()
    var pullToRefresh =  UIRefreshControl()
    var refreshIsNeeded = false
    var selectedContest: Contest?
    var selectedContestLeaderboard: ContestLeaderboard?
    
    //@IBOutlet
    @IBOutlet var menuButton: UIBarButtonItem!
    @IBOutlet weak var contestTable: UITableView!
    
    
    //app methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadData()
        self.pullToRefresh.attributedTitle = NSAttributedString(string: "▼ Glisser vers le bas pour actualiser ▼")
        self.pullToRefresh.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.pullToRefresh.tintColor = colorGreen
        self.contestTable?.addSubview(pullToRefresh)
        //sync
        FactoryHistory.getHistory().sync()
        self.view!.backgroundColor = colorGreyBackground
        self.contestTable.backgroundColor = colorGreyBackground
        self.navigationController!.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Segoe UI", size: 20)!]
        self.navigationController!.navigationBar.tintColor = colorGreen
        self.title = "Concours"
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "logout", name: "failed", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "update", name: "update", object: nil)
        if self.revealViewController() != nil {
            self.menuButton.target = self.revealViewController()
            self.menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        if self.refreshIsNeeded {
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
    
    //methods
    private func loadData() {
        SwiftSpinner.show("Recherche de concours...")
        SwiftSpinner.setTitleFont(UIFont(name: "Segoe UI", size: 22.0))
        //loading contests
        FactorySync.getContestManager().getContests { (contests) -> Void in
            self.contests = contests
            self.templating()
            self.contestTable.reloadData()
            // tell refresh control it can stop showing up now
            if self.pullToRefresh.refreshing
            {
                self.pullToRefresh.endRefreshing()
            }
            SwiftSpinner.hide()
        }
    }
    
    func templating(){
        if self.contests.isEmpty {
            let templateContest = Contest()
            templateContest.id = -1
            templateContest.name = "Pas de concours pour le moment"
            self.contests.append(templateContest)
            
        }
        if self.contestsLeaderboard.isEmpty {
            let templateContestLeaderboard = ContestLeaderboard()
            templateContestLeaderboard.name = "Pas de résultats de concours pour le moment"
            self.contestsLeaderboard.append(templateContestLeaderboard)
        }
        
    }
    
    func refresh(sender:AnyObject) {
        self.loadData()
    }
    
    // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.contests.count
        } else {
            return self.contestsLeaderboard.count
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("contest", forIndexPath: indexPath)
            let contest = self.contests[indexPath.row]
            cell.textLabel!.text = contest.name
            cell.textLabel?.textColor = UIColor.blackColor()
            cell.backgroundColor = colorGreyBackground
            cell.textLabel!.adjustsFontSizeToFitWidth = true
            cell.textLabel!.adjustsFontSizeToFitWidth = true
            //formatting date
            let formatter = NSDateFormatter()
            formatter.dateFormat = "d/M/yy"
            let end = formatter.stringFromDate(contest.end)
            //adding contest details to the table
            if contest.id == -1 {
                cell.accessoryType = UITableViewCellAccessoryType.None
                cell.detailTextLabel!.text = ""
            } else {
                cell.detailTextLabel!.text = end
                cell.accessoryView = UIImageView(image: UIImage(named: "contest"))
            }
            cell.textLabel!.font = UIFont(name: "Segoe UI", size: 16)
            cell.tintColor = colorGreen
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("contestResult", forIndexPath: indexPath)
            let contestLeaderboard = self.contestsLeaderboard[indexPath.row]
            cell.textLabel!.text = contestLeaderboard.name
            cell.textLabel?.textColor = UIColor.blackColor()
            cell.backgroundColor = colorGreyBackground
            cell.textLabel!.adjustsFontSizeToFitWidth = true
            cell.textLabel!.adjustsFontSizeToFitWidth = true
            //formatting date
            let formatter = NSDateFormatter()
            formatter.dateFormat = "d/M/yy"
            let end = formatter.stringFromDate(contestLeaderboard.end)
            //adding contest details to the table
            if contestLeaderboard.name == "Pas de résultats de concours pour le moment" {
                cell.accessoryType = UITableViewCellAccessoryType.None
                cell.detailTextLabel!.text = ""
            } else {
                cell.detailTextLabel!.text = end
                cell.accessoryView = UIImageView(image: UIImage(named: "leaderboard"))
            }
            cell.textLabel!.font = UIFont(name: "Segoe UI", size: 16)
            cell.tintColor = colorGreen
            return cell
        }
    }
    
    //UITableViewDelegate Methods
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            let contest = self.contests[indexPath.row]
            self.selectedContest = contest
            if contest.id != -1 {
                self.performSegueWithIdentifier("showContestContent", sender: self)
            }
        } else {
            let contestLeaderboard = self.contestsLeaderboard[indexPath.row]
            if contestLeaderboard.name != "Pas de résultats de concours pour le moment" {
                self.performSegueWithIdentifier("showContestLeaderboard", sender: self)
            }
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRectMake(0, 0, tableView.bounds.size.width, 44))
        headerView.backgroundColor = colorGreen
        
        let headerLabel = UILabel(frame: CGRectMake(15, 0, tableView.bounds.size.width, 44))
        headerLabel.backgroundColor = UIColor.clearColor()
        headerLabel.shadowOffset = CGSizeMake(0,2)
        headerLabel.textColor = UIColor.whiteColor()
        headerLabel.font = UIFont(name: "Segoe UI", size: 20)
        if section == 0 {
            headerLabel.text = "Concours"
        } else {
            headerLabel.text = "Résultats de concours"
        }
        headerView.addSubview(headerLabel)
        return headerView
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let CVC = segue.destinationViewController as? ContestViewController {
            // Pass the selected object to the new view controller.
            CVC.contest = self.selectedContest!
        }
        
        if let LCVC = segue.destinationViewController as? LeaderboardContestViewController {
            // Pass the selected object to the new view controller.
            LCVC.leaderboard = self.selectedContestLeaderboard!
        }
    }
}
