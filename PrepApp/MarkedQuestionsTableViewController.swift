//
//  MarkedQuestionsTableViewController.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 15/09/2015.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import UIKit

class MarkedQuestionsTableViewController: UITableViewController {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    var questions = [Question]()
    var isTrainingQuestions = [Bool]()
    var selectedQuestion: Question?
    var selectedIsTrainingQuestion: Bool?

    override func viewDidLoad() {
        super.viewDidLoad()
        //sync
        FactoryHistory.getHistory().sync()
        self.view!.backgroundColor = colorGreyBackground
        if self.revealViewController() != nil {
            self.menuButton.target = self.revealViewController()
            self.menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        self.title = "Questions marquées"
        self.navigationController!.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Segoe UI", size: 20)!]
        self.navigationController!.navigationBar.tintColor = colorGreen
        
        self.loadData()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "logout", name: "failed", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "update", name: "update", object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        SwiftSpinner.hide()
    }
    
    private func loadData() {
        self.questions = FactoryHistory.getHistory().getMarkedQuestions().0
        self.isTrainingQuestions = FactoryHistory.getHistory().getMarkedQuestions().1
        if self.questions.isEmpty {
            self.displayTemplate()
        }
    }
    
    private func displayTemplate() {
        let templateQuestion = Question()
        let templateChapter = Chapter()
        let templateSubject = Subject()
        templateSubject.id = -1
        templateChapter.subject = templateSubject
        templateChapter.name = "Aucune question marquée"
        templateQuestion.wording = "Marquez des questions et revenez ici !"
        templateQuestion.type = -1
        templateQuestion.chapter = templateChapter
        self.questions.append(templateQuestion)
        self.isTrainingQuestions.append(false)
    }
    
    func logout() {
        print("logging out")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func update() {
        // create alert controller
        let myAlert = UIAlertController(title: "Une mise à jour des questions est disponible", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        myAlert.view.tintColor = colorGreen
        // add "later" button
        myAlert.addAction(UIAlertAction(title: "Plus tard", style: UIAlertActionStyle.Cancel, handler: nil))
        // add "update" button
        myAlert.addAction(UIAlertAction(title: "Mettre à jour maintenant", style: UIAlertActionStyle.Destructive, handler: { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        // show the alert
        self.presentViewController(myAlert, animated: true, completion: nil)
    }
    
    private func getImageBySubject(subject: Int) -> UIImage {
        var image = UIImage()
        switch subject {
        case 1 : //biology
            image = UIImage(named: "bioMarked")!
        case 2 : //physics
            image = UIImage(named: "phyMarked")!
        case 3 : //chemistry
            image = UIImage(named: "cheMarked")!
        default :
            image = UIImage(named: "markedBar")!
        }
        return image
    }
    
    private func getModeByType(type: Int) -> String {
        switch type {
        case 0 : //training
            return "Entraînement - "
        case 1 : //solo
            return "Défi solo - "
        case 2 : //duo
            return "Défi duo - "
        case 3 : //contest
            return "Concours - "
        default :
            return ""
        }
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.questions.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("question", forIndexPath: indexPath) 
        let question = self.questions[indexPath.row]
        let isTrainingQuestion = self.isTrainingQuestions[indexPath.row]
        let type = isTrainingQuestion ? 0 : question.type
        let image = self.getImageBySubject(question.chapter!.subject!.id)
        cell.imageView!.image = image
        cell.textLabel?.textColor = UIColor.blackColor()
        cell.textLabel!.text = "\(self.getModeByType(type))\(question.chapter!.name)"
        cell.backgroundColor = colorGreyBackground
        cell.detailTextLabel!.text = question.wording.html2String
        cell.detailTextLabel!.font = UIFont(name: "Segoe UI", size: 12)
        cell.detailTextLabel!.textColor = colorGreen
        cell.textLabel!.adjustsFontSizeToFitWidth = false
        cell.detailTextLabel!.adjustsFontSizeToFitWidth = false
        cell.textLabel!.font = UIFont(name: "Segoe UI", size: 16)
        cell.tintColor = colorGreen
        if question.type == -1 {
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        return cell
    }
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            let question = QuestionHistory()
            Sound.playTrack("notif")
            question.id = self.questions[indexPath.row].id
            FactoryHistory.getHistory().updateQuestionMark(question)
            self.questions.removeAtIndex(indexPath.row)
            self.isTrainingQuestions.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
            if self.questions.isEmpty {
                //create template
                self.displayTemplate()
                let newIndexPath = NSIndexPath(forItem: 0, inSection: 0)
                self.tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Left)
            }
        }
    }
    
//
//    //UITableViewDelegate Methods
//    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 0.01
//    }
    
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        self.selectedQuestion = self.questions[indexPath.row]
        self.selectedIsTrainingQuestion = self.isTrainingQuestions[indexPath.row]
        self.performSegueWithIdentifier("showPreviewQuestion", sender: self)
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let question = self.questions[indexPath.row]
        if question.type != -1 {
            self.selectedQuestion = self.questions[indexPath.row]
            self.performSegueWithIdentifier("showComment", sender: self)
        }
    }

    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        let question = self.questions[indexPath.row]
        if question.type == -1 {
            return UITableViewCellEditingStyle.None
        } else {
            return UITableViewCellEditingStyle.Delete
        }
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        if let previewVC = segue.destinationViewController as? PreviewQuestionViewController {
            // Pass the selected object to the new view controller.
            previewVC.currentQuestion = self.selectedQuestion
            previewVC.currentChapter = self.selectedQuestion!.chapter
            previewVC.currentSubject = self.selectedQuestion!.chapter!.subject
            previewVC.selectedIsTrainingQuestion = self.selectedIsTrainingQuestion
        }
        
        if let commentVC = segue.destinationViewController as? CommentViewController {
            // Pass the selected object to the new view controller.
            commentVC.selectedId = self.selectedQuestion!.id
        }

    }
    

}
