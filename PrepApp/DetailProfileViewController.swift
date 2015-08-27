//
//  DetailProfileViewController.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 25/08/15.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import UIKit

class DetailProfileViewController: UIViewController {
    
    var profileTopics = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = self.profileTopics
        self.navigationController!.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Segoe UI", size: 20)!]
        self.navigationController!.navigationBar.tintColor = colorGreenAppButtons
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
