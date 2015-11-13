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
    @IBOutlet weak var contestTitle: UILabel!
    @IBOutlet weak var launchButton: UIButton!
    @IBOutlet weak var contestTable: UITableView!
    @IBOutlet weak var contestContent: UIWebView!
    
    //properties
    var contest = Contest()
    var elements = ["Date","Durée","Réponse juste","Réponse vide","Réponse fausse"]
    var images = ["term","solo","true","empty","false"]
    var details: [String]?
    
    //app method
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
    
    //methods
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
    
    func loadData() {
        //formatting date
        let formatter = NSDateFormatter()
        formatter.dateFormat = "d/M/yy"
        let begin = formatter.stringFromDate(contest.begin)
        let end = formatter.stringFromDate(contest.end)
        //adding contest details to the table
        self.details = ["Du \(begin) au \(end)"]
        self.details!.append("\(contest.duration) minutes")
        self.details!.append(contest.goodAnswer.toStringPoints())
        self.details!.append(contest.noAnswer.toStringPoints())
        //loading content
        self.contestContent.loadHTMLString(contest.content, baseURL: nil)
        self.details!.append(contest.wrongAnswer.toStringPoints())
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        let QCVC = segue.destinationViewController as! QuestionContestViewController
        // Pass the selected object to the new view controller.
        QCVC.contest = self.contest
    }
    
    //@IBAction
    @IBAction func launch(sender: AnyObject) {
        // create alert controller
        let myAlert = UIAlertController(title: "Lancer le concours ?", message: "Vous devez disposer de \(self.contest.duration) minutes devant vous !", preferredStyle: UIAlertControllerStyle.Alert)
        myAlert.view.tintColor = colorGreen
        // add buttons
        myAlert.addAction(UIAlertAction(title: "NON", style: UIAlertActionStyle.Cancel, handler: nil))
        myAlert.addAction(UIAlertAction(title: "OUI", style: UIAlertActionStyle.Destructive, handler: { (action) -> Void in
            print("launching contest number \(self.contest.id)")
            self.launchButton.enabled = false
            self.launchButton.backgroundColor = colorDarkGrey
            self.launchButton.setTitle("Concours terminé", forState: UIControlState.Disabled)
            self.performSegueWithIdentifier("showContest", sender: self)
        }))
        // show the alert
        self.presentViewController(myAlert, animated: true, completion: nil)

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

}
