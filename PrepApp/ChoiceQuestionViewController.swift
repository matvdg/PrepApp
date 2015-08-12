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
    let realm = FactoryRealm.getRealm()
    var currentChapter: Chapter?

    @IBOutlet weak var selectedChoice: UISegmentedControl!
    
    @IBAction func choice(sender: AnyObject) {
        self.choiceFilter = self.selectedChoice.selectedSegmentIndex
        self.delegate?.applyChoice(self.choiceFilter)
        self.dismissViewControllerAnimated(true, completion: nil )
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.checkChoiceAvailability()
        self.selectedChoice.selectedSegmentIndex = self.choiceFilter
    }
    
    
    private func checkChoiceAvailability() {
        
        var tempQuestions = [Question]()
        //fetching training questions
        var questionsRealm = realm.objects(Question).filter("chapter = %@ AND type = 0", currentChapter!)
        for question in questionsRealm {
            tempQuestions.append(question)
        }
        
        //fetching solo questions already DONE
        questionsRealm = realm.objects(Question).filter("chapter = %@ AND type = 1", currentChapter!)
        for question in questionsRealm {
            if History.isQuestionDone(question.id){
                tempQuestions.append(question)
                println("ajout solo")
            }
        }
        
        //fetching duo questions already DONE
        questionsRealm = realm.objects(Question).filter("chapter = %@ AND type = 2", currentChapter!)
        for question in questionsRealm {
            if History.isQuestionDone(question.id){
                tempQuestions.append(question)
                println("ajout duo")
            }
            
        }
        //Now we check if each option it's available
        
        var available: Bool = false
        
        
        //FAILED
        for question in tempQuestions {
            if History.isQuestionFail(question.id){
                available = true            }
        }
        if available {
            self.selectedChoice.setEnabled(true, forSegmentAtIndex: 1)
        } else {
            self.selectedChoice.setEnabled(false, forSegmentAtIndex: 1)
        }
        
        //SUCCEEDED
        available = false
        for question in tempQuestions {
            if History.isQuestionSuccess(question.id){
                available = true
            }
        }
        if available {
            self.selectedChoice.setEnabled(true, forSegmentAtIndex: 2)
        } else {
            self.selectedChoice.setEnabled(false, forSegmentAtIndex: 2)
        }
        
        //NEW
        //TODO : implement a solo/duo history to fetch the solo/duo DONE in theses modes not in training mode and then filter here only the solo/duo questions done in this mode
        available = false
        for question in tempQuestions {
            if History.isQuestionDone(question.id){
                available = true
            }
        }
        if available {
            self.selectedChoice.setEnabled(true, forSegmentAtIndex: 3)
        } else {
            self.selectedChoice.setEnabled(false, forSegmentAtIndex: 3)
        }

    }
    

}


