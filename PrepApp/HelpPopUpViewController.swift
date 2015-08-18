//
//  HelpPopUpViewController.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 04/08/15.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import UIKit

class HelpPopUpViewController: UIViewController {
    
    var help: String = ""
    var helpTopic: String = ""
    var helpPic: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "logout", name: "failed", object: nil)
        self.okButton.layer.cornerRadius = 6
        self.helpText.text = self.help
        self.helpText.textColor = UIColor.whiteColor()
        self.helpText.font = UIFont(name: "Segoe UI", size: 17)
        self.helpTitle.text = self.helpTopic
        self.helpText.setContentOffset(CGPointZero, animated: true)
        self.helpText.scrollRangeToVisible(NSRange(location: 0, length: 0))
        self.helpImage.image = UIImage(named: self.helpPic)
    }
    
    func logout() {
        println("logging out")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func dismiss(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBOutlet weak var helpText: UITextView!

    @IBOutlet weak var helpImage: UIImageView!
    
    @IBOutlet weak var helpTitle: UILabel!
    
    @IBOutlet weak var okButton: UIButton!

}
