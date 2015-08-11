//
//  ChoiceQuestionViewController.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 08/08/15.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import UIKit

class ChoiceQuestionViewController: UIViewController {
    
    var choiceFilter = 0 // 0=ALL 1=FAILED 2=SUCCEEDED 3=NEW
    var delegate: ChoiceQuestionViewControllerDelegate?

    @IBOutlet weak var selectedChoice: UISegmentedControl!
    
    @IBAction func choice(sender: AnyObject) {
        self.choiceFilter = self.selectedChoice.selectedSegmentIndex
        self.delegate?.applyChoice(self.choiceFilter)
        self.dismissViewControllerAnimated(true, completion: nil )
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectedChoice.selectedSegmentIndex = self.choiceFilter
    }
    

}


