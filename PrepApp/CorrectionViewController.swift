//
//  CorrectionViewController.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 23/07/15.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import UIKit

class CorrectionViewController: UIViewController, UIWebViewDelegate {
    
    var correctionHTML = ""
    let baseUrl = NSURL(fileURLWithPath: FactorySync.path, isDirectory: true)!

    @IBOutlet weak var correction: UIWebView!
    @IBOutlet weak var dismissButton: UIButton!
    
    @IBAction func dismiss(sender: AnyObject) {
        Sound.playPage()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        webView.backgroundColor = UIColor.whiteColor()
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "logout", name: "failed", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "update", name: "update", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshCorrection", name: "portrait", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshCorrection", name: "landscape", object: nil)
        self.correction.opaque = false
        self.dismissButton.layer.cornerRadius = 6
        self.correction.delegate = self
        
        self.correction.loadHTMLString(self.correctionHTML, baseURL: self.baseUrl)
    }
    
    func refreshCorrection(){
        self.correction.loadHTMLString(self.correctionHTML, baseURL: self.baseUrl)
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
}
