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
        Sound.playPage()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        webView.backgroundColor = UIColor.whiteColor()
            //UIColor(red: 236/255, green: 236/255, blue: 236/255, alpha: 1)
    }
    
    func logout() {
        println("logging out")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "logout", name: "failed", object: nil)
        self.correction.opaque = false
        self.dismissButton.layer.cornerRadius = 6
        self.correction.delegate = self
        
        self.correction.loadHTMLString(self.correctionHTML, baseURL: self.baseUrl)
    }

}
