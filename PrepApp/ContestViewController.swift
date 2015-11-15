//
//  ContestViewController.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 14/05/15.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import UIKit

class ContestViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIWebViewDelegate {

    //@IBOutlets
    @IBOutlet weak var launchButton: UIButton!
    @IBOutlet weak var contestTable: UITableView!
    @IBOutlet weak var contestContent: UIWebView!
    
    //properties
    var contest = Contest()
    var elements = ["Date","Durée","Réponse juste","Réponse vide","Réponse fausse"]
    var images = ["term","solo","true","empty","false"]
    var details: [String]?
    var refreshIsNeeded = false
    var contestHistory: ContestHistory?
    var reviewMode = false
    //app methods
	override func viewDidLoad() {
        self.loadData()
        //sync
        FactoryHistory.getHistory().sync()
        self.view!.backgroundColor = colorGreyBackground
        self.contestContent.backgroundColor = UIColor.clearColor()
        self.contestContent.opaque = false
        self.launchButton.layer.cornerRadius = 6
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "logout", name: "failed", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "update", name: "update", object: nil)
        self.navigationController!.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Segoe UI", size: 20)!]
        self.navigationController!.navigationBar.tintColor = colorGreen
        self.title = self.contest.name
	}
    
    override func viewDidAppear(animated: Bool) {
        if self.refreshIsNeeded {
            self.loadData()
            self.contestTable.reloadData()
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
    func loadData() {
        //formatting date
        let formatter = NSDateFormatter()
        formatter.dateFormat = "d/M/yy"
        let begin = formatter.stringFromDate(self.contest.begin)
        let end = formatter.stringFromDate(self.contest.end)
        //adding contest details to the table
        self.details = ["Du \(begin) au \(end)"]
        self.details!.append("\(self.contest.duration) minutes")
        let goodAnswer = abs(self.contest.goodAnswer)
        let badAnswer = -abs(self.contest.wrongAnswer)
        let emptyAnswer = -abs(self.contest.noAnswer)
        self.details!.append(goodAnswer.toStringPoints())
        self.details!.append(badAnswer.toStringPoints())
        self.details!.append(emptyAnswer.toStringPoints())
        //loading content
        self.contestContent.loadHTMLString(self.contest.content, baseURL: nil)
        
        if !FactoryHistory.getHistory().isContestNew(self.contest.id) {
            /*the contest isn't new -> fetched from QuestionHistory - we couldn't have checked into ContestHistory -although it'd have been an easier check- because this local data isn't saved into PrepApp servers, just in local Realm DB, so we loose it after a new install of the app... So we could do the contest twice and cheating just by reinstalling the app or logging out. So we checked into QuestionHistory which is stored locally and remotely, the check is 100% sure :D */
            //now we check into the local only ContestHistory to let display the score again or not (only if available)
            if let resultContest = FactorySync.getContestManager().getResultContest(self.contest.id) {
                //results available!
                self.contestHistory = resultContest
                self.reviewMode = true
                self.launchButton.setTitle("Revoir les résultats", forState: UIControlState.Normal)
            } else {
                //no results to display
                self.launchButton.enabled = false
                self.launchButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Disabled)
                self.launchButton.backgroundColor = colorDarkGrey
                self.launchButton.setTitle("Concours terminé", forState: UIControlState.Disabled)
            }
        }
    }
    
    //@IBAction
    @IBAction func launch(sender: AnyObject) {
        if self.reviewMode {
            self.performSegueWithIdentifier("showScore", sender: self)
        } else {
            // create alert controller
            let myAlert = UIAlertController(title: "Lancer le concours ?", message: "Vous devez disposer de \(self.contest.duration) minutes devant vous !", preferredStyle: UIAlertControllerStyle.Alert)
            myAlert.view.tintColor = colorGreen
            // add buttons
            myAlert.addAction(UIAlertAction(title: "NON", style: UIAlertActionStyle.Cancel, handler: nil))
            myAlert.addAction(UIAlertAction(title: "OUI", style: UIAlertActionStyle.Destructive, handler: { (action) -> Void in
                print("launching contest number \(self.contest.id)")
                self.performSegueWithIdentifier("showContest", sender: self)
            }))
            // show the alert
            self.presentViewController(myAlert, animated: true, completion: nil)
        }
    }
    
    //UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.elements.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("item", forIndexPath: indexPath)
        let image = self.images[indexPath.row]
        cell.imageView!.image = UIImage(named: image)
        cell.textLabel?.textColor = UIColor.blackColor()
        cell.textLabel!.font = UIFont(name: "Segoe UI", size: 18)
        cell.textLabel!.text = self.elements[indexPath.row]
        cell.backgroundColor = colorGreyBackground
        cell.detailTextLabel!.text = self.details![indexPath.row]
        cell.detailTextLabel!.font = UIFont(name: "Segoe UI", size: 18)
        cell.detailTextLabel!.textColor = colorGreen
        cell.textLabel!.adjustsFontSizeToFitWidth = true
        cell.detailTextLabel!.adjustsFontSizeToFitWidth = true
        cell.textLabel!.font = UIFont(name: "Segoe UI", size: 12)
        cell.tintColor = colorGreen
        return cell
    }
    
    //UIWebViewDelegate method
    func webViewDidFinishLoad(webView: UIWebView) {
        webView.backgroundColor = UIColor.clearColor()
        webView.opaque = false
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        if let QCVC = segue.destinationViewController as? QuestionContestViewController {
            // Pass the selected object to the new view controller.
            QCVC.contest = self.contest
        }
        
        if let scoreVC = segue.destinationViewController as? ScoreContestViewController {
            // Pass the selected object to the new view controller.
            scoreVC.score = self.contestHistory!.score
            scoreVC.emptyAnswers = self.contestHistory!.emptyAnswers
            scoreVC.succeeded = self.contestHistory!.succeeded
            scoreVC.numberOfQuestions = self.contestHistory!.numberOfQuestions
            scoreVC.contest = self.contest
            scoreVC.reviewMode = self.reviewMode
        }
    }


}
