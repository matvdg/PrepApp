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
    
    let realm = FactoryRealm.getRealm()
    
    enum choices:Int {
        case none = 0, biology, physics, chemistry, bioPhy, bioChe, chePhy, all
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
            myAlert.view.tintColor = colorGreen
            // add an "OK" button
            myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            // show the alert
            self.presentViewController(myAlert, animated: true, completion: nil)

        } else {
            if self.checkQuestions() {
                // create alert controller
                let myAlert = UIAlertController(title: "Lancer le défi ?", message: "Vous devez disposer de 20 minutes. Un défi lancé ne peut être mis en pause et un défi abandonné fait perdre des points !", preferredStyle: UIAlertControllerStyle.Alert)
                myAlert.view.tintColor = colorGreen
                // add buttons
                myAlert.addAction(UIAlertAction(title: "OUI", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                    self.performSegueWithIdentifier("showQuestionsSolo", sender: self)
                }))
                myAlert.addAction(UIAlertAction(title: "NON", style: UIAlertActionStyle.Default, handler: nil))
                // show the alert
                self.presentViewController(myAlert, animated: true, completion: nil)
            } else {
                // create alert controller
                let myAlert = UIAlertController(title: "Ce défi n'est plus disponible pour le moment", message: "Revenez plus tard pour de nouvelles questions ou allez dans le mode entraînement pour refaire les questions déjà vues.", preferredStyle: UIAlertControllerStyle.Alert)
                myAlert.view.tintColor = colorGreen
                // add an "OK" button
                myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                // show the alert
                self.presentViewController(myAlert, animated: true, completion: nil)
 
            }
            
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        let value = UIInterfaceOrientation.Portrait.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")
        //syncHistory
        FactoryHistory.getHistory().sync()
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //sync
        FactoryHistory.getHistory().sync()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refresh", name: "portrait", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refresh", name: "landscape", object: nil)

        self.view.backgroundColor = colorGreyBackground
        self.navigationController!.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Segoe UI", size: 20)!]
        self.navigationController!.navigationBar.tintColor = colorGreen

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "logout", name: "failed", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "update", name: "update", object: nil)
		if self.revealViewController() != nil {
			self.menuButton.target = self.revealViewController()
			self.menuButton.action = "revealToggle:"
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
        myAlert.view.tintColor = colorGreen
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
        self.trigram.layer.zPosition = 1
        self.label.layer.zPosition = 2
        self.buttonChallenge.layer.zPosition = 3
        //biology
        self.buttonBio = UIButton(frame: CGRectMake((self.view.bounds.width / 2) - (size/2) - (size/3), (self.view.bounds.height / 2) - (size/2) - (size/3), size, size))
        self.buttonBio!.layer.cornerRadius = (size/2)
        self.buttonBio!.alpha = 0.9
        //self.buttonBio?.backgroundColor = UIColor.greenColor()
        self.view.addSubview(self.buttonBio!)
        self.buttonBio!.addTarget(self, action: "selectBio", forControlEvents: UIControlEvents.TouchUpInside)
        
        //physics
        self.buttonPhy = UIButton(frame: CGRectMake((self.view.bounds.width / 2) - (size/2) + (size/3), (self.view.bounds.height / 2) - (size/2) - (size/3), size, size))
        self.buttonPhy!.layer.cornerRadius = (size/2)
        self.buttonPhy!.alpha = 0.9
        //self.buttonPhy?.backgroundColor = UIColor.redColor()
        self.view.addSubview(self.buttonPhy!)
        self.buttonPhy!.addTarget(self, action: "selectPhy", forControlEvents: UIControlEvents.TouchUpInside)
        
        //chemistry
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
        
        //bio/che
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
        self.choice = .bioChe
        println("Biologie/Chimie")
        self.trigram.image = UIImage(named: "tribiochi")
    }
    
    func selectChePhy(){
        self.label.text = "Défi Chimie/Physique"
        self.choice = .chePhy
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
    
    func checkQuestions() -> Bool {
        
        var result = false
        
        var tempQuestions = [Question]()
        //fetching solo questions NEVER DONE
        var questionsRealm = realm.objects(Question).filter("type = 1")
        for question in questionsRealm {
            if FactoryHistory.getHistory().isQuestionNew(question.id){
                tempQuestions.append(question)
            }
        }
        
        //now applying the trigram choice choosen by user 1 biology, 2 physics, 3 chemistry, 4 bioPhy, 5 bioChe, 6 chePhy, 7 all
        var counter = 0
        switch self.choice.rawValue {
            
        case 1: //biology
            
            for question in tempQuestions {
                if question.chapter!.subject!.id == 1 && counter < 12 {
                    counter++
                }
            }
            if counter == 12 {
                result = true
            }
        case 2: //physics
            for question in tempQuestions {
                if question.chapter!.subject!.id == 2 && counter < 6 {
                    counter++
                }
            }
            if counter == 6 {
                result = true
            }
            
        case 3: //chemistry
            for question in tempQuestions {
                if question.chapter!.subject!.id == 3 && counter < 6 {
                    counter++
                }
            }
            if counter == 6 {
                result = true
            }
            
        case 4: //bioPhy
            for question in tempQuestions {
                if question.chapter!.subject!.id == 1 && counter < 8 {
                    counter++
                }
            }
            if counter == 8 {
                for question in tempQuestions {
                    if question.chapter!.subject!.id == 2 && counter < 11 {
                        counter++
                    }
                }
                if counter == 11 {
                    result = true
                }

            }
            
        case 5: //bioChe
            for question in tempQuestions {
                if question.chapter!.subject!.id == 1 && counter < 8 {
                    counter++
                }
            }
            if counter == 8 {
                for question in tempQuestions {
                    if question.chapter!.subject!.id == 3 && counter < 11 {
                        counter++
                    }
                }
                if counter == 11 {
                    result = true
                }

            }
            
        case 6: //chePhy
            for question in tempQuestions {
                if question.chapter!.subject!.id == 2 && counter < 4 {
                    counter++
                }
            }
            if counter == 4 {
                for question in tempQuestions {
                    if question.chapter!.subject!.id == 3 && counter < 6 {
                        counter++
                    }
                }
                if counter == 6 {
                    result = true
                }

            }
            
        case 7: //all
            for question in tempQuestions {
                if question.chapter!.subject!.id == 1 && counter < 6 {
                    counter++
                }
            }
            if counter == 6 {
                for question in tempQuestions {
                    if question.chapter!.subject!.id == 2 && counter < 8 {
                        counter++
                    }
                }
                if counter == 8 {
                    for question in tempQuestions {
                        if question.chapter!.subject!.id == 3 && counter < 9 {
                            counter++
                        }
                    }
                    if counter == 9 {
                        result = true
                    }
                }
                

            }
            
        default:
            println("default")
        }
        
        return result
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        var QSVC = segue.destinationViewController as! QuestionSoloViewController
        // Pass the selected object to the new view controller.
        QSVC.choice = self.choice.rawValue
    }


}
