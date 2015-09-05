//
//  QuestionSoloViewController.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 23/07/15.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import UIKit
import RealmSwift

class QuestionSoloViewController: UIViewController,
    UITableViewDataSource,
    UITableViewDelegate,
    UIWebViewDelegate {
    
    //properties
    var mode = 0 //0 = challenge 1 = results
    var choice: Int = 0
    let realm = FactoryRealm.getRealm()
    var questions: [Question] = []
    var currentNumber: Int = 0
    var currentQuestion: Question?
    var goodAnswers: [Int] = []
    var allAnswers = [Int:[Int]]()
    var selectedAnswers: [Int] = []
    var didLoadWording = false
    var didLoadAnswers = false
    var didLoadInfos = false
    var sizeAnswerCells: [Int:CGFloat] = [:]
    var numberOfAnswers = 0
    var timeChallengeTimer = NSTimer()
    var animatingCorrectionTimer = NSTimer()
    var stopAnimationCorrectionTimer = NSTimer()
    var timeLeft = NSTimeInterval(20*60)
    var senseAnimationCorrection: Bool = true
    var waitBeforeNextQuestion: Bool = false
    let baseUrl = NSURL(fileURLWithPath: Factory.path, isDirectory: true)!
    
    //graphics properties
    var submitButton = UIButton()
    var wording = UIWebView()
    var answers = UITableView()
    var infos = UIWebView()
    var scrollView: UIScrollView!
    var greyMask: UIView!
    
    //app methods
    override func viewDidLoad() {
        self.markButton.image = nil
        self.markButton.title = "20:00"
        self.markButton.enabled = false
        self.timeChallengeTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("countdown"), userInfo: nil, repeats: true)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "logout", name: "failed", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "update", name: "update", object: nil)
        //handling swipe gestures
        var swipeRight = UISwipeGestureRecognizer(target: self, action: "swiped:")
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRight)
        
        var swipeLeft = UISwipeGestureRecognizer(target: self, action: "swiped:")
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(swipeLeft)
        
        //display the subject
        self.numberOfAnswers = 0
        self.sizeAnswerCells.removeAll(keepCapacity: false)
        //load the questions
        self.loadQuestions()
        //display the first question
        self.loadQuestion()
        
        
    }
    
    //@IBOutlets properties
    @IBOutlet weak var chapter: UILabel!
    @IBOutlet weak var markButton: UIBarButtonItem!
    @IBOutlet weak var questionNumber: UIBarButtonItem!
    @IBOutlet weak var filterButton: UIBarButtonItem!
    @IBOutlet weak var calc: UIBarButtonItem!
    @IBOutlet weak var nextButton: UIBarButtonItem!
    @IBOutlet weak var previousButton: UIBarButtonItem!
    
    //@IBActions methods
    @IBAction func previous(sender: AnyObject) {
        self.goPrevious()
    }
    
    @IBAction func next(sender: AnyObject) {
        self.goNext()
    }
    
    @IBAction func calcPopUp(sender: AnyObject) {
        var message = self.questions[self.currentNumber].calculator ? "Calculatrice autorisée" : "Calculatrice interdite"
        self.questions[self.currentNumber].calculator ? Sound.playTrack("calc") : Sound.playTrack("nocalc")
        // create alert controller
        let myAlert = UIAlertController(title: message, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        // add an "OK" button
        myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        // show the alert
        self.presentViewController(myAlert, animated: true, completion: nil)
        
    }
    
    @IBAction func markQuestion(sender: AnyObject) {
        
        var title = ""
        var message = ""
        if History.isQuestionMarked(self.currentQuestion!.id){
            Sound.playTrack("error")
            title = "Question déjà marquée !"
            message = "Retrouvez toutes les questions marquées dans la section \"Questions marquées\" dans \"Profil\""
            let myAlert = UIAlertController(title: title, message: message , preferredStyle: UIAlertControllerStyle.Alert)
            myAlert.addAction(UIAlertAction(title: "Supprimer le marquage", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                var historyQuestion = QuestionHistory()
                historyQuestion.id = self.currentQuestion!.id
                historyQuestion.marked = false
                History.updateQuestionMark(historyQuestion)
                Sound.playTrack("calc")
                let myAlert = UIAlertController(title: "Marquage supprimé", message: nil , preferredStyle: UIAlertControllerStyle.Alert)
                myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                // show the alert
                self.presentViewController(myAlert, animated: true, completion: nil)
            }))
            myAlert.addAction(UIAlertAction(title: "Envoyer un commentaire", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                self.performSegueWithIdentifier("showMarkedQuestions", sender: self)
            }))
            myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            
            // show the alert
            self.presentViewController(myAlert, animated: true, completion: nil)
            
        } else {
            if History.isQuestionDone(self.currentQuestion!.id) {
                Sound.playTrack("calc")
                title = "Question marquée"
                message = "Retrouvez toutes les questions marquées dans la section \"Questions marquées\" dans \"Profil\""
                let myAlert = UIAlertController(title: title, message: message , preferredStyle: UIAlertControllerStyle.Alert)
                var historyQuestion = QuestionHistory()
                historyQuestion.id = self.currentQuestion!.id
                historyQuestion.marked = true
                History.updateQuestionMark(historyQuestion)
                myAlert.addAction(UIAlertAction(title: "Supprimer le marquage", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                    var historyQuestion = QuestionHistory()
                    historyQuestion.id = self.currentQuestion!.id
                    historyQuestion.marked = false
                    History.updateQuestionMark(historyQuestion)
                    Sound.playTrack("calc")
                    let myAlert = UIAlertController(title: "Marquage supprimé", message: nil , preferredStyle: UIAlertControllerStyle.Alert)
                    myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    // show the alert
                    self.presentViewController(myAlert, animated: true, completion: nil)
                }))
                
                myAlert.addAction(UIAlertAction(title: "Envoyer un commentaire", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                    self.performSegueWithIdentifier("showMarkedQuestions", sender: self)
                }))
                myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                // show the alert
                self.presentViewController(myAlert, animated: true, completion: nil)
                
            } else {
                Sound.playTrack("error")
                title = "Oups !"
                message = "Vous devez d'abord répondre à la question pour pouvoir la marquer"
                let myAlert = UIAlertController(title: title, message: message , preferredStyle: UIAlertControllerStyle.Alert)
                myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                // show the alert
                self.presentViewController(myAlert, animated: true, completion: nil)
                
            }
        }
    }
    
    
    //methods
    private func goNext() {
        if self.currentNumber == 0 {
            self.previousButton.enabled = true
        }
        if self.currentNumber + 2 == self.questions.count {
            self.nextButton.enabled = false
        }
        if !self.waitBeforeNextQuestion {
            Sound.playTrack("next")
            self.allAnswers[self.currentNumber] = self.selectedAnswers
            self.waitBeforeNextQuestion = true
            let delay = 0.5 * Double(NSEC_PER_SEC)
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            dispatch_after(time, dispatch_get_main_queue()) {
                self.cleanView()
                self.sizeAnswerCells.removeAll(keepCapacity: false)
                self.currentNumber = (self.currentNumber + 1) % self.questions.count
                self.loadQuestion()
                self.waitBeforeNextQuestion = false
            }
        }
    }
    
    private func goPrevious() {
        if self.currentNumber + 1 == self.questions.count {
            self.nextButton.enabled = true
        }
        if self.currentNumber - 1 == 0 {
            self.previousButton.enabled = false
        }
        if !self.waitBeforeNextQuestion {
            Sound.playTrack("next")
            self.allAnswers[self.currentNumber] = self.selectedAnswers
            self.waitBeforeNextQuestion = true
            let delay = 0.5 * Double(NSEC_PER_SEC)
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            dispatch_after(time, dispatch_get_main_queue()) {
                self.cleanView()
                self.sizeAnswerCells.removeAll(keepCapacity: false)
                self.currentNumber = (self.currentNumber - 1) % self.questions.count
                self.loadQuestion()
                self.waitBeforeNextQuestion = false
            }
        }
    }
    
    private func loadQuestions() {
        //applying grey mask
        let frame = CGRect(x: 0, y: 152, width: self.view.bounds.width, height: self.view.bounds.height-152)
        self.greyMask = UIView(frame: frame)
        self.greyMask.backgroundColor = colorGreyBackgound
        self.greyMask.layer.zPosition = 100
        self.view.addSubview(self.greyMask)
        
        
        var tempQuestions = [Question]()
        //fetching solo questions NEVER DONE
        var questionsRealm = realm.objects(Question).filter("type = 1")
        for question in questionsRealm {
            if History.isQuestionNew(question.id){
                tempQuestions.append(question)
                println("ajout solo")
            }
        }
        
        tempQuestions.shuffle()
        
        //now applying the trigram choice choosen by user 1 biology, 2 physics, 3 chemistry, 4 bioPhy, 5 bioChe, 6 chePhy, 7 all
        var counter = 0
        switch self.choice {
            
            
        case 1: //biology
            
            for question in tempQuestions {
                
                if question.chapter!.subject!.id == 1 && counter < 12 {
                    self.questions.append(question)
                    counter++
                }
            }
            self.questions.shuffle()
            
        case 2: //physics
            for question in tempQuestions {
                
                if question.chapter!.subject!.id == 2 && counter < 6 {
                    self.questions.append(question)
                    counter++
                }
            }
            self.questions.shuffle()

        case 3: //chemistry
            for question in tempQuestions {
                
                if question.chapter!.subject!.id == 3 && counter < 6 {
                    self.questions.append(question)
                    counter++
                }
            }
            self.questions.shuffle()

        case 4: //bioPhy
            for question in tempQuestions {
                
                if question.chapter!.subject!.id == 1 && counter < 8 {
                    self.questions.append(question)
                    counter++
                }
            }
            counter = 0
            for question in tempQuestions {
                
                if question.chapter!.subject!.id == 2 && counter < 3 {
                    self.questions.append(question)
                    counter++
                }
            }

            self.questions.shuffle()
            
        case 5: //bioChe
            for question in tempQuestions {
                
                if question.chapter!.subject!.id == 1 && counter < 8 {
                    self.questions.append(question)
                    counter++
                }
            }
            counter = 0
            for question in tempQuestions {
                
                if question.chapter!.subject!.id == 3 && counter < 3 {
                    self.questions.append(question)
                    counter++
                }
            }
            
            self.questions.shuffle()

        case 6: //chePhy
            for question in tempQuestions {
                
                if question.chapter!.subject!.id == 2 && counter < 4 {
                    self.questions.append(question)
                    counter++
                }
            }
            counter = 0
            for question in tempQuestions {
                
                if question.chapter!.subject!.id == 3 && counter < 2 {
                    self.questions.append(question)
                    counter++
                }
            }
            
            self.questions.shuffle()

        case 7: //all
            for question in tempQuestions {
                
                if question.chapter!.subject!.id == 1 && counter < 6 {
                    self.questions.append(question)
                    counter++
                }
            }
            counter = 0
            for question in tempQuestions {
                
                if question.chapter!.subject!.id == 2 && counter < 2 {
                    self.questions.append(question)
                    counter++
                }
            }
            counter = 0
            for question in tempQuestions {
                
                if question.chapter!.subject!.id == 3 && counter < 1 {
                    self.questions.append(question)
                    counter++
                }
            }
            
            self.questions.shuffle()

        default:
            println("default")
        }
        
        if self.questions.count == 1 {
            self.nextButton.enabled = false
            self.previousButton.enabled = false
        } else {
            self.nextButton.enabled = true
            self.previousButton.enabled = false
        }
        
        self.questions.shuffle()
        
        
    }
    
    private func loadQuestion() {
        println(self.allAnswers)
        self.greyMask.layer.zPosition = 100
        self.selectedAnswers.removeAll(keepCapacity: false)
        self.questionNumber.title = "Question n°\(self.currentNumber+1)/\(self.questions.count)"
        self.currentQuestion = self.questions[self.currentNumber]
        let answers = self.currentQuestion!.answers
        self.goodAnswers.removeAll(keepCapacity: false)
        var numberAnswer = 0
        for answer in answers {
            if answer.correct {
                self.goodAnswers.append(numberAnswer)
            }
            numberAnswer++
        }
        
        //retrieving checkmarks if already done
        if let savedAnswers = self.allAnswers[self.currentNumber] {
            self.selectedAnswers = savedAnswers
        }
        
        println("Question n°\(self.currentQuestion!.id) , bonne(s) réponse(s) = \(self.goodAnswers)")
        self.calc.image = ( self.currentQuestion!.calculator ? UIImage(named: "calc") : UIImage(named: "nocalc"))
        self.didLoadWording = false
        self.didLoadAnswers = false
        self.didLoadInfos = false
        self.numberOfAnswers = self.currentQuestion!.answers.count
        self.loadWording()
        
        
        
        
        //display the subject
        self.title = self.currentQuestion!.chapter!.subject!.name.uppercaseString
        self.navigationController!.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Segoe UI", size: 20)!]
        self.navigationController!.navigationBar.tintColor = colorGreenAppButtons
        //display the chapter
        self.chapter.text = "Chapitre \(self.currentQuestion!.chapter!.number) : \(self.currentQuestion!.chapter!.name)"

        
    }
    
    private func loadWording(){
        self.wording =  UIWebView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 1))
        self.wording.delegate = self
        self.wording.loadHTMLString( self.currentQuestion!.wording, baseURL: self.baseUrl)
        let scrollFrame = CGRect(x: 0, y: 152, width: self.view.bounds.width, height: self.view.bounds.height-152)
        self.scrollView = UIScrollView(frame: scrollFrame)
        self.scrollView.backgroundColor = colorGreyBackgound
        self.scrollView.addSubview(self.wording)
        self.view.addSubview(self.scrollView)
        
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
    
    private func cleanView() {
        self.animatingCorrectionTimer.invalidate()
        self.submitButton.hidden = false
        self.submitButton.frame.size.width = 100
        self.submitButton.frame.size.height = 40
        self.submitButton.backgroundColor = colorGreenAppButtons
        self.submitButton.removeFromSuperview()
        self.infos.removeFromSuperview()
        self.wording.removeFromSuperview()
        self.answers.removeFromSuperview()
        self.scrollView!.removeFromSuperview()
    }
    
    private func refreshQuestion(){
        let delay = 1 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue()) {
            //println("refreshQuestion")
            self.cleanView()
            self.sizeAnswerCells.removeAll(keepCapacity: false)
            self.loadQuestion()
        }
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
        //println(self.currentQuestion!.info)
        self.infos.delegate = self
        self.infos.opaque = false
        self.infos.userInteractionEnabled = false
        self.infos.loadHTMLString(self.currentQuestion!.info, baseURL: self.baseUrl)
        //adding infos
        self.scrollView.addSubview(self.infos)
        self.scrollView.autoresizingMask = UIViewAutoresizing.FlexibleHeight
        if self.mode == 0 {
            //if last question
            if self.currentNumber+1 == self.questions.count {
                self.submitButton = UIButton(frame: CGRectMake(self.view.bounds.width/2 - 100, self.wording.bounds.size.height + tableHeight + 50 , 200, 40))
                self.submitButton.setTitle("Terminer le défi duo", forState: .Normal)
                self.submitButton.layer.cornerRadius = 6
                self.submitButton.titleLabel?.font = UIFont(name: "Segoe UI", size: 15)
                self.submitButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                self.submitButton.backgroundColor = colorGreenAppButtons
                //resizing the scroll view in order to fit all the elements
                var scrollSize = CGSizeMake(self.view.bounds.width, self.wording.bounds.size.height + tableHeight + 100)
                self.scrollView.contentSize =  scrollSize
                //adding button and action
                self.submitButton.addTarget(self, action: "submit", forControlEvents: UIControlEvents.TouchUpInside)
                self.scrollView.addSubview(self.submitButton)
                
            } else {
                //resizing the scroll view in order to fit all the elements
                var scrollSize = CGSizeMake(self.view.bounds.width, self.wording.bounds.size.height + tableHeight + 50)
                self.scrollView.contentSize =  scrollSize
            }

        } else {
            self.submitButton = UIButton(frame: CGRectMake(self.view.bounds.width/2 - 50, self.wording.bounds.size.height + tableHeight + 50 , 100, 40))
            self.submitButton.layer.cornerRadius = 6
            self.submitButton.titleLabel?.font = UIFont(name: "Segoe UI", size: 15)
            self.submitButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            self.submitButton.backgroundColor = colorGreenAppButtons
            // displaying results & correction if available
            self.showAnswers()
            //resizing the scroll view in order to fit all the elements
            var scrollSize = CGSizeMake(self.view.bounds.width, self.wording.bounds.size.height + tableHeight + 100)
            self.scrollView.contentSize =  scrollSize
            //adding button
            self.scrollView.addSubview(self.submitButton)
        }
    }
    
    func submit() {
        self.allAnswers[self.currentNumber] = self.selectedAnswers
        if self.checkUnanswered() {
            let myAlert = UIAlertController(title: "Attention, vous n'avez pas répondu à toutes les questions !", message: "Voulez-vous tout de même terminer le défi solo ?", preferredStyle: UIAlertControllerStyle.Alert)
            // add an "OK" button
            myAlert.addAction(UIAlertAction(title: "Oui, terminer", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                //challenge finished! switch to results mode
                
                self.cleanView()
                self.displayResultsMode()
            }))
            myAlert.addAction(UIAlertAction(title: "Non, annuler", style: UIAlertActionStyle.Default, handler: nil))
            // show the alert
            self.presentViewController(myAlert, animated: true, completion: nil)

        } else {
            let myAlert = UIAlertController(title: "Voulez-vous vraiment terminer le défi solo ?", message: "Vous ne pourrez plus modifier vos réponses.", preferredStyle: UIAlertControllerStyle.Alert)
            // add an "OK" button
            myAlert.addAction(UIAlertAction(title: "Oui, terminer", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                //challenge finished! switch to results mode
                
                self.cleanView()
                self.displayResultsMode()
            }))
            myAlert.addAction(UIAlertAction(title: "Non, annuler", style: UIAlertActionStyle.Default, handler: nil))
            // show the alert
            self.presentViewController(myAlert, animated: true, completion: nil)
        }
    }
    
    private func showAnswers() {
        
        var historyQuestion = QuestionHistory()
        self.answers.userInteractionEnabled = false
        historyQuestion.id = self.currentQuestion!.id
        historyQuestion.training = false
        if self.checkAnswers() {
            //true
            Sound.playTrack("true")
            historyQuestion.success = true
            //colouring the results
            for answer in self.goodAnswers {
                let indexPath = NSIndexPath(forRow: answer, inSection: 0)
                let cell = self.answers.cellForRowAtIndexPath(indexPath) as! UITableViewCellAnswer
                cell.number.backgroundColor = colorRightAnswer
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
                cell.number.backgroundColor = colorWrongAnswer
                //red
            }
            for answer in self.goodAnswers {
                let indexPath = NSIndexPath(forRow: answer, inSection: 0)
                if let cell = self.answers.cellForRowAtIndexPath(indexPath) as? UITableViewCellAnswer {
                    cell.number.backgroundColor = colorRightAnswer
                    //green
                    cell.number.textColor = UIColor.blackColor()
                }
                
            }
            
        }
        //saving the question result in history
        History.addQuestionToHistory(historyQuestion)
        
        //displaying and animating the correction button IF AVAILABLE
        if self.currentQuestion!.correction != "" {
            self.submitButton.setTitle("Correction", forState: UIControlState.Normal)
            self.submitButton.addTarget(self, action: "showCorrection", forControlEvents: UIControlEvents.TouchUpInside)
            self.animatingCorrectionTimer = NSTimer.scheduledTimerWithTimeInterval(0.03, target: self, selector: Selector("animateButton"), userInfo: nil, repeats: true)
            self.stopAnimationCorrectionTimer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "stopAnimation", userInfo: nil, repeats: false)
        } else {
            self.submitButton.hidden = true
        }
    }
    
    func animateButton(){
        if self.senseAnimationCorrection {
            self.submitButton.frame.size.width = self.submitButton.frame.size.width + 1
            self.submitButton.frame.size.height = self.submitButton.frame.size.height + 1
            self.submitButton.frame.origin.x = self.submitButton.frame.origin.x - 0.5
            self.submitButton.frame.origin.y = self.submitButton.frame.origin.y - 0.5
            self.submitButton.backgroundColor = colorGreenAppButtons
            if self.submitButton.frame.size.width > 110 {
                self.senseAnimationCorrection = false
            }
            
        } else {
            self.submitButton.frame.size.width = self.submitButton.frame.size.width - 1
            self.submitButton.frame.size.height = self.submitButton.frame.size.height - 1
            self.submitButton.frame.origin.x = self.submitButton.frame.origin.x + 0.5
            self.submitButton.frame.origin.y = self.submitButton.frame.origin.y + 0.5
            self.submitButton.backgroundColor = colorGreenAppButtons
            if self.submitButton.frame.size.width < 100 {
                self.senseAnimationCorrection = true
            }
        }
        
        
    }
    
    func stopAnimation(){
        self.animatingCorrectionTimer.invalidate()
        self.submitButton.frame.size.width = 100
        self.submitButton.frame.size.height = 40
        self.submitButton.backgroundColor = colorGreenAppButtons
    }
    
    func showCorrection() {
        //show the correction sheet
        self.animatingCorrectionTimer.invalidate()
        self.submitButton.frame.size.width = 100
        self.submitButton.frame.size.height = 40
        self.submitButton.backgroundColor = colorGreenAppButtons
        
        Sound.playPage()
        self.performSegueWithIdentifier("showCorrection", sender: self)
    }
    
    func swiped(gesture : UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            switch swipeGesture.direction {
                
            case UISwipeGestureRecognizerDirection.Left:
                if self.currentNumber + 1 != self.questions.count {
                    self.goNext()
                }
                
            case UISwipeGestureRecognizerDirection.Right:
                if self.currentNumber != 0 {
                    self.goPrevious()
                }
                
            default:
                println("other")
                break
            }
            
        }
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
    
    func countdown() {
        if self.timeLeft != 0 {
            self.timeLeft--
            let seconds = String(format: "%02d", Int(floor(self.timeLeft % 60)))
            let minutes = String(format: "%02d", Int(floor(self.timeLeft / 60)))
            self.markButton.title = "\(minutes):\(seconds)"
        } else {
            //challenge finished! switch to results mode
            self.allAnswers[self.currentNumber] = self.selectedAnswers
            let myAlert = UIAlertController(title: "Temps écoulé", message: "Le défi solo est à présent terminé.", preferredStyle: UIAlertControllerStyle.Alert)
            // add an "OK" button
            myAlert.addAction(UIAlertAction(title: "Oui, terminer", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                //challenge finished! switch to results mode
                self.displayResultsMode()
            }))
            myAlert.addAction(UIAlertAction(title: "Non, annuler", style: UIAlertActionStyle.Default, handler: nil))
            // show the alert
            self.presentViewController(myAlert, animated: true, completion: nil)
            self.displayResultsMode()
        }
        
    }
    
    func displayResultsMode() {
        //challenge finished! switch to results mode
        println("challenge mode ended, results mode")
        self.mode = 1
        self.markButton.image = UIImage(named: "marked")
        self.markButton.enabled = true
        self.timeChallengeTimer.invalidate()
        let myAlert = UIAlertController(title: "Défi solo terminé", message: "Vous pouvez à présent voir les réponses et les corrections si disponibles et éventuellement mettre certaines questions de côté en les marquant" , preferredStyle: UIAlertControllerStyle.Alert)
        myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))

        // show the alert
        self.presentViewController(myAlert, animated: true, completion: nil)
        self.currentNumber = 0
        if self.questions.count == 1 {
            self.nextButton.enabled = false
            self.previousButton.enabled = false
        } else {
            self.nextButton.enabled = true
            self.previousButton.enabled = false
        }
        self.loadQuestion()
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
    
    private func checkUnanswered() -> Bool {
        var result = false
        for (question, answers) in self.allAnswers {
            if answers.isEmpty {
                result = true
                break
            }
        }
        return result
    }
    
    //UITableViewDataSource methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //println("il y a \(self.numberOfAnswers) cellules")
        return self.numberOfAnswers
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("answerCell", forIndexPath: indexPath) as! UITableViewCellAnswer
        // Configure the cell...
        let answerNumber = indexPath.row
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.number.backgroundColor = colorUnanswered
        cell.answer.scrollView.scrollEnabled = false
        cell.answer.userInteractionEnabled = false
        cell.answer.frame = CGRectMake(40, 0, self.view.bounds.width - 80, 40)
        cell.number!.font = UIFont(name: "Segoe UI", size: 14)
        cell.number!.textColor = UIColor.whiteColor()
        cell.number!.textAlignment = NSTextAlignment.Center
        cell.number!.text = answerNumber.answerPrepApp()
        cell.answer.delegate = self
        cell.answer.position = answerNumber
        cell.answer.loadHTMLString(self.currentQuestion!.answers[answerNumber].content, baseURL: self.baseUrl)
        cell.accessoryType = UITableViewCellAccessoryType.None
        
        if (self.sizeAnswerCells.count == self.numberOfAnswers) {
            if let height = self.sizeAnswerCells[indexPath.row]{
                cell.number!.frame = CGRectMake(0, 0, 40, height)
                cell.answer!.frame = CGRectMake(40, 0, self.view.bounds.width - 80, height)
            }
            else {
                println("error loading too fast, delegates not finished")
                self.refreshQuestion()
            }
        }
        //retrieving checkmarks if already done
        if find(self.selectedAnswers,answerNumber) != nil {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
        return cell
    }
    
    //UITableViewDelegate methods
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if self.sizeAnswerCells.count == self.numberOfAnswers {
            if let height = self.sizeAnswerCells[indexPath.row] {
                return height
            } else {
                println("error loading too fast, delegates not finished")
                self.refreshQuestion()
                return 40
            }
            
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
    
    //UIWebViewDelegate method
    func webViewDidFinishLoad(webView: UIWebView) {
        if (self.sizeAnswerCells.count != self.numberOfAnswers) {
            //Asks the view to calculate and return the size that best fits its subviews.
            var fittingSize = webView.sizeThatFits(CGSizeZero)
            self.wording.opaque = false
            self.wording.scrollView.scrollEnabled = false
            webView.frame = CGRectMake(0, 0, self.view.bounds.width, fittingSize.height)
            self.scrollView.contentSize =  self.wording.bounds.size
            if self.didLoadWording {
                //we have just loaded the Answers webviews
                webView.frame = CGRectMake(40, 0, self.view.bounds.width - 40, fittingSize.height)
                //we save the computed sizes
                if let webViewAnswer = webView as? UIWebViewAnswer {
                    self.sizeAnswerCells[webViewAnswer.position!] = fittingSize.height
                }
                
                //if we have computed ALL the answers webview, then we refresh the table to display the proper sizes
                if self.sizeAnswerCells.count == self.numberOfAnswers {
                    self.answers.separatorInset = UIEdgeInsetsMake(0, 40, 0, 0)
                    self.answers.reloadData()
                }
                
                
            } else {
                //we have just loaded the Wording webview
                self.sizeAnswerCells.removeAll(keepCapacity: false)
                webView.frame = CGRectMake(0, 0, self.view.bounds.width, fittingSize.height)
                self.wording.backgroundColor = UIColor.whiteColor()
                self.didLoadWording = true
                self.loadAnswers(fittingSize.height + 10)
            }
            
        } else {
            if self.didLoadAnswers {
                if !self.didLoadInfos {
                    self.didLoadInfos = true
                    //we have just loaded the Infos webview
                    self.infos.backgroundColor = colorGreyBackgound
                    self.greyMask.layer.zPosition = 0
                }
            } else {
                //we have just refreshed the answers table, now we load the Infos webview and the submit button
                self.didLoadAnswers = true
                self.loadSubmit()
                
            }
            
        }
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        if let correctionVC = segue.destinationViewController as? CorrectionViewController {
            // Pass the selected object to the new view controller.
            correctionVC.correctionHTML = self.currentQuestion!.correction
        }
        
        if let profileVC = segue.destinationViewController as? DetailProfileViewController {
            // Pass the selected object to the new view controller.
            profileVC.profileTopics = "Questions marquées"
        }
    }
    
}




