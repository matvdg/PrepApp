//
//  NewsfeedViewController.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 02/09/2015.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import UIKit

class NewsfeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIViewControllerPreviewingDelegate {
    
    var timer = NSTimer()
    var newsfeed = [News]()
    var selected = 0
    var pullToRefresh =  UIRefreshControl()

    @IBOutlet weak var newsfeedTable: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        if( traitCollection.forceTouchCapability == .Available){
            registerForPreviewingWithDelegate(self, sourceView: self.newsfeedTable)
        }
        self.pullToRefresh.tintColor = colorGreen
        self.pullToRefresh.attributedTitle = NSAttributedString(string: "▼ Glisser vers le bas pour actualiser le fil d'actualités ▼")
        self.pullToRefresh.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.newsfeedTable?.addSubview(pullToRefresh)
        //sync newsfeed
        SwiftSpinner.show("Mise à jour du flux...")
        SwiftSpinner.setTitleFont(UIFont(name: "Segoe UI", size: 22.0))
        FactorySync.getNewsfeedManager().getNewsfeed { (newsfeed) -> Void in
            SwiftSpinner.hide()
            self.newsfeed = newsfeed
            self.newsfeedTable.reloadData()
        }
        //sync history
        FactoryHistory.getHistory().sync()
        self.view!.backgroundColor = colorGreyBackground
        self.navigationController!.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Segoe UI", size: 20)!]
        self.navigationController!.navigationBar.tintColor = colorGreen
        self.title = "Fil d'actualités"
        let swipeRight = UISwipeGestureRecognizer(target: self, action: "swiped:")
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRight)
        //notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "logout", name: "failed", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "update", name: "update", object: nil)
    }
    
    func swiped(gesture : UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.Right:
                self.navigationController?.popToRootViewControllerAnimated(true)
            default:
                print("other")
                break
            }
        }
    }
    
    func refresh(sender:AnyObject) {
        FactorySync.getNewsfeedManager().getNewsfeed { (newsfeed) -> Void in
            // tell refresh control it can stop showing up now
            if self.pullToRefresh.refreshing
            {
                self.pullToRefresh.endRefreshing()
            }
            self.newsfeed = newsfeed
            self.newsfeedTable.reloadData()
        }
    }
    
    // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.newsfeed.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("news", forIndexPath: indexPath)
        let news = self.newsfeed[indexPath.row]
        cell.textLabel!.text = news.title
        cell.textLabel?.textColor = UIColor.blackColor()
        cell.backgroundColor = colorGreyBackground
        cell.textLabel!.adjustsFontSizeToFitWidth = false
        cell.textLabel!.adjustsFontSizeToFitWidth = true
        cell.detailTextLabel!.font = UIFont(name: "Segoe UI", size: 12)
        cell.detailTextLabel!.textColor = colorGreen
        cell.detailTextLabel!.adjustsFontSizeToFitWidth = false
        cell.tintColor = colorGreen
        //formatting date
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EEEE d MMMM yyy à H:mm"
        let dateInString = formatter.stringFromDate(news.date)
        cell.detailTextLabel!.text = "\(news.firstName) \(news.lastName) - \(dateInString)"
        cell.textLabel!.font = UIFont(name: "Segoe UI", size: 16)
        cell.tintColor = colorGreen
        return cell
        
    }
    
    //UITableViewDelegate Methods
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let newsVC = segue.destinationViewController as! NewsViewController
        // Pass the selected object to the new view controller.
        newsVC.newsfeed = self.newsfeed
        newsVC.selected = self.newsfeedTable.indexPathForSelectedRow!.row
    }
    
    func logout() {
        ///called when touchID failed, authenticated = false
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
    
    //peek&pop
    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        let indexPath = self.newsfeedTable!.indexPathForRowAtPoint(location)
        let cell = self.newsfeedTable!.cellForRowAtIndexPath(indexPath!)
        let newsVC = storyboard?.instantiateViewControllerWithIdentifier("NewsVC") as? NewsViewController
        newsVC!.selected = indexPath!.row
        newsVC!.newsfeed = self.newsfeed
        newsVC!.hideButton = true
        newsVC!.preferredContentSize = CGSize(width: 0.0, height: 300)
        previewingContext.sourceRect = cell!.frame
        return newsVC
    }
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
        self.showViewController(viewControllerToCommit, sender: self)
    }

}
