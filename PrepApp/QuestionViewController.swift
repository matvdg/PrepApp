//
//  QuestionViewController.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 23/07/15.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import UIKit
import RealmSwift
import QuartzCore

class QuestionViewController: UIViewController,
UITableViewDataSource,
UITableViewDelegate,
UIPopoverPresentationControllerDelegate,
ChoiceQuestionViewControllerDelegate,
UIWebViewDelegate,
UIAdaptivePresentationControllerDelegate  {
    
    //properties
    let realm = FactoryRealm.getRealm()
    var mode = 0 //0 = training 1 = results
    var questions: [Question] = []
    var currentChapter: Chapter?
    var currentSubject: Subject?
    var currentNumber: Int = 0
    var currentQuestion: Question?
    var goodAnswers: [Int] = []
    var selectedAnswers: [Int] = []
    var didLoadWording = false
    var didLoadAnswers = false
    var didLoadInfos = false
    var sizeAnswerCells: [Int:CGFloat] = [:]
    var numberOfAnswers = 0
    var animatingAwardPointTimer = NSTimer()
    var stateAnimationAwardPoint = 0
    var waitBeforeNextQuestion: Bool = false
    var choiceFilter = 0 // 0=ALL 1=FAILED 2=SUCCEEDED 3=NEW 4=MARKED 5=SOLO 6=DUO 7=CONTEST

    let baseUrl = NSURL(fileURLWithPath: FactorySync.path, isDirectory: true)
    
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
        self.title = "Entraînement - \(self.currentSubject!.name.capitalizedString)"
        self.navigationController!.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Segoe UI", size: 20)!]
        self.navigationController!.navigationBar.tintColor = Colors.greenLogo
        //display the chapter
        self.chapter.text = "Chapitre \(self.currentChapter!.number) : \(self.currentChapter!.name)"
        //load the questions
        self.loadQuestions()
        //display the first question
        self.loadQuestion()
        
        
    }
    
    //@IBOutlets properties
    @IBOutlet weak var chapter: UILabel!
    @IBOutlet weak var questionNumber: UIBarButtonItem!
    @IBOutlet weak var calc: UIBarButtonItem!
    @IBOutlet weak var nextButton: UIBarButtonItem!
    @IBOutlet weak var previousButton: UIBarButtonItem!
    @IBOutlet weak var awardPoint: UILabel!
    @IBOutlet weak var awardPointImage: UIImageView!
    
    //@IBActions methods
    @IBAction func previous(sender: AnyObject) {
        self.goPrevious()
    }
    
    @IBAction func next(sender: AnyObject) {
        self.goNext()
    }
    
    @IBAction func calcPopUp(sender: AnyObject) {
        let message = self.questions[self.currentNumber].calculator ? "Calculatrice autorisée" : "Calculatrice interdite"
        self.questions[self.currentNumber].calculator ? Sound.playTrack("notif") : Sound.playTrack("nocalc")
        // create alert controller
        let myAlert = UIAlertController(title: message, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        myAlert.view.tintColor = Colors.green
        // add "OK" button
        myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        // show the alert
        self.presentViewController(myAlert, animated: true, completion: nil)

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
                message = "Retrouvez tous les marquages dans la section \"Marquages\""
                let myAlert = UIAlertController(title: title, message: message , preferredStyle: UIAlertControllerStyle.Alert)
                myAlert.view.tintColor = Colors.green
                let historyQuestion = QuestionHistory()
                historyQuestion.id = self.currentQuestion!.id
                historyQuestion.marked = true
                FactoryHistory.getHistory().updateQuestionMark(historyQuestion)
                myAlert.addAction(UIAlertAction(title: "Supprimer le marquage", style: UIAlertActionStyle.Destructive, handler: { (action) -> Void in
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
                Sound.playTrack("error")
                title = "Oups !"
                message = "Vous devez d'abord répondre à la question pour pouvoir la marquer"
                let myAlert = UIAlertController(title: title, message: message , preferredStyle: UIAlertControllerStyle.Alert)
                myAlert.view.tintColor = Colors.green
                myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                // show the alert
                self.presentViewController(myAlert, animated: true, completion: nil)

            }
        }
    }
    
    @IBAction func questionPopOver(sender: AnyObject) {
        let storyboard : UIStoryboard = UIStoryboard(
            name: "Main",
            bundle: nil)
        let choiceQuestion: ChoiceQuestionViewController = storyboard.instantiateViewControllerWithIdentifier("ChoiceQuestionViewController") as! ChoiceQuestionViewController
        choiceQuestion.modalPresentationStyle = .Popover
        choiceQuestion.preferredContentSize = CGSizeMake(200, 240)
        choiceQuestion.delegate = self
        choiceQuestion.choiceFilter = self.choiceFilter
        choiceQuestion.currentChapter = self.currentChapter
        let popoverChoiceQuestionViewController = choiceQuestion.popoverPresentationController
        popoverChoiceQuestionViewController?.permittedArrowDirections = UIPopoverArrowDirection.Up
        popoverChoiceQuestionViewController?.delegate = self
        popoverChoiceQuestionViewController?.barButtonItem = sender as? UIBarButtonItem
        presentViewController(
            choiceQuestion,
            animated: true,
            completion: nil)
    }
    
    
    //methods
    private func goNext() {
        self.mode = 0
        if self.currentNumber == 0 {
            self.previousButton.enabled = true
        }
        if self.currentNumber + 2 == self.questions.count {
            self.nextButton.enabled = false
        }
        if !self.waitBeforeNextQuestion {
            Sound.playTrack("next")
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
        self.mode = 0
        if self.currentNumber + 1 == self.questions.count {
            self.nextButton.enabled = true
        }
        if self.currentNumber - 1 == 0 {
            self.previousButton.enabled = false
        }
        if !self.waitBeforeNextQuestion {
            Sound.playTrack("next")
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
        self.greyMask.backgroundColor = Colors.greyBackground
        self.greyMask.layer.zPosition = 100
        self.view.addSubview(self.greyMask)

        var tempQuestions = [Question]()
        //fetching training questions
        var questionsRealm = realm.objects(Question).filter("chapter = %@ AND type = 0", currentChapter!)
        for question in questionsRealm {
            tempQuestions.append(question)
        }
        //fetching solo questions already DONE
        questionsRealm = realm.objects(Question).filter("chapter = %@ AND type = 1", currentChapter!)
        for question in questionsRealm {
            if FactoryHistory.getHistory().isQuestionDone(question.id){
                tempQuestions.append(question)
            }
        }
        //fetching duo questions already DONE
        questionsRealm = realm.objects(Question).filter("chapter = %@ AND type = 2", currentChapter!)
        for question in questionsRealm {
            if FactoryHistory.getHistory().isQuestionDone(question.id){
                tempQuestions.append(question)
            }
        }
        //fetching contest questions already DONE
        questionsRealm = realm.objects(Question).filter("chapter = %@ AND type = 3", currentChapter!)
        for question in questionsRealm {
            if FactoryHistory.getHistory().isQuestionDone(question.id){
                tempQuestions.append(question)
            }
        }
        //now applying the filter choosen by user
        // 0=ALL 1=FAILED 2=SUCCEEDED 3=NEW 4=MARKED 5=SOLO 6=DUO 7=CONTEST
        switch self.choiceFilter {
        case 0: //ALL
            self.questions = tempQuestions
        case 1: //FAILED
            for question in tempQuestions {
                if FactoryHistory.getHistory().isQuestionFailed(question.id){
                    self.questions.append(question)
                }
            }
        case 2: //SUCCEEDED
            for question in tempQuestions {
                if FactoryHistory.getHistory().isQuestionSuccessed(question.id){
                    self.questions.append(question)
                }
            }
        case 3: //NEW
            for question in tempQuestions {
                if FactoryHistory.getHistory().isQuestionNew(question.id){
                    self.questions.append(question)
                }
            }
        case 4: //MARKED
            for question in tempQuestions {
                if FactoryHistory.getHistory().isQuestionMarked(question.id){
                    self.questions.append(question)
                }
            }
        case 5: //SOLO
            for question in tempQuestions {
                if FactoryHistory.getHistory().isQuestionFromSolo(question.id){
                    self.questions.append(question)
                }
            }
        case 6: //DUO
            for question in tempQuestions {
                if FactoryHistory.getHistory().isQuestionFromDuo(question.id){
                    self.questions.append(question)
                }
            }
        case 7: //CONTEST
            for question in tempQuestions {
                if FactoryHistory.getHistory().isQuestionFromContest(question.id){
                    self.questions.append(question)
                }
            }
        default:
            print("default")
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
        print("Question n°\(self.currentQuestion!.id), bonne(s) réponse(s) = \(self.goodAnswers.answersPrepApp())")
        self.calc.image = ( self.currentQuestion!.calculator ? UIImage(named: "notif") : UIImage(named: "nocalc"))
        self.didLoadWording = false
        self.didLoadAnswers = false
        self.didLoadInfos = false
        self.numberOfAnswers = self.currentQuestion!.answers.count
        self.loadWording()
        
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

    private func refreshView(){
        self.cleanView()
        self.numberOfAnswers = 0
        self.sizeAnswerCells.removeAll(keepCapacity: false)
        self.currentNumber = 0
        self.nextButton.enabled = true
        self.previousButton.enabled = false
        self.questions.removeAll(keepCapacity: false)
        //load the questions
        self.loadQuestions()
        //display the first question
        self.loadQuestion()
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
    
    private func loadSubmit(){
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
        self.submitButton = UIButton(frame: CGRectMake(self.view.bounds.width/2 - 50, self.wording.bounds.size.height + tableHeight + 50 , 100, 40))
        self.submitButton.setTitle("VALIDER", forState: .Normal)
        self.submitButton.layer.cornerRadius = 6
        self.submitButton.titleLabel?.font = UIFont(name: "Segoe UI", size: 15)
        self.submitButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.submitButton.backgroundColor = Colors.green
        
        //resizing the scroll view in order to fit all the elements
        let scrollSize = CGSizeMake(self.view.bounds.width, self.wording.bounds.size.height + tableHeight + 100)
        self.scrollView.autoresizingMask = UIViewAutoresizing.FlexibleHeight
        self.scrollView.contentSize =  scrollSize
        //adding infos, button and action
        self.submitButton.addTarget(self, action: "submit", forControlEvents: UIControlEvents.TouchUpInside)
        self.scrollView.addSubview(self.infos)
        self.scrollView.addSubview(self.submitButton)
        if self.mode == 1 {
            self.submit()
        }
        
    }
    
    func submit() {
        if self.selectedAnswers.isEmpty {
            if self.mode == 0 {
                Sound.playTrack("error")
            }
            self.mode = 1
            // create alert controller
            let myAlert = UIAlertController(title: "Vous devez sélectionner au moins une réponse !", message: "Touchez les cases pour cocher une ou plusieurs réponses", preferredStyle: UIAlertControllerStyle.Alert)
            myAlert.view.tintColor = Colors.green
            // add "OK" button
            myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            // show the alert
            self.presentViewController(myAlert, animated: true, completion: nil)
        } else {
            let historyQuestion = QuestionHistory()
            self.answers.userInteractionEnabled = false
            historyQuestion.id = self.currentQuestion!.id
            historyQuestion.training = true
            if self.checkAnswers() {
                
                //true
                if self.mode == 0 {
                    Sound.playTrack("true")
                }
                self.mode = 1
                historyQuestion.success = true
                //colouring the results
                for answer in self.goodAnswers {
                    let indexPath = NSIndexPath(forRow: answer, inSection: 0)
                    let cell = self.answers.cellForRowAtIndexPath(indexPath) as! UITableViewCellAnswer
                    cell.number.backgroundColor = Colors.rightAnswer
                    //green
                }
                //generating AwardPoint 5 + 1 assiduity = +6
                if FactoryHistory.getHistory().isQuestionNew(self.currentQuestion!.id) {
                    self.animateAwardPoint(6)
                }
                
            } else {
                //false
                historyQuestion.success = false
                Sound.playTrack("false")
                 //colouring the results
                for answer in self.selectedAnswers {
                    let indexPath = NSIndexPath(forRow: answer, inSection: 0)
                    let cell = self.answers.cellForRowAtIndexPath(indexPath) as! UITableViewCellAnswer
                    cell.number.backgroundColor = Colors.wrongAnswer
                    //red
                }
                for answer in self.goodAnswers {
                    let indexPath = NSIndexPath(forRow: answer, inSection: 0)
                    if let cell = self.answers.cellForRowAtIndexPath(indexPath) as? UITableViewCellAnswer {
                        cell.number.backgroundColor = Colors.rightAnswer
                        //green
                        var notSelected = true
                        for selectedAnswer in self.selectedAnswers {
                            if selectedAnswer == answer {
                                notSelected = false
                            }
                        }
                        if notSelected {
                            cell.number.backgroundColor = Colors.wrongAnswer
                            //red
                        }
                    }
                }
                //generating AwardPoint assiduity +1
                if FactoryHistory.getHistory().isQuestionNew(self.currentQuestion!.id) {
                    self.animateAwardPoint(1)
                } else {
                    //generating AwardPoint double assiduity +1
                    if FactoryHistory.getHistory().isQuestionNewInTraining(self.currentQuestion!.id) {
                        self.animateAwardPoint(1)
                    }
                }
            }
            //saving the question result in history
            FactoryHistory.getHistory().addQuestionToHistory(historyQuestion)
            //displaying the correction button IF AVAILABLE
            if self.currentQuestion!.correction != "" {
                self.submitButton.setTitle("Correction", forState: UIControlState.Normal)
                self.submitButton.removeTarget(self, action: "submit", forControlEvents: UIControlEvents.TouchUpInside)
                self.submitButton.addTarget(self, action: "showCorrection", forControlEvents: UIControlEvents.TouchUpInside)
            } else {
                self.submitButton.hidden = true
            }
        }
    }
    
    func animateAwardPoint(awardPoints: Int) {
        User.currentUser!.awardPoints += awardPoints
        User.currentUser!.saveUser()
        User.currentUser!.updateAwardPoints(User.currentUser!.awardPoints)
        self.awardPointImage.alpha = 1
        self.awardPoint.alpha = 1
        self.awardPoint.text = awardPoints.toStringPoints()
        self.awardPoint.font = UIFont(name: "Segoe UI", size: 20)
        self.awardPoint.hidden = false
        self.awardPointImage.hidden = false
        self.awardPoint.layer.zPosition = 10
        self.awardPointImage.layer.zPosition = 10
        UIView.animateWithDuration(1, animations: { () -> Void in
            self.awardPoint.alpha = 0
            self.awardPointImage.alpha = 0
        })
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.toValue = NSNumber(float: 10)
        animation.duration = 1
        animation.repeatCount = 0
        animation.autoreverses = true
        self.awardPoint.layer.addAnimation(animation, forKey: nil)
        self.awardPointImage.layer.addAnimation(animation, forKey: nil)
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
    
    //ChoiceQuestionViewControllerDelegate method
    func applyChoice(choice: Int){
        self.choiceFilter = choice
        self.refreshView()
        Sound.playTrack("next")
    }

    //UIAdaptivePresentationControllerDelegate method
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
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
        
        if let commentVC = segue.destinationViewController as? CommentViewController {
            commentVC.selectedId = self.currentQuestion!.id
        }
    }
    
}



    

