//
//  NewsViewController.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 08/11/2015.
//  Copyright © 2015 PrepApp. All rights reserved.
//

import UIKit

class NewsViewController: UIViewController {
    
    var newsfeed = [News]()
    var selected = 0

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var content: UITextView!
    @IBOutlet weak var details: UILabel!
    @IBOutlet weak var dismissButton: UIButton!
    @IBAction func dismiss(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dismissButton.layer.cornerRadius = 6.0
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "logout", name: "failed", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "update", name: "update", object: nil)
        self.loadNews()

    }
    
    func loadNews() {
        let news = self.newsfeed[self.selected]
        self.titleLabel.text = news.title
        //formatting date
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EEEE d MMMM yyy à H:mm"
        let dateInString = formatter.stringFromDate(news.date)
        self.details.text = "\(news.firstName) \(news.lastName) - \(dateInString)"
        self.details.font = UIFont(name: "Segoe UI", size: 16)
        self.content.text = news.content
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
