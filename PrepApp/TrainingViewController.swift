//
//  TrainingViewController.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 13/05/15.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import UIKit

class TrainingViewController: UIViewController {
    
    var chapter: Chapter?

	@IBOutlet var menuButton: UIBarButtonItem!
	
    @IBAction func bio(sender: AnyObject) {
        
        self.performSegueWithIdentifier("showChapters", sender: self)
    }

    @IBAction func phy(sender: AnyObject) {
        self.performSegueWithIdentifier("showChapters", sender: self)
    }
	
    @IBAction func chi(sender: AnyObject) {
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
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        var chaptersVC = segue.destinationViewController as! ChaptersTableViewController
        // Pass the selected object to the new view controller.
//        if let indexPath = self.tableView.indexPathForSelectedRow() {
//            let selectedPhoto = photos[indexPath.row]
//            secondScene.currentPhoto = selectedPhoto
//        }
        
    }
	
	

}
