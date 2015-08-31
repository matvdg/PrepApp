//
//  SoloViewController.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 14/05/15.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import UIKit

class SoloViewController: UIViewController {
	
    
    var button: UIButton?
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

    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    func renderButtons() {
        let size: CGFloat = 185
        let yOffset: CGFloat = 80
        
        //biologie
        self.button = UIButton(frame: CGRectMake((self.view.bounds.width / 2) - (size/2) - (size/3), yOffset, size, size))
        self.button!.layer.cornerRadius = (size/2)
        self.button!.alpha = 0.1
        self.view.addSubview(self.button!)
        self.button!.addTarget(self, action: "selectBio", forControlEvents: UIControlEvents.TouchUpInside)
        
        //physique
        self.button = UIButton(frame: CGRectMake((self.view.bounds.width / 2) - (size/2) + (size/3), yOffset, size, size))
        self.button!.layer.cornerRadius = (size/2)
        self.button!.alpha = 0.1
        self.view.addSubview(self.button!)
        self.button!.addTarget(self, action: "selectPhy", forControlEvents: UIControlEvents.TouchUpInside)
        
        //chimie
        self.button = UIButton(frame: CGRectMake((self.view.bounds.width / 2) - (size/2), size - (size/3) + yOffset, size, size))
        self.button!.layer.cornerRadius = (size/2)
        self.button!.alpha = 0.1
        self.view.addSubview(self.button!)
        self.button!.addTarget(self, action: "selectChi", forControlEvents: UIControlEvents.TouchUpInside)
        
        //bio/phy
        self.button = UIButton(frame: CGRectMake((self.view.bounds.width / 2) - (size/6), size/2 - (size/3) + yOffset, size/3 , size/3 + 40))
        self.button!.layer.cornerRadius = (size/6)
        self.button!.alpha = 0.1
        self.view.addSubview(self.button!)
        self.button!.addTarget(self, action: "selectBioPhy", forControlEvents: UIControlEvents.TouchUpInside)
        
        //bio/chi
        self.button = UIButton(frame: CGRectMake((self.view.bounds.width / 2) - (size/6) - (size/2), size - (size/4) + yOffset, size/3 + 40, size/3))
        self.button!.layer.cornerRadius = (size/6)
        self.button!.alpha = 0.1
        self.view.addSubview(self.button!)
        self.button!.addTarget(self, action: "selectBioChi", forControlEvents: UIControlEvents.TouchUpInside)
        
        //chi/phy
        self.button = UIButton(frame: CGRectMake((self.view.bounds.width / 2) - (size/6) + 60, size - (size/4) + yOffset, size/3 + 40, size/3))
        self.button!.layer.cornerRadius = (size/6)
        self.button!.alpha = 0.1
        self.view.addSubview(self.button!)
        self.button!.addTarget(self, action: "selectChiPhy", forControlEvents: UIControlEvents.TouchUpInside)
        
        //all
        self.button = UIButton(frame: CGRectMake((self.view.bounds.width / 2) - (size/4), size - (size/2) + yOffset, size/2, size/2))
        self.button!.layer.cornerRadius = (size/4)
        self.button!.alpha = 0.1
        self.view.addSubview(self.button!)
        self.button!.addTarget(self, action: "selectAll", forControlEvents: UIControlEvents.TouchUpInside)



        
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
    
    func selectChi(){
        self.label.text = "Défi Chimie"
        self.choice = .chemistry
        println("Chimie")
        self.trigram.image = UIImage(named: "trichi")
    }
    
    func selectBioChi(){
        self.label.text = "Défi Biologie/Chimie"
        self.choice = .bioChi
        println("Biologie/Chimie")
        self.trigram.image = UIImage(named: "tribiochi")
    }
    
    func selectChiPhy(){
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
