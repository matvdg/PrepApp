//
//  QuestionContestViewController.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 11/11/2015.
//  Copyright © 2015 PrepApp. All rights reserved.
//

import UIKit
import RealmSwift

class QuestionContestViewController: UIViewController,
    UITableViewDataSource,
    UITableViewDelegate,
    UIWebViewDelegate,
    UINavigationControllerDelegate
    
{
    
    //properties
    var mode = 0 //0 = challenge 1 = results
    var contest: Contest?
    var score: Int = 0
    var points: Float = 0
    var emptyAnswers = 0
    var soundAlreadyPlayed = false
    var succeeded = 0
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
    var timeLeft = NSTimeInterval(1)
    var waitBeforeNextQuestion: Bool = false
    let baseUrl = NSURL(fileURLWithPath: FactorySync.path, isDirectory: true)
    var reviewMode = false
    //graphics properties
    var submitButton = UIButton()
    var wording = UIWebView()
    var answers = UITableView()
    var infos = UIWebView()
    var scrollView: UIScrollView!
    var greyMask: UIView!
    
    //app methods
    override func viewDidLoad() {
        //sync
        FactoryHistory.getHistory().sync()
        self.view!.backgroundColor = Colors.greyBackground
        self.markButton.image = nil
        self.chrono.textAlignment = NSTextAlignment.Center
        self.timeLeft = NSTimeInterval(60 * self.contest!.duration)
        let seconds = Int(floor(self.timeLeft % 60))
        let minutes = Int(floor(self.timeLeft / 60))
        var string = ""
        if minutes < 1 {
            string = String(format: "%02d", seconds)
        } else {
            string = String(format: "%02d", minutes)
        }
        self.chrono.text = string
        self.timeChallengeTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("countdown"), userInfo: nil, repeats: true)
        self.markButton.enabled = false
        self.titleLabel.text = self.contest!.name
        self.endChallengeButton.layer.cornerRadius = 6
        self.titleLabel.textColor = UIColor.blackColor()
        self.titleBar.backgroundColor = Colors.greenLogo
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "logout", name: "failed", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "update", name: "update", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshQuestion", name: "portrait", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshQuestion", name: "landscape", object: nil)
        //handling swipe gestures
        let swipeRight = UISwipeGestureRecognizer(target: self, action: "swiped:")
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRight)
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: "swiped:")
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
    @IBOutlet weak var titleBar: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var chronoImage: UIImageView!
    @IBOutlet weak var chrono: UILabel!
    @IBOutlet weak var endChallengeButton: UIButton!
    
    
    //@IBActions methods
    @IBAction func previous(sender: AnyObject) {
        self.goPrevious()
    }
    
    @IBAction func next(sender: AnyObject) {
        self.goNext()
    }
    
    @IBAction func calcPopUp(sender: AnyObject) {
        if self.mode == 0 {
            let message = self.questions[self.currentNumber].calculator ? "Calculatrice autorisée" : "Calculatrice interdite"
            self.questions[self.currentNumber].calculator ? Sound.playTrack("notif") : Sound.playTrack("nocalc")
            // create alert controller
            let myAlert = UIAlertController(title: message, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            myAlert.view.tintColor = Colors.green
            // add "OK" button
            myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
            // show the alert
            self.presentViewController(myAlert, animated: true, completion: nil)
        } else {
            self.reviewMode = true
            self.performSegueWithIdentifier("showScore", sender: self)
        }
    }
    
    @IBAction func markQuestion(sender: AnyObject) {
        
        var title = ""
        var message = ""
        if FactoryHistory.getHistory().isQuestionMarked(self.currentQuestion!.id){
            Sound.playTrack("error")
            title = "Question déjà marquée !"
            message = "Retrouvez tous les marquages dans la section \"Marquages\""
            let myAlert = UIAlertController(title: title, message: message , preferredStyle: UIAlertControllerStyle.Alert)
            myAlert.view.tintColor = Colors.green
            myAlert.addAction(UIAlertAction(title: "Supprimer le marquage", style: UIAlertActionStyle.Destructive, handler: { (action) -> Void in
                self.markButton.tintColor = UIColor.grayColor()
                let historyQuestion = QuestionHistory()
                historyQuestion.id = self.currentQuestion!.id
                historyQuestion.marked = false
                FactoryHistory.getHistory().updateQuestionMark(historyQuestion)
                Sound.playTrack("notif")
                let myAlert = UIAlertController(title: "Marquage supprimé", message: nil , preferredStyle: UIAlertControllerStyle.Alert)
                myAlert.view.tintColor = Colors.green
                myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
                // show the alert
                self.presentViewController(myAlert, animated: true, completion: nil)
            }))
            myAlert.addAction(UIAlertAction(title: "Envoyer un commentaire", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                self.performSegueWithIdentifier("showMarkedQuestion", sender: self)
            }))
            myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
            
            // show the alert
            self.presentViewController(myAlert, animated: true, completion: nil)
            
        } else {
            if FactoryHistory.getHistory().isQuestionDone(self.currentQuestion!.id) {
                Sound.playTrack("notif")
                title = "Question marquée"
                self.markButton.tintColor = Colors.greenLogo
                message = "Retrouvez tous les marquages dans la section \"Marquages\""
                let myAlert = UIAlertController(title: title, message: message , preferredStyle: UIAlertControllerStyle.Alert)
                myAlert.view.tintColor = Colors.green
                let historyQuestion = QuestionHistory()
                historyQuestion.id = self.currentQuestion!.id
                historyQuestion.marked = true
                FactoryHistory.getHistory().updateQuestionMark(historyQuestion)
                myAlert.addAction(UIAlertAction(title: "Supprimer le marquage", style: UIAlertActionStyle.Destructive, handler: { (action) -> Void in
                    self.markButton.tintColor = UIColor.grayColor()
                    let historyQuestion = QuestionHistory()
                    historyQuestion.id = self.currentQuestion!.id
                    historyQuestion.marked = false
                    FactoryHistory.getHistory().updateQuestionMark(historyQuestion)
                    Sound.playTrack("notif")
                    let myAlert = UIAlertController(title: "Marquage supprimé", message: nil , preferredStyle: UIAlertControllerStyle.Alert)
                    myAlert.view.tintColor = Colors.green
                    myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    // show the alert
                    self.presentViewController(myAlert, animated: true, completion: nil)
                }))
                
                myAlert.addAction(UIAlertAction(title: "Envoyer un commentaire", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                    self.performSegueWithIdentifier("showMarkedQuestion", sender: self)
                }))
                myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
                // show the alert
                self.presentViewController(myAlert, animated: true, completion: nil)
                
            } else {
                Sound.playTrack("error")
                title = "Oups !"
                message = "Vous devez d'abord répondre à la question pour pouvoir la marquer"
                let myAlert = UIAlertController(title: title, message: message , preferredStyle: UIAlertControllerStyle.Alert)
                myAlert.view.tintColor = Colors.green
                myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
                // show the alert
                self.presentViewController(myAlert, animated: true, completion: nil)
                
            }
        }
    }
    
    @IBAction func endChallenge(sender: AnyObject) {
        if self.mode == 0 { //challenge mode
            self.allAnswers[self.currentNumber] = self.selectedAnswers
            if !self.checkUnanswered() {
                let myAlert = UIAlertController(title: "Voulez-vous vraiment terminer le concours ?", message: "Vous ne pourrez plus modifier vos réponses. Vous devez disposer d'une connexion internet pour envoyer vos résultats au serveur.", preferredStyle: UIAlertControllerStyle.Alert)
                myAlert.view.tintColor = Colors.green
                // add "OK" button
                myAlert.addAction(UIAlertAction(title: "Oui, envoyer mes résultats", style: UIAlertActionStyle.Destructive, handler: { (action) -> Void in
                    self.sendResults()
                }))
                myAlert.addAction(UIAlertAction(title: "Non, annuler", style: UIAlertActionStyle.Cancel, handler: nil))
                // show the alert
                self.presentViewController(myAlert, animated: true, completion: nil)
            } else { //alerting if some questions are unanswered
                let myAlert = UIAlertController(title: "Attention, vous n'avez pas répondu à toutes les questions !", message: "Voulez-vous tout de même terminer le concours ? Vous devez disposer d'une connexion internet pour envoyer vos résultats au serveur.", preferredStyle: UIAlertControllerStyle.Alert)
                // add "OK" button
                myAlert.addAction(UIAlertAction(title: "Oui, envoyer mes résultats", style: UIAlertActionStyle.Destructive, handler: { (action) -> Void in
                    self.sendResults()
                }))
                myAlert.addAction(UIAlertAction(title: "Non, annuler", style: UIAlertActionStyle.Cancel, handler: nil))
                // show the alert
                self.presentViewController(myAlert, animated: true, completion: nil)
            }
            
        } else { //correction mode
            let myAlert = UIAlertController(title: "Voulez-vous vraiment quitter ce concours ?", message: "Vous pourrez consulter à nouveau vos résultats et recevoir le classement dès la fin du concours ! Vous ne pourrez cependant plus revoir vos réponses, mais vous pourrez retrouver les questions et leur correction dans entraînement.", preferredStyle: UIAlertControllerStyle.Alert)
            myAlert.view.tintColor = Colors.green
            // add "OK" button
            myAlert.addAction(UIAlertAction(title: "Oui, quitter", style: UIAlertActionStyle.Destructive, handler: { (action) -> Void in
                self.dismissViewControllerAnimated(true, completion: nil)
                
            }))
            myAlert.addAction(UIAlertAction(title: "Non, annuler", style: UIAlertActionStyle.Cancel, handler: nil))
            // show the alert
            self.presentViewController(myAlert, animated: true, completion: nil)
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
                self.currentNumber = (self.currentNumber + 1) % self.questions.count
                self.loadQuestion()
                self.waitBeforeNextQuestion = false
                self.soundAlreadyPlayed = false
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
                self.currentNumber = (self.currentNumber - 1) % self.questions.count
                self.loadQuestion()
                self.waitBeforeNextQuestion = false
                self.soundAlreadyPlayed = false
            }
        }
    }
    
    private func loadQuestions() {
        //applying grey mask
        let frame = CGRect(x: 0, y: 152, width: self.view.bounds.width, height: self.view.bounds.height)
        self.greyMask = UIView(frame: frame)
        self.greyMask.backgroundColor = Colors.greyBackground
        self.greyMask.layer.zPosition = 100
        self.view.addSubview(self.greyMask)
        
        //fetching contest questions
        let questionsRealm = realm.objects(Question).filter("idContest = \(self.contest!.id)")
        for question in questionsRealm {
            self.questions.append(question)
        }
        self.questions.shuffle()
        
        //checking pagination
        if self.questions.count == 1 {
            self.nextButton.enabled = false
            self.previousButton.enabled = false
        } else {
            self.nextButton.enabled = true
            self.previousButton.enabled = false
        }
        
    }
    
    private func loadQuestion() {
        self.greyMask.layer.zPosition = 100
        self.selectedAnswers.removeAll(keepCapacity: false)
        self.sizeAnswerCells.removeAll(keepCapacity: false)
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
        
        print("Question n°\(self.currentQuestion!.id), bonne(s) réponse(s) = \(self.goodAnswers.answersPrepApp())")
        
        //mark button
        if self.mode == 1 {
            if FactoryHistory.getHistory().isQuestionMarked(self.currentQuestion!.id){
                self.markButton.tintColor = Colors.greenLogo
            } else {
                self.markButton.tintColor = UIColor.grayColor()
            }
        } else {
            switch self.currentQuestion!.chapter!.subject!.id {
            case 1 : //biology
                self.markButton.image = UIImage(named: "bioBar")
                self.chapter.backgroundColor = Colors.bio
            case 2 : //physics
                self.markButton.image = UIImage(named: "phyBar")
                self.chapter.backgroundColor = Colors.phy
            case 3 : //chemistry
                self.markButton.image = UIImage(named: "cheBar")
                self.chapter.backgroundColor = Colors.che
            default:
                self.markButton.image = nil
            }
        }
        
        //calc button
        if self.mode == 0 {
            if self.currentQuestion!.calculator {
                self.calc.image = UIImage(named: "calc")
                self.calc.tintColor = UIColor.grayColor()
            } else {
                self.calc.image = UIImage(named: "nocalc")
                self.calc.tintColor = Colors.greenLogo
            }
        }
        
        self.didLoadWording = false
        self.didLoadAnswers = false
        self.didLoadInfos = false
        self.numberOfAnswers = self.currentQuestion!.answers.count
        self.loadWording()
        
        //display the subject
        self.title = self.currentQuestion!.chapter!.subject!.name.uppercaseString
        //display the chapter
        self.chapter.text = "\(self.currentQuestion!.chapter!.subject!.name.capitalizedString) : \(self.currentQuestion!.chapter!.name)"
    }
    
    private func loadWording(){
        self.wording =  UIWebView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 1))
        self.wording.delegate = self
        self.wording.loadHTMLString( self.currentQuestion!.wording, baseURL: self.baseUrl)
        let y: CGFloat = UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation) ? 132 : 152
        let scrollFrame = CGRect(x: 0, y: y, width: self.view.bounds.width, height: self.view.bounds.height-y)
        self.scrollView = UIScrollView(frame: scrollFrame)
        self.scrollView.backgroundColor = Colors.greyBackground
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
        self.submitButton.hidden = false
        self.submitButton.frame.size.width = 100
        self.submitButton.frame.size.height = 40
        self.submitButton.backgroundColor = Colors.green
        self.submitButton.removeFromSuperview()
        self.infos.removeFromSuperview()
        self.wording.removeFromSuperview()
        self.answers.removeFromSuperview()
        self.scrollView!.removeFromSuperview()
    }
    
    func refreshQuestion(){
        //refreshing grey mask
        self.greyMask.removeFromSuperview()
        let frame = CGRect(x: 0, y: 152, width: self.view.bounds.width, height: self.view.bounds.height)
        self.greyMask = UIView(frame: frame)
        self.greyMask.backgroundColor = Colors.greyBackground
        self.greyMask.layer.zPosition = 100
        self.view.addSubview(self.greyMask)
        self.cleanView()
        self.sizeAnswerCells.removeAll(keepCapacity: false)
        self.didLoadWording = false
        self.didLoadAnswers = false
        self.didLoadInfos = false
        self.loadWording()
    }
    
    private func loadInfos(){
        var tableHeight: CGFloat = 0
        for (_,height) in self.sizeAnswerCells {
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
        //adding infos
        self.scrollView.addSubview(self.infos)
        self.scrollView.autoresizingMask = UIViewAutoresizing.FlexibleHeight
        if self.mode == 1 {
            self.submitButton = UIButton(frame: CGRectMake(self.view.bounds.width/2 - 50, self.wording.bounds.size.height + tableHeight + 50 , 100, 40))
            self.submitButton.layer.cornerRadius = 6
            self.submitButton.titleLabel?.font = UIFont(name: "Segoe UI", size: 15)
            self.submitButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            self.submitButton.backgroundColor = Colors.green
            // displaying results & correction if available
            self.showAnswers()
            //resizing the scroll view in order to fit all the elements
            let scrollSize = CGSizeMake(self.view.bounds.width, self.wording.bounds.size.height + tableHeight + 100)
            self.scrollView.contentSize =  scrollSize
            //adding button
            self.scrollView.addSubview(self.submitButton)
        } else {
            //resizing the scroll view in order to fit all the elements
            let scrollSize = CGSizeMake(self.view.bounds.width, self.wording.bounds.size.height + tableHeight + 50)
            self.scrollView.contentSize =  scrollSize
        }
    }
    
    private func showAnswers() {
        
        self.answers.userInteractionEnabled = false
        if self.checkAnswers() == 1 {
            //true
            if !self.soundAlreadyPlayed {
                Sound.playTrack("true")
                self.soundAlreadyPlayed = true
            }
            
            //colouring the results
            for answer in self.goodAnswers {
                let indexPath = NSIndexPath(forRow: answer, inSection: 0)
                let cell = self.answers.cellForRowAtIndexPath(indexPath) as! UITableViewCellAnswer
                cell.number.backgroundColor = Colors.rightAnswer //green
            }
            
        } else {
            //false
            if !self.soundAlreadyPlayed {
                Sound.playTrack("false")
                self.soundAlreadyPlayed = true
            }
            
            //colouring the results
            for answer in self.selectedAnswers {
                let indexPath = NSIndexPath(forRow: answer, inSection: 0)
                let cell = self.answers.cellForRowAtIndexPath(indexPath) as! UITableViewCellAnswer
                cell.number.backgroundColor = Colors.wrongAnswer //red
            }
            for answer in self.goodAnswers {
                let indexPath = NSIndexPath(forRow: answer, inSection: 0)
                if let cell = self.answers.cellForRowAtIndexPath(indexPath) as? UITableViewCellAnswer {
                    cell.number.backgroundColor = Colors.rightAnswer //green
                }
            }
        }
        
        //displaying the correction button IF AVAILABLE
        if self.currentQuestion!.correction != "" {
            self.submitButton.setTitle("Correction", forState: UIControlState.Normal)
            self.submitButton.addTarget(self, action: "showCorrection", forControlEvents: UIControlEvents.TouchUpInside)
        } else {
            self.submitButton.hidden = true
        }
    }
    
    private func computeScore() {
        for i in 0..<self.questions.count {
            
            let historyQuestion = QuestionHistory()
            historyQuestion.id = self.questions[i].id
            historyQuestion.training = false
            if let answers = self.allAnswers[i] {
                self.selectedAnswers = answers
            } else {
                //in case of no answer
                self.selectedAnswers = []
            }
            self.goodAnswers.removeAll(keepCapacity: false)
            var numberAnswer = 0
            for answer in self.questions[i].answers {
                if answer.correct {
                    self.goodAnswers.append(numberAnswer)
                }
                numberAnswer++
            }
            
            if self.checkAnswers() == 1 {
                //true answer
                historyQuestion.success = true
                self.succeeded++
            } else if self.checkAnswers() == 0 {
                //empty anwser
                historyQuestion.success = false
                self.emptyAnswers++
            } else {
                //false answer
                historyQuestion.success = false
            }
            //saving the question result in history
            FactoryHistory.getHistory().addQuestionToHistory(historyQuestion)
        }
        let failed = self.questions.count - self.succeeded - self.emptyAnswers
        let goodAnswer = abs(self.contest!.goodAnswer)
        let badAnswer = -abs(self.contest!.wrongAnswer)
        let emptyAnswer = -abs(self.contest!.noAnswer)
        let goodAnswers = Float(self.succeeded)*goodAnswer
        let wrongAnswers = Float(failed)*(badAnswer)
        let noAnswers = Float(self.emptyAnswers)*emptyAnswer
        self.points = goodAnswers + wrongAnswers + noAnswers
        let maxPoints = Float(self.questions.count) * abs(self.contest!.goodAnswer)
        self.score = Int(floor(self.points / maxPoints * 20))
    }
    
    func showCorrection() {
        //show the correction sheet
        self.submitButton.frame.size.width = 100
        self.submitButton.frame.size.height = 40
        self.submitButton.backgroundColor = Colors.green
        
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
                print("other")
                break
            }
            
        }
    }
    
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
    
    func countdown() {
        if self.timeLeft != 0 {
            self.timeLeft--
            let seconds = Int(floor(self.timeLeft % 60))
            let minutes = Int(floor(self.timeLeft / 60))
            var string = "120"
            if minutes < 1 {
                string = String(format: "%02d", seconds)
            } else {
                string = String(format: "%02d", minutes)
            }
            self.chrono.text = string
        } else {
            self.timeChallengeTimer.invalidate()
            //challenge finished! switch to results mode
            self.allAnswers[self.currentNumber] = self.selectedAnswers
            let myAlert = UIAlertController(title: "Temps écoulé", message: "Le concours est à présent terminé.", preferredStyle: UIAlertControllerStyle.Alert)
            myAlert.view.tintColor = Colors.green
            // add "OK" button
            myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                //contest finished! now we need to send the results
                self.sendResults()
            }))
            // show the alert
            self.presentViewController(myAlert, animated: true, completion: nil)
        }
    }
    
    private func sendResults() {
        //contest finished! switch to results mode and sending results (before displaying them to avoid cheating by killing the app)
        self.computeScore()
        SwiftSpinner.setTitleFont(UIFont(name: "Segoe UI", size: 22.0))
        SwiftSpinner.show("")
        FactorySync.getContestManager().sendResultsContest(self.contest!.id, points: self.points, callback: { (answer, message) -> Void in
            SwiftSpinner.hide()
            if answer {
                FactorySync.getContestManager().saveResultsContest(self.contest!, score: self.score, emptyAnswers: self.emptyAnswers, succeeded: self.succeeded, numberOfQuestions: self.questions.count)
                let myAlert = UIAlertController(title: "Envoi des résultats", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                myAlert.view.tintColor = Colors.green
                //add an "OK" button
                myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
                    //results sent: challenge finished! switch to results mode
                    self.cleanView()
                    self.displayResultsMode()
                }))
                // show the alert
                self.presentViewController(myAlert, animated: true, completion: nil)
            } else {
                let myAlert = UIAlertController(title: "Oups !", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                myAlert.view.tintColor = Colors.green
                //add an "try again" button
                myAlert.addAction(UIAlertAction(title: "Réessayer", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                    self.sendResults()
                }))
                // show the alert
                self.presentViewController(myAlert, animated: true, completion: nil)
            }
        })
    }
    
    func displayResultsMode() {
        //challenge finished! switch to results mode
        print("challenge mode ended, results mode")
        self.mode = 1
        self.chrono.hidden = true
        self.chronoImage.hidden = true
        self.calc.image = UIImage(named: "score")
        self.calc.tintColor = Colors.greenLogo
        self.titleLabel.text = "Correction du concours"
        self.markButton.enabled = true
        self.markButton.image = UIImage(named: "markedBar")
        let myAlert = UIAlertController(title: "Concours terminé", message: "Vous pouvez à présent voir les réponses et les corrections si disponibles et éventuellement mettre certaines questions de côté en les marquant à l'aide du drapeau." , preferredStyle: UIAlertControllerStyle.Alert)
        myAlert.view.tintColor = Colors.green
        myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            self.loadQuestion()
            self.performSegueWithIdentifier("showScore", sender: self)
        }))
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
    }
    
    private func checkAnswers() -> Int {
        if self.selectedAnswers.isEmpty {
            //empty answer
            return 0
        } else {
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
            if result {
                //good answer
                return 1
            } else {
                //wrong answer
                return -1
            }

        }
    }
    
    private func checkUnanswered() -> Bool {
        var result = false
        for (_, answers) in self.allAnswers {
            if answers.isEmpty {
                result = true
                break
            }
        }
        return result
    }
    
    //UITableViewDataSource methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.numberOfAnswers
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("answerCell", forIndexPath: indexPath) as! UITableViewCellAnswer
        // Configure the cell...
        let answerNumber = indexPath.row
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.number.backgroundColor = Colors.unanswered
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
        }
        //retrieving checkmarks if already done
        if self.selectedAnswers.indexOf(answerNumber) != nil {
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
                return 40
            }
            
        } else {
            return 40
        }
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        Sound.playTrack("select")
        _ = indexPath.row
        let cell: UITableViewCellAnswer = tableView.cellForRowAtIndexPath(indexPath) as! UITableViewCellAnswer
        if (cell.accessoryType != UITableViewCellAccessoryType.Checkmark) {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            self.selectedAnswers.append(indexPath.row)
        }
        else
        {
            cell.accessoryType = UITableViewCellAccessoryType.None
            let index = self.selectedAnswers.indexOf(indexPath.row)
            self.selectedAnswers.removeAtIndex(index!)
        }
    }
    
    //UIWebViewDelegate method
    func webViewDidFinishLoad(webView: UIWebView) {
        if (self.sizeAnswerCells.count != self.numberOfAnswers) {
            //Asks the view to calculate and return the size that best fits its subviews.
            let fittingSize = webView.sizeThatFits(CGSizeZero)
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
                    self.infos.backgroundColor = Colors.greyBackground
                    self.greyMask.layer.zPosition = 0
                }
            } else {
                //we have just refreshed the answers table, now we load the Infos webview and the submit button
                self.didLoadAnswers = true
                self.loadInfos()
                
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
        
        if let commentVC = segue.destinationViewController as? CommentViewController {
            commentVC.selectedId = self.currentQuestion!.id
        }
        
        if let scoreVC = segue.destinationViewController as? ScoreContestViewController {
            // Pass the selected object to the new view controller.
            scoreVC.score = self.score
            scoreVC.emptyAnswers = self.emptyAnswers
            scoreVC.succeeded = self.succeeded
            scoreVC.contest = self.contest
            scoreVC.numberOfQuestions = self.questions.count
            scoreVC.reviewMode = self.reviewMode
        }
        
    }
    
}