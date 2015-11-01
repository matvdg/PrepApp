//
//  ChoiceQuestionViewController.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 08/08/15.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import UIKit

class ChoiceQuestionViewController: UIViewController {
    
    var choiceFilter = 0 // 0=ALL 1=FAILED 2=SUCCEEDED 3=NEW 4=MARKED
    var delegate: ChoiceQuestionViewControllerDelegate?
    let realm = FactoryRealm.getRealm()
    var currentChapter: Chapter?

    
    //@IBOutlets
    @IBOutlet weak var all: UIButton!
    @IBOutlet weak var failed: UIButton!
    @IBOutlet weak var succeeded: UIButton!
    @IBOutlet weak var new: UIButton!
    @IBOutlet weak var marked: UIButton!
    
    //@IBActions
    @IBAction func filterAll(sender: AnyObject) {
        self.choiceFilter = 0
        self.delegate?.applyChoice(self.choiceFilter)
        self.dismissViewControllerAnimated(true, completion: nil )
        self.designButtons()
    }
    
    @IBAction func filterFailed(sender: AnyObject) {
        self.choiceFilter = 1
        self.delegate?.applyChoice(self.choiceFilter)
        self.dismissViewControllerAnimated(true, completion: nil )
        self.designButtons()
    }
    
    @IBAction func filterSucceeded(sender: AnyObject) {
        self.choiceFilter = 2
        self.delegate?.applyChoice(self.choiceFilter)
        self.dismissViewControllerAnimated(true, completion: nil )
        self.designButtons()
    }
    
    @IBAction func filterNew(sender: AnyObject) {
        self.choiceFilter = 3
        self.delegate?.applyChoice(self.choiceFilter)
        self.dismissViewControllerAnimated(true, completion: nil )
        self.designButtons()
    }
    
    @IBAction func filterMarked(sender: AnyObject) {
        self.choiceFilter = 4
        self.delegate?.applyChoice(self.choiceFilter)
        self.dismissViewControllerAnimated(true, completion: nil )
        self.designButtons()
    }
    
    //app method
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view!.backgroundColor = colorGreyBackground
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "logout", name: "failed", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "update", name: "update", object: nil)
        self.designButtons()
        self.checkChoiceAvailability()
    }
    
    //methods
    func logout() {
        print("logging out")
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
    
    private func designButtons() {
        all.backgroundColor = UIColor.whiteColor()
        all.setTitleColor(colorGreen, forState: .Normal)
        failed.backgroundColor = UIColor.whiteColor()
        failed.setTitleColor(colorGreen, forState: .Normal)
        succeeded.backgroundColor = UIColor.whiteColor()
        succeeded.setTitleColor(colorGreen, forState: .Normal)
        new.backgroundColor = UIColor.whiteColor()
        new.setTitleColor(colorGreen, forState: .Normal)
        marked.backgroundColor = UIColor.whiteColor()
        marked.setTitleColor(colorGreen, forState: .Normal)
        
        switch(self.choiceFilter) {
            case 0 : //All
                all.backgroundColor = colorGreen
                all.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            case 1 : //Failed
                failed.backgroundColor = colorGreen
                failed.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            case 2 : //Succeeded
                succeeded.backgroundColor = colorGreen
                succeeded.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            case 3 : //New
                new.backgroundColor = colorGreen
                new.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            case 4 : //Marked
                marked.backgroundColor = colorGreen
                marked.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            default :
                all.backgroundColor = colorGreen
                all.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        }
    }
    
    private func checkChoiceAvailability() {
        
        var tempQuestions = [Question]()
        var counter: Int = 0
        var available: Bool = false
        
        //fetching training questions
        var questionsRealm = realm.objects(Question).filter("chapter = %@ AND type = 0", currentChapter!)
        for question in questionsRealm {
            tempQuestions.append(question)
            counter++

        }
        
        //fetching solo questions already DONE
        questionsRealm = realm.objects(Question).filter("chapter = %@ AND type = 1", currentChapter!)
        for question in questionsRealm {
            if FactoryHistory.getHistory().isQuestionDone(question.id){
                tempQuestions.append(question)
                counter++
            }
        }
        
        //fetching duo questions already DONE
        questionsRealm = realm.objects(Question).filter("chapter = %@ AND type = 2", currentChapter!)
        for question in questionsRealm {
            if FactoryHistory.getHistory().isQuestionDone(question.id){
                tempQuestions.append(question)
                counter++
            }
            
        }
        self.all.setTitle("Toutes (\(counter))", forState: .Normal)
        
        //Now we check if each option it's available
        counter = 0
        
        //FAILED
        for question in tempQuestions {
            if FactoryHistory.getHistory().isQuestionFailed(question.id){
                available = true
                counter++
            }
        }
        if available {
            self.failed.enabled = true
        } else {
            self.failed.enabled = false
            failed.setTitleColor(UIColor.grayColor(), forState: .Normal)
        }
        self.failed.setTitle("Échouées (\(counter))", forState: .Normal)
        
        //SUCCEEDED
        available = false
        counter = 0
        for question in tempQuestions {
            if FactoryHistory.getHistory().isQuestionSuccessed(question.id){
                available = true
                counter++
            }
        }
        if available {
            self.succeeded.enabled = true
        } else {
            self.succeeded.enabled = false
            succeeded.setTitleColor(UIColor.grayColor(), forState: .Normal)
        }
        self.succeeded.setTitle("Réussies (\(counter))", forState: .Normal)
        
        //NEW
        available = false
        counter = 0
        for question in tempQuestions {
            if FactoryHistory.getHistory().isQuestionNewInTraining(question.id){
                available = true
                counter++
            }
        }
        if available {
            self.new.enabled = true
        } else {
            self.new.enabled = false
            new.setTitleColor(UIColor.grayColor(), forState: .Normal)
        }
        self.new.setTitle("Nouvelles (\(counter))", forState: .Normal)
        
        //MARKED
        available = false
        counter = 0
        for question in tempQuestions {
            if FactoryHistory.getHistory().isQuestionMarked(question.id){
                available = true
                counter++
            }
        }
        if available {
            self.marked.enabled = true
        } else {
            self.marked.enabled = false
            marked.setTitleColor(UIColor.grayColor(), forState: .Normal)
        }
        self.marked.setTitle("Marquées (\(counter))", forState: .Normal)
    }
    

}


