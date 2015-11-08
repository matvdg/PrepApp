//
//  ContestViewController.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 14/05/15.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import UIKit

class ContestViewController: UIViewController {

    @IBOutlet weak var noContestLabel: UILabel!
	@IBOutlet var menuButton: UIBarButtonItem!
	var timer = NSTimer()
    
	override func viewDidLoad() {
        //sync
        self.noContestLabel.hidden = true
        SwiftSpinner.show("Recherche de concours...")
        SwiftSpinner.setTitleFont(UIFont(name: "Segoe UI", size: 22.0))
        self.timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: Selector("stopAnimation"), userInfo: nil, repeats: false)
        
        SwiftSpinner.setTitleFont(UIFont(name: "Segoe UI", size: 22.0))
        FactoryHistory.getHistory().sync()
        self.view!.backgroundColor = colorGreyBackground
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
    
    func stopAnimation(){
        self.timer.invalidate()
        SwiftSpinner.hide()
        self.noContestLabel.hidden = false
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
        myAlert.addAction(UIAlertAction(title: "Plus tard", style: UIAlertActionStyle.Default, handler: nil))
        // add "update" button
        myAlert.addAction(UIAlertAction(title: "Mettre à jour maintenant", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        // show the alert
        self.presentViewController(myAlert, animated: true, completion: nil)
    }

}
