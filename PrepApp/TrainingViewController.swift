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
    var image: String = ""
    var imageChi: String = ""
    var imagePhy: String = ""
    var imageBio: String = ""

    @IBOutlet weak var bioButton: UIButton!
    
    @IBOutlet weak var phyButton: UIButton!
    
    @IBOutlet weak var chiButton: UIButton!
    
	@IBOutlet var menuButton: UIBarButtonItem!
	
    @IBAction func bio(sender: AnyObject) {
        self.subject = realm.objects(Subject).filter("name='biologie'")[0]
        self.image = self.imageBio
        self.performSegueWithIdentifier("showChapters", sender: self)
    }

    @IBAction func phy(sender: AnyObject) {
        self.subject = realm.objects(Subject).filter("name='physique'")[0]
        self.image = self.imagePhy
        self.performSegueWithIdentifier("showChapters", sender: self)
    }
	
    @IBAction func chi(sender: AnyObject) {
        self.subject = realm.objects(Subject).filter("name='chimie'")[0]
        self.image = self.imageChi
        self.performSegueWithIdentifier("showChapters", sender: self)
    }
	
    override func viewDidLoad() {
        
        super.viewDidLoad()

		if self.revealViewController() != nil {
			menuButton.target = self.revealViewController()
			menuButton.action = "revealToggle:"
			self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
		}
		
		

    }
    
    override func viewDidAppear(animated: Bool) {
        self.designButton()
        if User.authenticated == false {
            NSUserDefaults.standardUserDefaults().removeObjectForKey("user")
            NSUserDefaults.standardUserDefaults().synchronize()
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
    }
    
    func designButton () {
        var random: Int = Int(rand()%5) + 1
        self.imageBio = "bio\(random)"
        self.bioButton.setImage(UIImage(named: self.imageBio), forState: UIControlState.Normal)
        random = Int(rand()%5) + 1
        self.imageChi = "chi\(random)"
        self.chiButton.setImage(UIImage(named: self.imageChi), forState: UIControlState.Normal)
        random = Int(rand()%5) + 1
        self.imagePhy = "phy\(random)"
        self.phyButton.setImage(UIImage(named: self.imagePhy), forState: UIControlState.Normal)
    }
    
    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        var chaptersVC = segue.destinationViewController as! ChaptersTableViewController
        // Pass the selected object to the new view controller.
        chaptersVC.subject = self.subject
        chaptersVC.image = self.image
    }
	
	

}
