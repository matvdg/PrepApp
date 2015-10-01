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
        if self.revealViewController() != nil {
            self.revealViewController().setFrontViewPosition(FrontViewPosition.Left, animated: true)
        }
    }

    @IBAction func phy(sender: AnyObject) {
        self.subject = realm.objects(Subject).filter("name='physique'")[0]
        self.performSegueWithIdentifier("showChapters", sender: self)
        if self.revealViewController() != nil {
            self.revealViewController().setFrontViewPosition(FrontViewPosition.Left, animated: true)
        }
    }
	
    @IBAction func chi(sender: AnyObject) {
        self.subject = realm.objects(Subject).filter("name='chimie'")[0]
        self.performSegueWithIdentifier("showChapters", sender: self)
        if self.revealViewController() != nil {
            self.revealViewController().setFrontViewPosition(FrontViewPosition.Left, animated: true)
        }
        
    }
	
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Segoe UI", size: 20)!]
        self.navigationController!.navigationBar.tintColor = colorGreenAppButtons
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "update", name: "update", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "logout", name: "failed", object: nil)
        if self.revealViewController() != nil {
			self.menuButton.target = self.revealViewController()
			self.menuButton.action = "revealToggle:"
			self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
		}
        self.bioButton.backgroundColor = colorBio
        self.phyButton.backgroundColor = colorPhy
        self.chiButton.backgroundColor = colorChe

        
    }
    
    func logout() {
        println("logging out")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func update() {
        // create alert controller
        let myAlert = UIAlertController(title: "Une mise à jour des questions est disponible", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        myAlert.view.tintColor = colorGreenAppButtons
        // add an "later" button
        myAlert.addAction(UIAlertAction(title: "Plus tard", style: UIAlertActionStyle.Default, handler: nil))
        // add an "update" button
        myAlert.addAction(UIAlertAction(title: "Mettre à jour maintenant", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        // show the alert
        self.presentViewController(myAlert, animated: true, completion: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController?.navigationBar.barTintColor = nil
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
