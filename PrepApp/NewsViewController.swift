//
//  NewsViewController.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 08/11/2015.
//  Copyright © 2015 PrepApp. All rights reserved.
//

import UIKit

class NewsViewController: UIViewController {
    
    var news = News()

    @IBOutlet weak var content: UITextView!
    @IBOutlet weak var details: UILabel!
    @IBAction func dismiss(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadNews()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "logout", name: "failed", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "update", name: "update", object: nil)
        if let _ = self.navigationController {
            self.navigationController!.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Segoe UI", size: 20)!]
            self.navigationController!.navigationBar.tintColor = Colors.greenLogo
        }
    }
    
    func loadNews() {
        self.title = self.news.title
        //formatting date
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EEEE d MMMM yyy à H:mm"
        let dateInString = formatter.stringFromDate(self.news.date)
        self.details.text = "\(self.news.firstName) \(self.news.lastName) - \(dateInString)"
        self.details.font = UIFont(name: "Segoe UI", size: 16)
        self.content.text = self.news.content
        self.content.textAlignment = NSTextAlignment.Justified
    }
    
    func logout() {
        print("logging out")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func update() {
        // create alert controller
        let myAlert = UIAlertController(title: "Une mise à jour des questions est disponible", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        myAlert.view.tintColor = Colors.green
        // add "later" button
        myAlert.addAction(UIAlertAction(title: "Plus tard", style: UIAlertActionStyle.Cancel, handler: nil))
        // add "update" button
        myAlert.addAction(UIAlertAction(title: "Mettre à jour maintenant", style: UIAlertActionStyle.Destructive, handler: { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        // show the alert
        self.presentViewController(myAlert, animated: true, completion: nil)
    }



}
