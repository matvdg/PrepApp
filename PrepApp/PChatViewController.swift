//
//  PChatViewController.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 19/11/2015.
//  Copyright © 2015 PrepApp. All rights reserved.
//

import UIKit

class PChatViewController: UIViewController, UIWebViewDelegate {
    
        
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var chatWV: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //sync
        FactoryHistory.getHistory().sync()
        self.view!.backgroundColor = colorGreyBackground
        self.title = "P'Chat"
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "logout", name: "failed", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "update", name: "update", object: nil)
        self.navigationController!.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Segoe UI", size: 20)!]
        self.navigationController!.navigationBar.tintColor = colorGreen
        if self.revealViewController() != nil {
            self.menuButton.target = self.revealViewController()
            self.menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        self.loadChat()
        
    }
    
    func loadChat() {
        SwiftSpinner.setTitleFont(UIFont(name: "Segoe UI", size: 22.0))
        SwiftSpinner.show("Chargement de P'Chat...")
        let request = NSMutableURLRequest(URL: FactorySync.pchatUrl!)
        request.HTTPMethod = "POST"
        request.timeoutInterval = NSTimeInterval(5)
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData
        let postString = "name=\(User.currentUser!.nickname)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        self.chatWV.loadRequest(request)
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
        myAlert.addAction(UIAlertAction(title: "Plus tard", style: UIAlertActionStyle.Cancel, handler: nil))
        // add "update" button
        myAlert.addAction(UIAlertAction(title: "Mettre à jour maintenant", style: UIAlertActionStyle.Destructive, handler: { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        // show the alert
        self.presentViewController(myAlert, animated: true, completion: nil)
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        SwiftSpinner.hide()
    }
    
    
}