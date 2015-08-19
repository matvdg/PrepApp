//
//  TrainingViewController.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 13/05/15.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import UIKit
import RealmSwift

class TrainingViewController: UIViewController {
    
    var subject: Subject?
    let realm = FactoryRealm.getRealm()

    @IBOutlet weak var bioButton: UIButton!
    
    @IBOutlet weak var phyButton: UIButton!
    
    @IBOutlet weak var chiButton: UIButton!
    
	@IBOutlet var menuButton: UIBarButtonItem!
	
    @IBAction func bio(sender: AnyObject) {
        self.subject = realm.objects(Subject).filter("name='biologie'")[0]
        self.performSegueWithIdentifier("showChapters", sender: self)
    }

    @IBAction func phy(sender: AnyObject) {
        self.subject = realm.objects(Subject).filter("name='physique'")[0]
        self.performSegueWithIdentifier("showChapters", sender: self)
    }
	
    @IBAction func chi(sender: AnyObject) {
        self.subject = realm.objects(Subject).filter("name='chimie'")[0]
        self.performSegueWithIdentifier("showChapters", sender: self)
    }
	
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Segoe UI", size: 20)!]
        self.navigationController!.navigationBar.tintColor = UIColor(red: 27/255, green: 129/255, blue: 94/255, alpha: 1)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "logout", name: "failed", object: nil)
        if self.revealViewController() != nil {
			menuButton.target = self.revealViewController()
			menuButton.action = "revealToggle:"
			self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
		}
    }
    
    func logout() {
        println("logging out")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        
        self.navigationController?.navigationBar.setBackgroundImage(nil, forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.translucent = true
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        var chaptersVC = segue.destinationViewController as! ChaptersTableViewController
        // Pass the selected object to the new view controller.
        chaptersVC.subject = self.subject
    }
	
	

}
