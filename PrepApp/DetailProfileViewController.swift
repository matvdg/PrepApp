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
    

    
}
