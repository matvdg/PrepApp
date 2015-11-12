//
//  ContestViewController.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 14/05/15.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import UIKit

class ContestViewController: UIViewController {

    //@IBOutlets
    @IBOutlet weak var noContestLabel: UILabel!
    @IBOutlet weak var contestTitle: UILabel!
    @IBOutlet weak var contestDate: UILabel!
    @IBOutlet weak var contestContent: UITextView!
    @IBOutlet weak var launchButton: UIButton!
    @IBOutlet weak var imageDate: UIImageView!
	@IBOutlet var menuButton: UIBarButtonItem!
    
    //properties
    var contest = Contest()
    
    //app method
	override func viewDidLoad() {
        self.loadData()
        //sync
        FactoryHistory.getHistory().sync()
        self.view!.backgroundColor = colorGreyBackground
        self.launchButton.layer.cornerRadius = 6
        super.viewDidLoad()
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
        //hiding objects
        self.noContestLabel.hidden = true
        self.contestTitle.hidden = true
        self.contestContent.hidden = true
        self.contestDate.hidden = true
        self.launchButton.hidden = true
        self.imageDate.hidden = true
        
        //looking for contest
        SwiftSpinner.show("Recherche de concours...")
        SwiftSpinner.setTitleFont(UIFont(name: "Segoe UI", size: 22.0))
        FactorySync.getContestManager().getContests { (answer) -> Void in
            SwiftSpinner.hide()
            if let contest = answer {
                self.contest = contest
                self.title = "Concours n°\(contest.id)"
                self.contestTitle.text = contest.name
                self.contestContent.text = contest.content.html2String
                self.contestContent.font = UIFont(name: "Segoe UI", size: 16.0)
                self.contestContent.textAlignment = NSTextAlignment.Justified
                //formatting date
                let formatter = NSDateFormatter()
                formatter.dateFormat = "d/M/yy"
                let begin = formatter.stringFromDate(contest.begin)
                let end = formatter.stringFromDate(contest.end)
                self.contestDate.text = "Du \(begin) au \(end)"
                self.contestTitle.hidden = false
                self.contestContent.hidden = false
                self.contestDate.hidden = false
                self.launchButton.hidden = false
                self.imageDate.hidden = false
            } else {
                self.noContestLabel.hidden = false
                self.contestTitle.hidden = true
                self.contestContent.hidden = true
                self.contestDate.hidden = true
                self.launchButton.hidden = true
                self.imageDate.hidden = true
            }
        }
        

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
            self.performSegueWithIdentifier("showContest", sender: self)
        }))
        // show the alert
        self.presentViewController(myAlert, animated: true, completion: nil)

    }

}
