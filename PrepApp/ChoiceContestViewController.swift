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
    var contestsHistory = [ContestHistory]()
    var contestLeaderboards = [ContestLeaderboard]()
    let realm = FactoryRealm.getRealm()
    var pullToRefresh =  UIRefreshControl()
    var refreshIsNeeded = false
    var selectedContest: Contest?
    var selectedContestHistory: ContestHistory?
    var selectedContestLeaderboard: ContestLeaderboard?
    
    //@IBOutlet
    @IBOutlet var menuButton: UIBarButtonItem!
    @IBOutlet weak var contestTable: UITableView!
    
    //app methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadData()
        self.pullToRefresh.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.pullToRefresh.tintColor = Colors.green
        self.contestTable?.addSubview(pullToRefresh)
        //sync
        FactoryHistory.getHistory().sync()
        self.view!.backgroundColor = Colors.greyBackground
        self.contestTable.backgroundColor = Colors.greyBackground
        self.navigationController!.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Segoe UI", size: 20)!]
        self.navigationController!.navigationBar.tintColor = Colors.greenLogo
        self.title = "Concours"
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
        self.contestLeaderboards = [ContestLeaderboard]()
        SwiftSpinner.setTitleFont(UIFont(name: "Segoe UI", size: 22.0))
        SwiftSpinner.show("")
        //loading contests
        FactorySync.getContestManager().getContests { (contests) -> Void in
            self.contests = contests
            self.contestsHistory = FactorySync.getContestManager().getResultContests()
            FactorySync.getContestManager().getContestLeaderboards({ (contestLeaderboards) -> Void in
                self.contestLeaderboards = contestLeaderboards
                //sync finished!
                self.templating()
                self.contestTable.reloadData()
                // tell refresh control it can stop showing up now
                if self.pullToRefresh.refreshing
                {
                    self.pullToRefresh.endRefreshing()
                }
                //hide the waiting animation
                SwiftSpinner.hide()

            })
        }
    }
    
    func templating(){
        if self.contests.isEmpty {
            let templateContest = Contest()
            templateContest.id = -1
            templateContest.name = "Aucun concours pour le moment"
            self.contests.append(templateContest)
        }
        if self.contestsHistory.isEmpty {
            let templateContestHistory = ContestHistory()
            templateContestHistory.id = -1
            templateContestHistory.name = "Aucun résultat pour le moment"
            self.contestsHistory.append(templateContestHistory)
        }
        if self.contestLeaderboards.isEmpty {
            let templateContestLeaderboard = ContestLeaderboard()
            templateContestLeaderboard.id = -1
            templateContestLeaderboard.name = "Aucun classement pour le moment"
            self.contestLeaderboards.append(templateContestLeaderboard)
        }
        
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
            return self.contests.count
        } else if section == 1 {
            return self.contestsHistory.count
        } else {
            return self.contestLeaderboards.count
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("contest", forIndexPath: indexPath)
            let contest = self.contests[indexPath.row]
            cell.textLabel!.text = contest.name
            cell.textLabel?.textColor = UIColor.blackColor()
            cell.backgroundColor = Colors.greyBackground
            cell.textLabel!.adjustsFontSizeToFitWidth = true
            cell.textLabel!.adjustsFontSizeToFitWidth = true
            //formatting date
            let formatter = NSDateFormatter()
            formatter.dateFormat = "d/M/yyyy"
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
            cell.tintColor = Colors.green
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("contestResult", forIndexPath: indexPath)
            let contestHistory = self.contestsHistory[indexPath.row]
            cell.textLabel!.text = contestHistory.name
            cell.textLabel?.textColor = UIColor.blackColor()
            cell.backgroundColor = Colors.greyBackground
            cell.textLabel!.adjustsFontSizeToFitWidth = true
            cell.textLabel!.adjustsFontSizeToFitWidth = true
            //adding contest details to the table
            if contestHistory.id == -1 {
                cell.accessoryType = UITableViewCellAccessoryType.None
                cell.detailTextLabel!.text = ""
            } else {
                cell.detailTextLabel!.text = ""
                cell.accessoryView = UIImageView(image: UIImage(named: "results"))
            }
            cell.textLabel!.font = UIFont(name: "Segoe UI", size: 16)
            cell.tintColor = Colors.green
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("contestLeaderboard", forIndexPath: indexPath)
            let contestLeaderboard = self.contestLeaderboards[indexPath.row]
            cell.textLabel!.text = contestLeaderboard.name
            cell.textLabel?.textColor = UIColor.blackColor()
            cell.backgroundColor = Colors.greyBackground
            cell.textLabel!.adjustsFontSizeToFitWidth = true
            cell.textLabel!.adjustsFontSizeToFitWidth = true
            //adding contest details to the table
            if contestLeaderboard.id == -1 {
                cell.accessoryType = UITableViewCellAccessoryType.None
                cell.detailTextLabel!.text = ""
            } else {
                cell.detailTextLabel!.text = ""
                cell.accessoryView = UIImageView(image: UIImage(named: "leaderboard"))
            }
            cell.textLabel!.font = UIFont(name: "Segoe UI", size: 16)
            cell.tintColor = Colors.green
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
        } else if indexPath.section == 1 {
            let contestHistory = self.contestsHistory[indexPath.row]
            self.selectedContestHistory = contestHistory
            if contestHistory.id != -1 {
                self.performSegueWithIdentifier("showScore", sender: self)
            }
        } else {
            let contestLeaderboard = self.contestLeaderboards[indexPath.row]
            self.selectedContestLeaderboard = contestLeaderboard
            if contestLeaderboard.id != -1 {
                self.performSegueWithIdentifier("showContestLeaderboard", sender: self)
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
            headerLabel.text = "En cours"
        } else if section == 1 {
            headerLabel.text = "Résultats"
        } else {
            headerLabel.text = "Classements"
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
        
        if let scoreVC = segue.destinationViewController as? ScoreContestViewController {
            // Pass the selected object to the new view controller.
            scoreVC.score = self.selectedContestHistory!.score
            scoreVC.emptyAnswers = self.selectedContestHistory!.emptyAnswers
            scoreVC.succeeded = self.selectedContestHistory!.succeeded
            scoreVC.numberOfQuestions = self.selectedContestHistory!.numberOfQuestions
            let contest = Contest()
            contest.id = self.selectedContestHistory!.id
            contest.name = selectedContestHistory!.name
            contest.content = selectedContestHistory!.content
            contest.wrongAnswer = selectedContestHistory!.wrongAnswer
            contest.goodAnswer = selectedContestHistory!.goodAnswer
            contest.noAnswer = selectedContestHistory!.noAnswer
            contest.duration = selectedContestHistory!.duration
            contest.begin = selectedContestHistory!.begin
            contest.end = selectedContestHistory!.end
            scoreVC.contest = contest
            scoreVC.reviewMode = true
        }
    }
}
