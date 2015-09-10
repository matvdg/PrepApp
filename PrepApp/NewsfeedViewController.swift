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
        let url = NSURL(string: "http://www.prep-app.com")
        let request = NSURLRequest(URL: url!)
        self.newsWV.loadRequest(request)
        self.newsWV.scrollView.showsHorizontalScrollIndicator = false
        self.navigationController!.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Segoe UI", size: 20)!]
        self.navigationController!.navigationBar.tintColor = colorGreenAppButtons
        var swipeRight = UISwipeGestureRecognizer(target: self, action: "swiped:")
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRight)
    }
    
    @IBOutlet weak var newsWV: UIWebView!
    
    func swiped(gesture : UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            switch swipeGesture.direction {
            
                
            case UISwipeGestureRecognizerDirection.Right:
                self.navigationController?.popToRootViewControllerAnimated(true)
                
            default:
                println("other")
                break
                
            }
            
        }
    }


}
