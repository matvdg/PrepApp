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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.okButton.layer.cornerRadius = 6
        self.helpText.text = help
        self.helpText.textColor = UIColor.whiteColor()
        self.helpText.font = UIFont(name: "Segoe UI", size: 17)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismiss(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBOutlet weak var helpText: UITextView!

    @IBOutlet weak var okButton: UIButton!
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
