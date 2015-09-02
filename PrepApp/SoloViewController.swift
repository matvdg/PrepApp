//
//  SoloViewController.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 14/05/15.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import UIKit

class SoloViewController: UIViewController {
	
    
    var buttonBio: UIButton?
    var buttonPhy: UIButton?
    var buttonChe: UIButton?
    var buttonBioPhy: UIButton?
    var buttonBioChe: UIButton?
    var buttonChePhy: UIButton?
    var buttonAll: UIButton?
    
    enum choices {
        case none
        case biology
        case physics
        case chemistry
        case bioPhy
        case bioChi
        case chiPhy
        case all
    }
    var choice = choices.none
    
	@IBOutlet var menuButton: UIBarButtonItem!
    @IBOutlet weak var trigram: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var buttonChallenge: UIButton!
    
    @IBAction func runChallenge(sender: AnyObject) {
        if self.choice == .none {
            // create alert controller
            let myAlert = UIAlertController(title: "Veuillez toucher le trigramme pour choisir au moins une matière", message: "Vous pouvez également choisir des combinaisons de deux ou trois matières", preferredStyle: UIAlertControllerStyle.Alert)
            // add an "OK" button
            myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            // show the alert
            self.presentViewController(myAlert, animated: true, completion: nil)

        } else {
            println("go!")
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        let value = UIInterfaceOrientation.Portrait.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refresh", name: "portrait", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refresh", name: "landscape", object: nil)

        self.view.backgroundColor = colorGreyBackgound
        self.navigationController!.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Segoe UI", size: 20)!]
        self.navigationController!.navigationBar.tintColor = colorGreenAppButtons

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "logout", name: "failed", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "update", name: "update", object: nil)
		if self.revealViewController() != nil {
			menuButton.target = self.revealViewController()
			menuButton.action = "revealToggle:"
			self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
		}
        self.trigram.image = UIImage(named: "triunselected")
        self.buttonChallenge.layer.cornerRadius = 6
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
    
    func refresh() {
        println("refreshing")
        self.buttonChePhy?.removeFromSuperview()
        self.buttonPhy?.removeFromSuperview()
        self.buttonChe?.removeFromSuperview()
        self.buttonBioPhy?.removeFromSuperview()
        self.buttonBioChe?.removeFromSuperview()
        self.buttonBio?.removeFromSuperview()
        self.buttonAll?.removeFromSuperview()
        self.renderButtons()
    }
    
    
    
    func renderButtons() {
        let size: CGFloat = 185
        
        //biologie
        self.buttonBio = UIButton(frame: CGRectMake((self.view.bounds.width / 2) - (size/2) - (size/3), (self.view.bounds.height / 2) - (size/2) - (size/3), size, size))
        self.buttonBio!.layer.cornerRadius = (size/2)
        self.buttonBio!.alpha = 0.9
        //self.buttonBio?.backgroundColor = UIColor.greenColor()
        self.view.addSubview(self.buttonBio!)
        self.buttonBio!.addTarget(self, action: "selectBio", forControlEvents: UIControlEvents.TouchUpInside)
        
        //physique
        self.buttonPhy = UIButton(frame: CGRectMake((self.view.bounds.width / 2) - (size/2) + (size/3), (self.view.bounds.height / 2) - (size/2) - (size/3), size, size))
        self.buttonPhy!.layer.cornerRadius = (size/2)
        self.buttonPhy!.alpha = 0.9
        //self.buttonPhy?.backgroundColor = UIColor.redColor()
        self.view.addSubview(self.buttonPhy!)
        self.buttonPhy!.addTarget(self, action: "selectPhy", forControlEvents: UIControlEvents.TouchUpInside)
        
        //chimie
        self.buttonChe = UIButton(frame: CGRectMake((self.view.bounds.width / 2) - (size/2), (self.view.bounds.height / 2) - (size/2)  + (size/3), size, size))
        self.buttonChe!.layer.cornerRadius = (size/2)
        self.buttonChe!.alpha = 0.9
        //self.buttonChe?.backgroundColor = UIColor.blueColor()
        self.view.addSubview(self.buttonChe!)
        self.buttonChe!.addTarget(self, action: "selectChe", forControlEvents: UIControlEvents.TouchUpInside)
        
        //bio/phy
        self.buttonBioPhy = UIButton(frame: CGRectMake((self.view.bounds.width / 2) - (size/6), (self.view.bounds.height / 2) - (size/2) - (size/4), size/3 , size/3 + 40))
        self.buttonBioPhy!.layer.cornerRadius = (size/6)
        self.buttonBioPhy!.alpha = 0.9
        //self.buttonBioPhy?.backgroundColor = UIColor.yellowColor()
        self.view.addSubview(self.buttonBioPhy!)
        self.buttonBioPhy!.addTarget(self, action: "selectBioPhy", forControlEvents: UIControlEvents.TouchUpInside)
        
        //bio/chi
        self.buttonBioChe = UIButton(frame: CGRectMake((self.view.bounds.width / 2) - (size/6) - (size/2),  (self.view.bounds.height / 2) - (size/5), size/3 + 40, size/3))
        self.buttonBioChe!.layer.cornerRadius = (size/6)
        self.buttonBioChe!.alpha = 0.9
        //self.buttonBioChe?.backgroundColor = UIColor.brownColor()
        self.view.addSubview(self.buttonBioChe!)
        self.buttonBioChe!.addTarget(self, action: "selectBioChe", forControlEvents: UIControlEvents.TouchUpInside)
        
        //che/phy
        self.buttonChePhy = UIButton(frame: CGRectMake((self.view.bounds.width / 2) - (size/6) + 60, (self.view.bounds.height / 2) - (size/5), size/3 + 40, size/3))
        self.buttonChePhy!.layer.cornerRadius = (size/6)
        self.buttonChePhy!.alpha = 0.9
        //self.buttonChePhy?.backgroundColor = UIColor.purpleColor()
        self.view.addSubview(self.buttonChePhy!)
        self.buttonChePhy!.addTarget(self, action: "selectChePhy", forControlEvents: UIControlEvents.TouchUpInside)
        
        //all
        self.buttonAll = UIButton(frame: CGRectMake((self.view.bounds.width / 2) - (size/4), (self.view.bounds.height / 2) - (size/3), size/2, size/2))
        self.buttonAll!.layer.cornerRadius = (size/4)
        self.buttonAll!.alpha = 0.9
        //self.buttonAll?.backgroundColor = UIColor.darkGrayColor()
        self.view.addSubview(self.buttonAll!)
        self.buttonAll!.addTarget(self, action: "selectAll", forControlEvents: UIControlEvents.TouchUpInside)



        
    }
    
    func selectBio(){
        self.label.text = "Défi Biologie"
        self.choice = .biology
        println("Biologie")
        self.trigram.image = UIImage(named: "tribio")
    }
    
    func selectPhy(){
        self.label.text = "Défi Physique"
        self.choice = .physics
        println("Physique")
        self.trigram.image = UIImage(named: "triphy")
    }
    
    func selectChe(){
        self.label.text = "Défi Chimie"
        self.choice = .chemistry
        println("Chimie")
        self.trigram.image = UIImage(named: "trichi")
    }
    
    func selectBioChe(){
        self.label.text = "Défi Biologie/Chimie"
        self.choice = .bioChi
        println("Biologie/Chimie")
        self.trigram.image = UIImage(named: "tribiochi")
    }
    
    func selectChePhy(){
        self.label.text = "Défi Chimie/Physique"
        self.choice = .chiPhy
        println("Chimie/Physique")
        self.trigram.image = UIImage(named: "trichiphy")
    }
    
    func selectBioPhy(){
        self.label.text = "Défi Biologie/Physique"
        self.choice = .bioPhy
        println("Biologie/Physique")
        self.trigram.image = UIImage(named: "tribiophy")
    }
    
    func selectAll(){
        self.label.text = "Défi Biologie/Chimie/Physique"
        self.choice = .all
        println("Biologie/Chimie/Physique")
        self.trigram.image = UIImage(named: "triall")
    }

}
