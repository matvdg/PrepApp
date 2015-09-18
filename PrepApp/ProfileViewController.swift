//
//  ProfileViewController.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 14/05/15.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var profilePics = ["stats","podium","marked","credits"]
    var profileTopics = ["Statistiques","Classement","Questions marquées","Suggestions/remarques"]
    var selectedSection: Int = -1

    

	@IBOutlet var menuButton: UIBarButtonItem!
	
	override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Segoe UI", size: 20)!]
        self.navigationController!.navigationBar.tintColor = colorGreenAppButtons
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "logout", name: "failed", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "update", name: "update", object: nil)
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
    
    //UITableViewDataSource Methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.profilePics.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("profileSection", forIndexPath: indexPath) as! UITableViewCell
        var image = UIImage(named: self.profilePics[indexPath.row])
        cell.imageView?.image = image
        cell.textLabel?.textColor = UIColor.blackColor()
        cell.textLabel!.font = UIFont(name: "Segoe UI", size: 18)
        cell.textLabel!.text = self.profileTopics[indexPath.row]
        return cell
    }
    //UITableViewDelegate Methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selectedSection = indexPath.row
        if self.revealViewController() != nil {
            self.revealViewController().setFrontViewPosition(FrontViewPosition.Left, animated: true)
        }
        switch self.selectedSection { //"Statistiques","Classement","Questions marquées","Suggestions/remarques"
        case 0 : //Statistiques
           self.performSegueWithIdentifier("showStats", sender: self)
        case 1 : //Classement
            self.performSegueWithIdentifier("showLeaderboard", sender: self)
        case 2 : //Questions marquées
            self.performSegueWithIdentifier("showMarkedQuestions", sender: self)
        case 3 : //Suggestions/remarques
            self.performSegueWithIdentifier("showSuggestions", sender: self)
        default:
            println("nothing selected")
        }
        
    }
    
   

}
