//
//  NewsfeedViewController.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 02/09/2015.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import UIKit

class NewsfeedViewController: UIViewController {
    
    var timer = NSTimer()

    @IBOutlet weak var newsfeedTable: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        SwiftSpinner.show("Mise à jour du flux...")
        SwiftSpinner.setTitleFont(UIFont(name: "Segoe UI", size: 22.0))
        self.timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: Selector("stopAnimation"), userInfo: nil, repeats: false)
        //sync
        FactoryHistory.getHistory().sync()
        self.view!.backgroundColor = colorGreyBackground
        self.navigationController!.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Segoe UI", size: 20)!]
        self.navigationController!.navigationBar.tintColor = colorGreen
        let swipeRight = UISwipeGestureRecognizer(target: self, action: "swiped:")
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRight)
    }
    
    func stopAnimation(){
        self.timer.invalidate()
        SwiftSpinner.hide()
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


}
