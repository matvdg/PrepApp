//
//  QuestionViewController.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 23/07/15.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import UIKit
import RealmSwift

class QuestionViewController: UIViewController {
    
    var currentChapter: Chapter?
    var currentQuestion: Int = 0
    let realm = FactoryRealm.getRealm()
    var questionsRealm: Results<Question>?
    var questions: [Question] = []
    var counter: Int = 0
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.wording.backgroundColor = UIColor.clearColor()
        self.designButtons()
        //debug  AND type = 0
        self.questionsRealm = realm.objects(Question).filter("chapter = %@", currentChapter!)
        for question in self.questionsRealm! {
            self.questions.append(question)
        }
        self.counter = self.questions.count
        //println(self.counter)
        //println(self.questions)
        self.loadQuestion()
        self.chapter.text = "Chapitre n° \(self.currentChapter!.number) : \(self.currentChapter!.name)"
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        if User.authenticated == false {
            NSUserDefaults.standardUserDefaults().removeObjectForKey("user")
            NSUserDefaults.standardUserDefaults().synchronize()
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBOutlet weak var submitButton: UIBarButtonItem!
    
    @IBOutlet weak var chapter: UILabel!
    
    @IBOutlet weak var question: UILabel!
    
    @IBOutlet weak var wording: UIWebView!
    
    @IBOutlet weak var buttonA: UIButton!
    @IBOutlet weak var buttonB: UIButton!
    @IBOutlet weak var buttonC: UIButton!
    @IBOutlet weak var buttonD: UIButton!
    @IBOutlet weak var buttonE: UIButton!
    @IBOutlet weak var buttonF: UIButton!
    
    @IBAction func answerA(sender: AnyObject) {
        
    }
    
    @IBAction func answerB(sender: AnyObject) {
    }
  
    @IBAction func answerC(sender: AnyObject) {
    }
    
    @IBAction func answerD(sender: AnyObject) {
    }
    
    @IBAction func answerE(sender: AnyObject) {
    }
    
    @IBAction func answerF(sender: AnyObject) {
    }

    @IBAction func previous(sender: AnyObject) {
        self.currentQuestion = (self.currentQuestion - 1) % self.counter
        self.currentQuestion = (self.currentQuestion < 0) ? (self.currentQuestion + self.counter):(self.currentQuestion)
        self.loadQuestion()
    }
    
    @IBAction func next(sender: AnyObject) {
        self.currentQuestion = (self.currentQuestion + 1) % self.counter
        self.loadQuestion()
    }
    
    
    @IBAction func submit(sender: AnyObject) {
    }
    
    
    func loadQuestion() {
        self.question.text = "Question n°\(self.currentQuestion+1)/\(self.counter)"
        var question = self.questions[self.currentQuestion]
        println(question.wording)
        let baseUrl = NSURL(fileURLWithPath: Factory.path, isDirectory: true)!
        self.wording.loadHTMLString((question.wording), baseURL: baseUrl)
        self.buttonA.setTitle((question.answerOne).htmlToString, forState: UIControlState.Normal)
        self.buttonB.setTitle((question.answerTwo).htmlToString, forState: UIControlState.Normal)
        self.buttonC.setTitle((question.answerThree).htmlToString, forState: UIControlState.Normal)
        self.buttonD.setTitle((question.answerFour).htmlToString, forState: UIControlState.Normal)
        self.buttonE.setTitle((question.answerFive).htmlToString, forState: UIControlState.Normal)
        self.buttonF.setTitle((question.answerSix).htmlToString, forState: UIControlState.Normal)

    }
    
    func designButtons () {
        buttonA.backgroundColor = UIColor.clearColor()
        buttonA.layer.cornerRadius = 5
        buttonA.layer.borderWidth = 1
        buttonA.layer.borderColor = UIColor.darkGrayColor().CGColor
        
        buttonB.backgroundColor = UIColor.clearColor()
        buttonB.layer.cornerRadius = 5
        buttonB.layer.borderWidth = 1
        buttonB.layer.borderColor = UIColor.darkGrayColor().CGColor
        
        buttonC.backgroundColor = UIColor.clearColor()
        buttonC.layer.cornerRadius = 5
        buttonC.layer.borderWidth = 1
        buttonC.layer.borderColor = UIColor.darkGrayColor().CGColor
        
        buttonD.backgroundColor = UIColor.clearColor()
        buttonD.layer.cornerRadius = 5
        buttonD.layer.borderWidth = 1
        buttonD.layer.borderColor = UIColor.darkGrayColor().CGColor
        
        buttonE.backgroundColor = UIColor.clearColor()
        buttonE.layer.cornerRadius = 5
        buttonE.layer.borderWidth = 1
        buttonE.layer.borderColor = UIColor.darkGrayColor().CGColor
        
        buttonF.backgroundColor = UIColor.clearColor()
        buttonF.layer.cornerRadius = 5
        buttonF.layer.borderWidth = 1
        buttonF.layer.borderColor = UIColor.darkGrayColor().CGColor
        
        

    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
