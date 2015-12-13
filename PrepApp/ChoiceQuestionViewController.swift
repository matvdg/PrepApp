//
//  ChoiceQuestionViewController.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 08/08/15.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import UIKit

class ChoiceQuestionViewController: UIViewController {
    
    var choiceFilter = 0 // 0=ALL 1=FAILED 2=SUCCEEDED 3=NEW 4=MARKED 5=SOLO 6=DUO 7=CONTEST
    var delegate: ChoiceQuestionViewControllerDelegate?
    let realm = FactoryRealm.getRealm()
    var currentChapter: Chapter?

    
    //@IBOutlets
    @IBOutlet weak var all: UIButton!
    @IBOutlet weak var failed: UIButton!
    @IBOutlet weak var succeeded: UIButton!
    @IBOutlet weak var new: UIButton!
    @IBOutlet weak var marked: UIButton!
    @IBOutlet weak var fromSolo: UIButton!
    @IBOutlet weak var fromDuo: UIButton!
    @IBOutlet weak var fromContest: UIButton!
    
    //@IBActions
    @IBAction func filterAll(sender: AnyObject) {
        self.choiceFilter = 0
        self.delegate?.applyChoice(self.choiceFilter)
        self.designButtons()
        self.dismissViewControllerAnimated(true, completion: nil )
    }
    
    @IBAction func filterFailed(sender: AnyObject) {
        self.choiceFilter = 1
        self.delegate?.applyChoice(self.choiceFilter)
        self.designButtons()
        self.dismissViewControllerAnimated(true, completion: nil )
    }
    
    @IBAction func filterSucceeded(sender: AnyObject) {
        self.choiceFilter = 2
        self.delegate?.applyChoice(self.choiceFilter)
        self.designButtons()
        self.dismissViewControllerAnimated(true, completion: nil )
    }
    
    @IBAction func filterNew(sender: AnyObject) {
        self.choiceFilter = 3
        self.delegate?.applyChoice(self.choiceFilter)
        self.designButtons()
        self.dismissViewControllerAnimated(true, completion: nil )
    }
    
    @IBAction func filterMarked(sender: AnyObject) {
        self.choiceFilter = 4
        self.delegate?.applyChoice(self.choiceFilter)
        self.designButtons()
        self.dismissViewControllerAnimated(true, completion: nil )
    }
    
    @IBAction func filterSolo(sender: AnyObject) {
        self.choiceFilter = 5
        self.delegate?.applyChoice(self.choiceFilter)
        self.designButtons()
        self.dismissViewControllerAnimated(true, completion: nil )
    }
    
    @IBAction func filterDuo(sender: AnyObject) {
        self.choiceFilter = 6
        self.delegate?.applyChoice(self.choiceFilter)
        self.designButtons()
        self.dismissViewControllerAnimated(true, completion: nil )
    }
    
    @IBAction func filterContest(sender: AnyObject) {
        self.choiceFilter = 7
        self.delegate?.applyChoice(self.choiceFilter)
        self.designButtons()
        self.dismissViewControllerAnimated(true, completion: nil )
    }
    
    
    //app method
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view!.backgroundColor = Colors.greyBackground
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
        myAlert.view.tintColor = Colors.green
        // add "later" button
        myAlert.addAction(UIAlertAction(title: "Plus tard", style: UIAlertActionStyle.Cancel, handler: nil))
        // add "update" button
        myAlert.addAction(UIAlertAction(title: "Mettre à jour maintenant", style: UIAlertActionStyle.Destructive, handler: { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        // show the alert
        self.presentViewController(myAlert, animated: true, completion: nil)
    }
    
    private func designButtons() {
        all.backgroundColor = UIColor.whiteColor()
        all.setTitleColor(Colors.green, forState: .Normal)
        failed.backgroundColor = UIColor.whiteColor()
        failed.setTitleColor(Colors.green, forState: .Normal)
        succeeded.backgroundColor = UIColor.whiteColor()
        succeeded.setTitleColor(Colors.green, forState: .Normal)
        new.backgroundColor = UIColor.whiteColor()
        new.setTitleColor(Colors.green, forState: .Normal)
        marked.backgroundColor = UIColor.whiteColor()
        marked.setTitleColor(Colors.green, forState: .Normal)
        fromSolo.backgroundColor = UIColor.whiteColor()
        fromSolo.setTitleColor(Colors.green, forState: .Normal)
        fromDuo.backgroundColor = UIColor.whiteColor()
        fromDuo.setTitleColor(Colors.green, forState: .Normal)
        fromContest.backgroundColor = UIColor.whiteColor()
        fromContest.setTitleColor(Colors.green, forState: .Normal)
        
        switch(self.choiceFilter) {
            case 0 : //All
                all.backgroundColor = Colors.green
                all.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            case 1 : //Failed
                failed.backgroundColor = Colors.green
                failed.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            case 2 : //Succeeded
                succeeded.backgroundColor = Colors.green
                succeeded.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            case 3 : //New
                new.backgroundColor = Colors.green
                new.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            case 4 : //Marked
                marked.backgroundColor = Colors.green
                marked.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            case 5 : //fromSolo
                fromSolo.backgroundColor = Colors.green
                fromSolo.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            case 6 : //fromDuo
                fromDuo.backgroundColor = Colors.green
                fromDuo.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            case 7 : //fromContest
                fromContest.backgroundColor = Colors.green
                fromContest.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            default :
                all.backgroundColor = Colors.green
                all.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        }
    }
    
    private func checkChoiceAvailability() {
        
        var tempQuestions = [Question]()
        var counter: Int = 0
        
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
        
        //fetching contest questions already DONE
        questionsRealm = realm.objects(Question).filter("chapter = %@ AND type = 3", currentChapter!)
        for question in questionsRealm {
            if FactoryHistory.getHistory().isQuestionDone(question.id){
                tempQuestions.append(question)
                counter++
            }
        }
        self.all.setTitle("Toutes (\(counter))", forState: .Normal)
        
        
        //Now we check if each option it's available
        var available: Bool = false
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
            if FactoryHistory.getHistory().isQuestionNew(question.id){
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
        
        //SOLO
        available = false
        counter = 0
        for question in tempQuestions {
            if FactoryHistory.getHistory().isQuestionFromSolo(question.id){
                available = true
                counter++
            }
        }
        if available {
            self.fromSolo.enabled = true
        } else {
            self.fromSolo.enabled = false
            fromSolo.setTitleColor(UIColor.grayColor(), forState: .Normal)
        }
        self.fromSolo.setTitle("Défi solo (\(counter))", forState: .Normal)
        
        //DUO
        available = false
        counter = 0
        for question in tempQuestions {
            if FactoryHistory.getHistory().isQuestionFromDuo(question.id){
                available = true
                counter++
            }
        }
        if available {
            self.fromDuo.enabled = true
        } else {
            self.fromDuo.enabled = false
            fromDuo.setTitleColor(UIColor.grayColor(), forState: .Normal)
        }
        self.fromDuo.setTitle("Défi duo (\(counter))", forState: .Normal)

        
        //CONTEST
        available = false
        counter = 0
        for question in tempQuestions {
            if FactoryHistory.getHistory().isQuestionFromContest(question.id){
                available = true
                counter++
            }
        }
        if available {
            self.fromContest.enabled = true
        } else {
            self.fromContest.enabled = false
            fromContest.setTitleColor(UIColor.grayColor(), forState: .Normal)
        }
        self.fromContest.setTitle("Concours (\(counter))", forState: .Normal)


    }
    

}


