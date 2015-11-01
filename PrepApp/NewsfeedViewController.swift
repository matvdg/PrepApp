//
//  NewsfeedViewController.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 02/09/2015.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import UIKit

class NewsfeedViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        //sync
        FactoryHistory.getHistory().sync()
        self.view!.backgroundColor = colorGreyBackground
        self.navigationController!.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Segoe UI", size: 20)!]
        self.navigationController!.navigationBar.tintColor = colorGreen
        let swipeRight = UISwipeGestureRecognizer(target: self, action: "swiped:")
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRight)
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
