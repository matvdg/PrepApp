//
//  SoloViewController.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 14/05/15.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import UIKit

class SoloViewController: UIViewController {
	
	@IBOutlet var menuButton: UIBarButtonItem!
    var graph: UIButton?

    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Segoe UI", size: 20)!]
        self.navigationController!.navigationBar.tintColor = colorGreenAppButtons

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "logout", name: "failed", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "update", name: "update", object: nil)
		if self.revealViewController() != nil {
			menuButton.target = self.revealViewController()
			menuButton.action = "revealToggle:"
			self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
		}
        self.renderButtons()
    }

    func logout() {
        println("logging out")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func update() {
        // create alert controller
        let myAlert = UIAlertController(title: "Une mise à jour des questions est disponible", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        // add an "later" button
        myAlert.addAction(UIAlertAction(title: "Plus tard", style: UIAlertActionStyle.Default, handler: nil))
        // add an "update" button
        myAlert.addAction(UIAlertAction(title: "Mettre à jour maintenant", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        // show the alert
        self.presentViewController(myAlert, animated: true, completion: nil)
    }
    
    func renderButtons() {
        let size: CGFloat = 100
        //biologie
        self.graph = UIButton(frame: CGRectMake((self.view.bounds.width / 2) - (size/2) - (size/3), size, size, size))
        self.graph!.layer.cornerRadius = (size/2)
        self.graph!.alpha = 0.5
        self.graph!.layer.borderWidth = 5.0
        self.graph!.tintColor = UIColor.whiteColor()
        self.graph!.layer.borderColor = UIColor.whiteColor().CGColor
        self.graph!.backgroundColor = colorBio
        self.view.addSubview(self.graph!)
        self.graph!.addTarget(self, action: "selectBio", forControlEvents: UIControlEvents.TouchUpInside)
        //physique
        self.graph = UIButton(frame: CGRectMake((self.view.bounds.width / 2) - (size/2) + (size/3), size, size, size))
        self.graph!.layer.cornerRadius = (size/2)
        self.graph!.alpha = 0.5
        self.graph!.tintColor = UIColor.whiteColor()
        self.graph!.layer.borderWidth = 5.0
        self.graph!.layer.borderColor = UIColor.whiteColor().CGColor
        self.graph!.backgroundColor = colorPhy
        self.view.addSubview(self.graph!)
        self.graph!.addTarget(self, action: "selectPhy", forControlEvents: UIControlEvents.TouchUpInside)
        //chimie
        self.graph = UIButton(frame: CGRectMake((self.view.bounds.width / 2) - (size/2), size * 2 - (size/3), size, size))
        self.graph!.layer.cornerRadius = (size/2)
        self.graph!.layer.borderWidth = 5.0
        self.graph!.alpha = 0.5
        self.graph!.tintColor = UIColor.whiteColor()
        self.graph!.layer.borderColor = UIColor.whiteColor().CGColor
        self.graph!.backgroundColor = colorChi
        self.view.addSubview(self.graph!)
        self.graph!.addTarget(self, action: "selectChi", forControlEvents: UIControlEvents.TouchUpInside)

        
    }
    
    func selectBio(){
        println("Biologie")
    }
    func selectPhy(){
        println("Physique")
    }
    func selectChi(){
        println("Chimie")
    }
    func selectBioChi(){
        println("Biologie/Chimie")
    }
    func selectChiPhy(){
        println("Chimie/Physique")
    }
    func selectBioPhy(){
        println("Biologie/Physique")
    }
    func selectAll(){
        println("Biologie/Chimie/Physique")
    }

}
