//
//  QuestionViewController.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 23/07/15.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import UIKit
import RealmSwift

class QuestionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPopoverPresentationControllerDelegate, UIWebViewDelegate {
    
    
    let realm = FactoryRealm.getRealm()
    var questionsRealm: Results<Question>?
    var questions: [Question] = []
    var currentChapter: Chapter?
    var currentSubject: Subject?
    var currentNumber: Int = 0
    var currentQuestion: Question?
    var counter: Int = 0
    var wording = UIWebView()
    var answers = UITableView()
    var didLoadWording = false
    var sizeAnswerCells: [CGFloat] = []
    var numberOfAnswers = 0
    
    let baseUrl = NSURL(fileURLWithPath: Factory.path, isDirectory: true)!
    
    
    var scrollView: UIScrollView!
    
    
    //let goodAnswers = self.questions[self.currentNumber].goodAnswers.componentsSeparatedByString(",").count

    override func viewDidLoad() {
        
        //display the subject
        self.numberOfAnswers = 0
        self.sizeAnswerCells.removeAll(keepCapacity: true)
        self.counter = 0
        self.title = self.currentSubject!.name.uppercaseString
        self.navigationController!.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Segoe UI", size: 20)!]
        //display the chapter
        self.chapter.text = "Chapitre n° \(self.currentChapter!.number) : \(self.currentChapter!.name)"
        //load the questions
        self.loadQuestions()
        //display the first question
        self.loadQuestion()
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        if User.authenticated == false {
            NSUserDefaults.standardUserDefaults().removeObjectForKey("user")
            NSUserDefaults.standardUserDefaults().synchronize()
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBOutlet weak var chapter: UILabel!
    
    @IBOutlet weak var questionNumber: UIBarButtonItem!
    
    @IBOutlet weak var calc: UIBarButtonItem!

    @IBAction func previous(sender: AnyObject) {
        self.sizeAnswerCells.removeAll(keepCapacity: true)
        self.currentNumber = (self.currentNumber - 1) % self.counter
        self.currentNumber = (self.currentNumber < 0) ? (self.currentNumber + self.counter):(self.currentNumber)
        self.loadQuestion()
    }
    
    @IBAction func next(sender: AnyObject) {
        self.sizeAnswerCells.removeAll(keepCapacity: true)
        self.currentNumber = (self.currentNumber + 1) % self.counter
        self.view.reloadInputViews()
        self.loadQuestion()
    }
    
    @IBAction func calcPopUp(sender: AnyObject) {
        var message = self.questions[self.currentNumber].calculator ? "Calculatrice autorisée" : "Calculatrice interdite"
       
        // create alert controller
        let myAlert = UIAlertController(title: message, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        // add an "OK" button
        myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        // show the alert
        self.presentViewController(myAlert, animated: true, completion: nil)

    }
    
    @IBAction func questionPopOver(sender: AnyObject) {
        let storyboard : UIStoryboard = UIStoryboard(
            name: "Main",
            bundle: nil)
        var choiceQuestion: ChoiceQuestionViewController = storyboard.instantiateViewControllerWithIdentifier("ChoiceQuestionViewController") as! ChoiceQuestionViewController
        choiceQuestion.modalPresentationStyle = .Popover
        choiceQuestion.preferredContentSize = CGSizeMake(280, 40)
        
        let popoverChoiceQuestionViewController = choiceQuestion.popoverPresentationController
        popoverChoiceQuestionViewController?.permittedArrowDirections = UIPopoverArrowDirection.Up
        popoverChoiceQuestionViewController?.delegate = self
        popoverChoiceQuestionViewController?.barButtonItem = sender as! UIBarButtonItem
        presentViewController(
            choiceQuestion,
            animated: true,
            completion: nil)
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
            return .None
    }
    
    private func loadQuestions() {
        //debug AND type = 0
        self.questionsRealm = realm.objects(Question).filter("chapter = %@ ", currentChapter!)
        for question in self.questionsRealm! {
            self.questions.append(question)
        }
        self.counter = self.questions.count
    }
    
    private func loadQuestion() {
        
        self.questionNumber.title = "Question n°\(self.currentNumber+1)/\(self.counter)"
        self.currentQuestion = self.questions[self.currentNumber]
        self.calc.image = ( self.currentQuestion!.calculator ? UIImage(named: "calc") : UIImage(named: "nocalc"))
        self.didLoadWording = false
        self.countAnswers()
        self.loadWording()
        
    }
    
    private func loadWording(){
        
        self.wording =  UIWebView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 1))
        self.wording.delegate = self
        self.wording.loadHTMLString( self.currentQuestion!.wording, baseURL: self.baseUrl)
        let scrollFrame = CGRect(x: 0, y: 152, width: self.view.bounds.width, height: self.view.bounds.height-152)
        self.scrollView = UIScrollView(frame: scrollFrame)
        self.scrollView.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
        self.scrollView.addSubview(self.wording)
        self.view.addSubview(scrollView)
    }
        
    private func loadAnswers(y: CGFloat){
        self.answers.frame = CGRectMake(0, y, self.view.bounds.width, 400)
        self.answers.scrollEnabled = false
        self.answers.userInteractionEnabled = true
        self.answers.delegate = self
        self.answers.dataSource = self
        self.answers.registerClass(UITableViewCellAnswer.self, forCellReuseIdentifier: "answerCell")
        self.scrollView.addSubview(self.answers)
        self.answers.reloadData()
        
        
    }
    
    private func loadSubmit(){
        var tableHeight: CGFloat = 0
        for height in self.sizeAnswerCells {
            tableHeight += height
        }
        let submit = UIButton(frame: CGRectMake(self.view.bounds.width/2 - 50, self.wording.bounds.size.height + tableHeight + 30 , 100, 40))
        submit.setTitle("Validez", forState: .Normal)
        submit.layer.cornerRadius = 6
        submit.titleLabel?.font = UIFont(name: "Segoe UI", size: 15)
        submit.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        submit.backgroundColor = UIColor(red: 27/255, green: 129/255, blue: 94/255, alpha: 1)
        var scrollSize = CGSizeMake(self.view.bounds.width, self.wording.bounds.size.height + tableHeight + 100)
        self.scrollView.autoresizingMask = UIViewAutoresizing.FlexibleHeight
        self.scrollView.contentSize =  scrollSize
        self.scrollView.addSubview(submit)
    }
    
    private func countAnswers() {
        var numberOfAnswers = 2
        if self.questions[self.currentNumber].answerThree != "" {
            numberOfAnswers++
            if self.questions[self.currentNumber].answerFour != "" {
                numberOfAnswers++
                if self.questions[self.currentNumber].answerFive != "" {
                    numberOfAnswers++
                    if self.questions[self.currentNumber].answerSix != "" {
                        numberOfAnswers++
                    }
                }
            }
        }
        println(numberOfAnswers)
        self.numberOfAnswers = numberOfAnswers
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        println("il y a \(self.numberOfAnswers) cellules")
        return self.numberOfAnswers
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("answerCell", forIndexPath: indexPath) as! UITableViewCellAnswer
        // Configure the cell...
        let answerNumber = indexPath.row
        var letter = "X"
        var html = "html"
        switch answerNumber {
        case 0:
            letter = "A"
            html = self.questions[self.currentNumber].answerOne
        case 1:
            letter = "B"
            html = self.questions[self.currentNumber].answerTwo
        case 2:
            letter = "C"
            html = self.questions[self.currentNumber].answerThree
        case 3:
            letter = "D"
            html = self.questions[self.currentNumber].answerFour
        case 4:
            letter = "E"
            html = self.questions[self.currentNumber].answerFive
        case 5:
            letter = "F"
            html = self.questions[self.currentNumber].answerSix
        default:
            letter = "X"
            html = "html"
        }
        
        cell.number.backgroundColor = UIColor(red: 27/255, green: 129/255, blue: 94/255, alpha: 1)
        cell.answer.scrollView.scrollEnabled = false
        cell.answer.userInteractionEnabled = false
        cell.answer.frame = CGRectMake(40, 0, self.view.bounds.width - 40, 40)
        cell.answer.backgroundColor = UIColor.clearColor()
        cell.number!.font = UIFont(name: "Segoe UI", size: 14)
        cell.number!.textColor = UIColor.whiteColor()
        cell.number!.textAlignment = NSTextAlignment.Center
        cell.number!.text = letter
        cell.answer.delegate = self
        cell.answer.loadHTMLString(html, baseURL: self.baseUrl)
        
        if (self.sizeAnswerCells.count == self.numberOfAnswers) {
            cell.number!.frame = CGRectMake(0, 0, 40, self.sizeAnswerCells[indexPath.row])
            cell.answer!.frame = CGRectMake(40, 0, self.view.bounds.width - 40, self.sizeAnswerCells[indexPath.row])
        }
        

        
        return cell
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if self.sizeAnswerCells.count == self.numberOfAnswers {
            return self.sizeAnswerCells[indexPath.row]
        } else {
            return 40
        }
        
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        if (self.sizeAnswerCells.count != self.numberOfAnswers) {
            //Asks the view to calculate and return the size that best fits its subviews.
            var fittingSize = webView.sizeThatFits(CGSizeZero)
            //bug DB #F9F9F9 span after image
            
            self.wording.opaque = false
            self.wording.scrollView.scrollEnabled = false
            webView.frame = CGRectMake(0, 0, self.view.bounds.width, fittingSize.height)
            self.scrollView.contentSize =  self.wording.bounds.size
            println(fittingSize.height)
            
            if self.didLoadWording {
                println("webview answer")
                webView.frame = CGRectMake(40, 0, self.view.bounds.width - 40, fittingSize.height)
                self.sizeAnswerCells.append(fittingSize.height)
                println(self.sizeAnswerCells)
                
                if self.sizeAnswerCells.count == self.numberOfAnswers {
                    println("self.sizeAnswerCells.count = \(self.sizeAnswerCells.count)")
                    println("numberOfAnswers = \(self.numberOfAnswers)")
                    println("cell sizes computed, refreshing table")
                    self.answers.reloadData()
                    self.loadSubmit()
                }
                
            } else {
                self.sizeAnswerCells.removeAll(keepCapacity: true)
                println("webview wording")
                webView.frame = CGRectMake(0, 0, self.view.bounds.width, fittingSize.height)
                self.wording.backgroundColor = UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1)
                self.didLoadWording = true
                self.loadAnswers(fittingSize.height)
            }

        }
    }

}



    

