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
    let baseUrl = NSURL(fileURLWithPath: Factory.path, isDirectory: true)!

    @IBOutlet weak var correction: UIWebView!
    @IBOutlet weak var dismissButton: UIButton!
    
    @IBAction func dismiss(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        webView.backgroundColor = UIColor(red: 236/255, green: 236/255, blue: 236/255, alpha: 1)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.correction.opaque = false
        self.dismissButton.layer.cornerRadius = 6
        self.correction.delegate = self
        
        self.correction.loadHTMLString(self.correctionHTML, baseURL: self.baseUrl)
    }
    
    override func viewDidAppear(animated: Bool) {
        if User.authenticated == false {
            NSUserDefaults.standardUserDefaults().removeObjectForKey("user")
            NSUserDefaults.standardUserDefaults().synchronize()
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }

}
