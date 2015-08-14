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

    @IBOutlet weak var seg: UISegmentedControl!
    
    @IBAction func choice(sender: AnyObject) {
        self.choiceFilter = self.seg.selectedSegmentIndex
        self.delegate?.applyChoice(self.choiceFilter)
        self.dismissViewControllerAnimated(true, completion: nil )
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        var attr = NSDictionary(object: UIFont(name: "Segoe UI", size: 10.0)!, forKey: NSFontAttributeName)
        self.seg.setTitleTextAttributes(attr as [NSObject : AnyObject], forState: .Normal)
        self.checkChoiceAvailability()
        self.seg.selectedSegmentIndex = self.choiceFilter
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
            if History.isQuestionDone(question.id){
                tempQuestions.append(question)
                counter++
            }
        }
        
        //fetching duo questions already DONE
        questionsRealm = realm.objects(Question).filter("chapter = %@ AND type = 2", currentChapter!)
        for question in questionsRealm {
            if History.isQuestionDone(question.id){
                tempQuestions.append(question)
                counter++
            }
            
        }
        self.seg.setTitle("Toutes (\(counter))", forSegmentAtIndex: 0)
        
        //Now we check if each option it's available
        counter = 0
        
        //FAILED
        for question in tempQuestions {
            if History.isQuestionFailed(question.id){
                available = true
                counter++
            }
        }
        if available {
            self.seg.setEnabled(true, forSegmentAtIndex: 1)
            self.seg.setTitle("Échouées (\(counter))", forSegmentAtIndex: 1)
        } else {
            self.seg.setEnabled(false, forSegmentAtIndex: 1)
            self.seg.setTitle("Échouées (\(counter))", forSegmentAtIndex: 1)
        }
        
        //SUCCEEDED
        available = false
        counter = 0
        for question in tempQuestions {
            if History.isQuestionSuccessed(question.id){
                available = true
                counter++
            }
        }
        if available {
            self.seg.setEnabled(true, forSegmentAtIndex: 2)
            self.seg.setTitle("Réussies (\(counter))", forSegmentAtIndex: 2)
        } else {
            self.seg.setEnabled(false, forSegmentAtIndex: 2)
            self.seg.setTitle("Réussies (\(counter))", forSegmentAtIndex: 2)
        }
        
        //NEW
        available = false
        counter = 0
        for question in tempQuestions {
            if History.isQuestionNewInTraining(question.id){
                available = true
                counter++
            }
        }
        if available {
            self.seg.setEnabled(true, forSegmentAtIndex: 3)
            self.seg.setTitle("Nouvelles (\(counter))", forSegmentAtIndex: 3)
        } else {
            self.seg.setEnabled(false, forSegmentAtIndex: 3)
            self.seg.setTitle("Nouvelles (\(counter))", forSegmentAtIndex: 3)
        }
        
        //MARKED
        available = false
        counter = 0
        for question in tempQuestions {
            if History.isQuestionMarked(question.id){
                available = true
                counter++
            }
        }
        if available {
            self.seg.setEnabled(true, forSegmentAtIndex: 4)
            self.seg.setTitle("Marquées (\(counter))", forSegmentAtIndex: 4)
        } else {
            self.seg.setEnabled(false, forSegmentAtIndex: 4)
            self.seg.setTitle("Marquées (\(counter))", forSegmentAtIndex: 4)
        }


    }
    

}


