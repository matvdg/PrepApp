//
//  QuestionViewController.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 23/07/15.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import UIKit
import RealmSwift

class QuestionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPopoverPresentationControllerDelegate, ChoiceQuestionViewControllerDelegate ,UIWebViewDelegate {
    
    
    let realm = FactoryRealm.getRealm()
    var questions: [Question] = []
    var currentChapter: Chapter?
    var currentSubject: Subject?
    var currentNumber: Int = 0
    var currentQuestion: Question?
    var counter: Int = 0
    var goodAnswers: [Int] = []
    var selectedAnswers: [Int] = []
    var didLoadWording = false
    var didLoadAnswers = false
    var sizeAnswerCells: [Int:CGFloat] = [:]
    var numberOfAnswers = 0
    var timer = NSTimer()
    var stopTimer = NSTimer()
    var senseTimer: Bool = true
    var choiceFilter = 0 // 0=ALL 1=FAILED 2=SUCCEEDED 3=NEW
    let baseUrl = NSURL(fileURLWithPath: Factory.path, isDirectory: true)!
    
    //graphics
    var submitButton = UIButton()
    var wording = UIWebView()
    var answers = UITableView()
    var infos = UIWebView()
    var scrollView: UIScrollView!
    
    
    override func viewDidLoad() {
        
        //display the subject
        self.numberOfAnswers = 0
        self.sizeAnswerCells.removeAll(keepCapacity: false)
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
        self.cleanView()
        self.sizeAnswerCells.removeAll(keepCapacity: false)
        self.currentNumber = (self.currentNumber - 1) % self.counter
        self.currentNumber = (self.currentNumber < 0) ? (self.currentNumber + self.counter):(self.currentNumber)
        self.loadQuestion()
    }
    
    @IBAction func next(sender: AnyObject) {
        
        self.cleanView()
        self.sizeAnswerCells.removeAll(keepCapacity: false)
        self.currentNumber = (self.currentNumber + 1) % self.counter
        self.loadQuestion()
    }
    
    private func cleanView() {
        self.timer.invalidate()
        self.submitButton.frame.size.width = 100
        self.submitButton.frame.size.height = 40
        self.submitButton.backgroundColor = UIColor(red: 27/255, green: 129/255, blue: 94/255, alpha: 1)
        self.submitButton.removeFromSuperview()
        self.infos.removeFromSuperview()
        self.wording.removeFromSuperview()
        self.answers.removeFromSuperview()
        self.scrollView!.removeFromSuperview()
        Sound.playTrack("next")
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
        choiceQuestion.delegate = self
        choiceQuestion.choiceFilter = self.choiceFilter
        choiceQuestion.currentChapter = self.currentChapter
        let popoverChoiceQuestionViewController = choiceQuestion.popoverPresentationController
        popoverChoiceQuestionViewController?.permittedArrowDirections = UIPopoverArrowDirection.Up
        popoverChoiceQuestionViewController?.delegate = self
        popoverChoiceQuestionViewController?.barButtonItem = sender as! UIBarButtonItem
        presentViewController(
            choiceQuestion,
            animated: true,
            completion: nil)
    }
    
    func applyChoice(var choice: Int){
        self.numberOfAnswers = 0
        self.sizeAnswerCells.removeAll(keepCapacity: false)
        self.counter = 0
        self.choiceFilter = choice
        self.currentNumber = 0
        self.cleanView()
        self.questions.removeAll(keepCapacity: false)
        println("after cleaned count = \(self.questions.count)")
        //load the questions
        self.loadQuestions()
        //display the first question
        self.loadQuestion()
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
            return .None
    }
    
    private func loadQuestions() {
        
        var tempQuestions = [Question]()
        //fetching training questions
        //AND type = 0
        var questionsRealm = realm.objects(Question).filter("chapter = %@ ", currentChapter!)
        for question in questionsRealm {
            tempQuestions.append(question)
        }
        
//        //fetching solo questions already DONE
//        questionsRealm = realm.objects(Question).filter("chapter = %@ AND type = 1", currentChapter!)
//        for question in questionsRealm {
//            if History.isQuestionDone(question.id){
//                tempQuestions.append(question)
//                println("ajout solo")
//            }
//        }
//        
//        //fetching duo questions already DONE
//        questionsRealm = realm.objects(Question).filter("chapter = %@ AND type = 2", currentChapter!)
//        for question in questionsRealm {
//            if History.isQuestionDone(question.id){
//                tempQuestions.append(question)
//                println("ajout duo")
//            }
//            
//        }
        
        //now applying the filter choosen by user
        switch choiceFilter {
        case 0: //ALL
            println("case all")
            self.questions = tempQuestions
        case 1: //FAILED
             println("case failed")
            for question in tempQuestions {
                if History.isQuestionFail(question.id){
                    println("question failed ajoutée id=\(question.id)")
                    self.questions.append(question)
                }
            }
        case 2: //SUCCEEDED
             println("case succeeded")
            for question in tempQuestions {
                if History.isQuestionSuccess(question.id){
                    println("question succeeded ajoutée id=\(question.id)")
                    self.questions.append(question)
                }
            }
        case 3: //NEW
             println("case new")
            
            //TODO : implement a solo/duo history to fetch the solo/duo DONE in theses modes not in training mode and then filter here only the solo/duo questions done in this mode
            for question in tempQuestions {
                if History.isQuestionDone(question.id){
                    println("question done ajoutée id=\(question.id)")
                    self.questions.append(question)
                }
            }
        default:
            println("default")
            
        }
        println(self.questions.count)
    
        self.counter = self.questions.count
        println(self.counter)
        //println(self.questions)
    }
    
    private func loadQuestion() {
        self.selectedAnswers.removeAll(keepCapacity: false)
        self.questionNumber.title = "Question n°\(self.currentNumber+1)/\(self.counter)"
        self.currentQuestion = self.questions[self.currentNumber]
        let answers = self.currentQuestion!.goodAnswers.componentsSeparatedByString(",")
        self.goodAnswers.removeAll(keepCapacity: false)
        for answer in answers {
            if let answerIndex = answer.toInt() {
                self.goodAnswers.append(answerIndex - 1)
            } else {
                println("DB error: no good answers, contact Administator")
            }
            
        }
        
        //println("Bonne(s) réponse(s) = \(self.goodAnswers)")
        self.calc.image = ( self.currentQuestion!.calculator ? UIImage(named: "calc") : UIImage(named: "nocalc"))
        self.didLoadWording = false
        self.didLoadAnswers = false
        self.countAnswers()
        self.loadWording()
        
    }
    
    private func loadWording(){
        self.wording =  UIWebView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 1))
        self.wording.delegate = self
        self.wording.loadHTMLString( self.currentQuestion!.wording, baseURL: self.baseUrl)
        let scrollFrame = CGRect(x: 0, y: 152, width: self.view.bounds.width, height: self.view.bounds.height-152)
        self.scrollView = UIScrollView(frame: scrollFrame)
        self.scrollView.backgroundColor = UIColor(red: 236/255, green: 236/255, blue: 236/255, alpha: 1)
        self.scrollView.addSubview(self.wording)
        self.view.addSubview(scrollView)
    }
        
    private func loadAnswers(y: CGFloat){
        self.answers.frame = CGRectMake(0, y, self.view.bounds.width, 400)
        self.answers.scrollEnabled = false
        
        self.answers.userInteractionEnabled = true
        self.answers.allowsMultipleSelection = false
        self.answers.delegate = self
        self.answers.dataSource = self
        self.answers.registerClass(UITableViewCellAnswer.self, forCellReuseIdentifier: "answerCell")
        self.scrollView.addSubview(self.answers)
        self.answers.reloadData()
        
        
    }
    
    private func loadSubmit(){
        var tableHeight: CGFloat = 0
        for (id,height) in self.sizeAnswerCells {
            tableHeight += height
        }
        //resizing the answers table (the cells have already been resized independently
        self.answers.frame.size = CGSizeMake(self.view.bounds.width, tableHeight)
        
        
        //displaying the infos and button AFTER the wording and the answers table, and centering
        self.infos = UIWebView(frame: CGRectMake(0, self.wording.bounds.size.height + 10 + tableHeight , self.view.bounds.width, 40))
        self.infos.delegate = self
        self.infos.opaque = false
        self.infos.userInteractionEnabled = false
        self.infos.loadHTMLString(self.currentQuestion!.info, baseURL: self.baseUrl)
        self.submitButton = UIButton(frame: CGRectMake(self.view.bounds.width/2 - 50, self.wording.bounds.size.height + tableHeight + 50 , 100, 40))
        self.submitButton.setTitle("Validez", forState: .Normal)
        self.submitButton.layer.cornerRadius = 6
        self.submitButton.titleLabel?.font = UIFont(name: "Segoe UI", size: 15)
        self.submitButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.submitButton.backgroundColor = UIColor(red: 27/255, green: 129/255, blue: 94/255, alpha: 1)
        
        //resizing the scroll view in order to fit all the elements
        var scrollSize = CGSizeMake(self.view.bounds.width, self.wording.bounds.size.height + tableHeight + 100)
        self.scrollView.autoresizingMask = UIViewAutoresizing.FlexibleHeight
        self.scrollView.contentSize =  scrollSize
        //adding infos, button and action
        self.submitButton.addTarget(self, action: "submit", forControlEvents: UIControlEvents.TouchUpInside)
        self.scrollView.addSubview(self.infos)
        self.scrollView.addSubview(self.submitButton)
    }
    
    func submit() {
        
        if self.selectedAnswers.isEmpty {
            // create alert controller
            let myAlert = UIAlertController(title: "Vous devez sélectionner au moins une réponse !", message: "Touchez les cases pour cocher une ou plusieurs réponses", preferredStyle: UIAlertControllerStyle.Alert)
            // add an "OK" button
            myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            // show the alert
            self.presentViewController(myAlert, animated: true, completion: nil)
        } else {
            var historyQuestion = QuestionHistory()
            self.answers.userInteractionEnabled = false
            historyQuestion.id = self.currentQuestion!.id
            if self.checkAnswers() {
                //true
                Sound.playTrack("true")
                historyQuestion.success = true
                //colouring the results
                for answer in self.goodAnswers {
                    let indexPath = NSIndexPath(forRow: answer, inSection: 0)
                    let cell = self.answers.cellForRowAtIndexPath(indexPath) as! UITableViewCellAnswer
                    cell.number.backgroundColor = UIColor(red: 27/255, green: 129/255, blue: 94/255, alpha: 1)
                    cell.number.textColor = UIColor.blackColor()
                    //green
                }
                
            } else {
                //false
                historyQuestion.success = false
                Sound.playTrack("false")
                 //colouring the results
                for answer in self.selectedAnswers {
                    let indexPath = NSIndexPath(forRow: answer, inSection: 0)
                    let cell = self.answers.cellForRowAtIndexPath(indexPath) as! UITableViewCellAnswer
                    cell.number.backgroundColor = UIColor(red: 223/255, green: 52/255, blue: 46/255, alpha: 1)
                    //red
                }
                for answer in self.goodAnswers {
                    let indexPath = NSIndexPath(forRow: answer, inSection: 0)
                    let cell = self.answers.cellForRowAtIndexPath(indexPath) as! UITableViewCellAnswer
                    cell.number.backgroundColor = UIColor(red: 27/255, green: 129/255, blue: 94/255, alpha: 1)
                    //green
                    cell.number.textColor = UIColor.blackColor()
                }
                
            }
            //saving the question result in history
            History.addQuestionToHistory(historyQuestion)
            //displaying and animating the correction button
            self.submitButton.setTitle("Correction", forState: UIControlState.Normal)
            self.submitButton.removeTarget(self, action: "submit", forControlEvents: UIControlEvents.TouchUpInside)
            self.submitButton.addTarget(self, action: "showCorrection", forControlEvents: UIControlEvents.TouchUpInside)
            self.timer = NSTimer.scheduledTimerWithTimeInterval(0.03, target: self, selector: Selector("animateButton"), userInfo: nil, repeats: true)
            self.stopTimer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "stopAnimation", userInfo: nil, repeats: false)
        }
        
    }
    
    func animateButton(){
        if self.senseTimer {
            self.submitButton.frame.size.width = self.submitButton.frame.size.width + 1
            self.submitButton.frame.size.height = self.submitButton.frame.size.height + 1
            self.submitButton.frame.origin.x = self.submitButton.frame.origin.x - 0.5
            self.submitButton.frame.origin.y = self.submitButton.frame.origin.y - 0.5
            self.submitButton.backgroundColor = UIColor(red: 27/255, green: self.submitButton.frame.size.width/255, blue: 94/255, alpha: 1)
            if self.submitButton.frame.size.width > 110 {
                self.senseTimer = false
            }
            
        } else {
            self.submitButton.frame.size.width = self.submitButton.frame.size.width - 1
            self.submitButton.frame.size.height = self.submitButton.frame.size.height - 1
            self.submitButton.frame.origin.x = self.submitButton.frame.origin.x + 0.5
            self.submitButton.frame.origin.y = self.submitButton.frame.origin.y + 0.5
            self.submitButton.backgroundColor = UIColor(red: 27/255, green: self.submitButton.frame.size.width/255, blue: 94/255, alpha: 1)
            if self.submitButton.frame.size.width < 100 {
                self.senseTimer = true
            }
        }
        
        
    }
    
    func stopAnimation(){
        self.timer.invalidate()
        self.submitButton.frame.size.width = 100
        self.submitButton.frame.size.height = 40
        self.submitButton.backgroundColor = UIColor(red: 27/255, green: 129/255, blue: 94/255, alpha: 1)
    }
    
    func showCorrection() {
        //show the correction sheet
        self.timer.invalidate()
        self.submitButton.frame.size.width = 100
        self.submitButton.frame.size.height = 40
        self.submitButton.backgroundColor = UIColor(red: 27/255, green: 129/255, blue: 94/255, alpha: 1)

        Sound.playTrack("correction")
        self.performSegueWithIdentifier("showCorrection", sender: self)
    }
    
    private func checkAnswers() -> Bool {
        var result = false
        for selectedAnswer in self.selectedAnswers {
            result = false
            for answer in self.goodAnswers {
                if answer == selectedAnswer {
                    result = true
                }
            }
            if result == false {
                break
            }
        }
        if self.selectedAnswers.count != self.goodAnswers.count {
            result = false
        }
        return result
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
        //println(numberOfAnswers)
        self.numberOfAnswers = numberOfAnswers
    }
    
    //tableview methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //println("il y a \(self.numberOfAnswers) cellules")
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
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.number.backgroundColor = UIColor.lightGrayColor()
        cell.answer.scrollView.scrollEnabled = false
        cell.answer.userInteractionEnabled = false
        cell.answer.frame = CGRectMake(40, 0, self.view.bounds.width - 80, 40)
        cell.number!.font = UIFont(name: "Segoe UI", size: 14)
        cell.number!.textColor = UIColor.whiteColor()
        cell.number!.textAlignment = NSTextAlignment.Center
        cell.number!.text = letter
        cell.answer.delegate = self
        cell.answer.position = answerNumber
        cell.answer.loadHTMLString(html, baseURL: self.baseUrl)
        cell.accessoryType = UITableViewCellAccessoryType.None
        
        if (self.sizeAnswerCells.count == self.numberOfAnswers) {
            cell.number!.frame = CGRectMake(0, 0, 40, self.sizeAnswerCells[indexPath.row]!)
            cell.answer!.frame = CGRectMake(40, 0, self.view.bounds.width - 80, self.sizeAnswerCells[indexPath.row]!)
        }
        

        
        return cell
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if self.sizeAnswerCells.count == self.numberOfAnswers {
            return self.sizeAnswerCells[indexPath.row]!
        } else {
            return 40
        }
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        Sound.playTrack("select")
        var selectedRow = indexPath.row
        var cell: UITableViewCellAnswer = tableView.cellForRowAtIndexPath(indexPath) as! UITableViewCellAnswer
        if (cell.accessoryType != UITableViewCellAccessoryType.Checkmark) {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            self.selectedAnswers.append(indexPath.row)
        }
        else
        {
            cell.accessoryType = UITableViewCellAccessoryType.None
            var index = find(self.selectedAnswers, indexPath.row)
            self.selectedAnswers.removeAtIndex(index!)
        }
        //println(self.selectedAnswers)
    }
    
    //webviews method
    func webViewDidFinishLoad(webView: UIWebView) {
        if (self.sizeAnswerCells.count != self.numberOfAnswers) {
            //Asks the view to calculate and return the size that best fits its subviews.
            var fittingSize = webView.sizeThatFits(CGSizeZero)
            self.wording.opaque = false
            self.wording.scrollView.scrollEnabled = false
            webView.frame = CGRectMake(0, 0, self.view.bounds.width, fittingSize.height)
            self.scrollView.contentSize =  self.wording.bounds.size
            println(fittingSize.height)
            //TODO: fixing the ORDER to store the size, to avoid REVERSE sizes bugs (good sizes, wrong cells)
            
            if self.didLoadWording {
                //we have just loaded the Answers webviews
                //println("we have just loaded the Answers webviews")
                webView.frame = CGRectMake(40, 0, self.view.bounds.width - 40, fittingSize.height)
                //we save the computed sizes
                let webViewAnswer = webView as! UIWebViewAnswer
                self.sizeAnswerCells[webViewAnswer.position!] = fittingSize.height
                println(self.sizeAnswerCells)
                
                //if we have computed ALL the answers webview, then we refresh the table to display the proper sizes
                if self.sizeAnswerCells.count == self.numberOfAnswers {
                    //println("self.sizeAnswerCells.count = \(self.sizeAnswerCells.count)")
                    //println("numberOfAnswers = \(self.numberOfAnswers)")
                    //println("cell sizes computed, refreshing table")
                    self.answers.separatorInset = UIEdgeInsetsMake(0, 40, 0, 0)
                    self.answers.reloadData()
                }
                
            } else {
                //we have just loaded the Wording webview
                //println("we have just loaded the Wording webview")
                self.sizeAnswerCells.removeAll(keepCapacity: false)
                webView.frame = CGRectMake(0, 0, self.view.bounds.width, fittingSize.height)
                self.wording.backgroundColor = UIColor.whiteColor()
                self.didLoadWording = true
                self.loadAnswers(fittingSize.height + 10)
            }

        } else {
            if self.didLoadAnswers {
                //we have just loaded the Infos webview
                //println("we have just loaded the Infos webview")
                self.infos.backgroundColor = UIColor(red: 236/255, green: 236/255, blue: 236/255, alpha: 1)
            
            } else {
                //we have just refreshed the answers table, now we load the Infos webview and the submit button
                //println("we have just refreshed the answers table, now we load the Infos webview and the submit button")
                self.didLoadAnswers = true
                self.loadSubmit()
                
            }
            
        }
    }
    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        var correctionVC = segue.destinationViewController as! CorrectionViewController
        // Pass the selected object to the new view controller.
        correctionVC.correctionHTML = self.currentQuestion!.correction
    }


}



    

