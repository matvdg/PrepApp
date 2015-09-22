//
//  MarkedQuestionsTableViewController.swift
//  PrepApp
//
//  Created by Mikael Vandeginste on 15/09/2015.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import UIKit

class MarkedQuestionsTableViewController: UITableViewController {
    
    var questions = [Question]()
    var isTrainingQuestions = [Bool]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.questions = FactoryHistory.getHistory().getMarkedQuestions().0
        self.isTrainingQuestions = FactoryHistory.getHistory().getMarkedQuestions().1
        if self.questions.isEmpty {
            var templateQuestion = Question()
            var templateChapter = Chapter()
            var templateSubject = Subject()
            templateSubject.id = -1
            templateChapter.subject = templateSubject
            templateChapter.name = "Aucune question marquée"
            templateQuestion.wording = "Marquez des questions et revenez ici !"
            templateQuestion.type = -1
            templateQuestion.chapter = templateChapter
            self.questions.append(templateQuestion)
            self.isTrainingQuestions.append(false)
        }
        self.title = "Questions marquées"
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "logout", name: "failed", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "update", name: "update", object: nil)
    }
    
    func logout() {
        println("logging out")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func update() {
        // create alert controller
        let myAlert = UIAlertController(title: "Une mise à jour des questions est disponible", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        myAlert.view.tintColor = colorGreenAppButtons
        // add an "later" button
        myAlert.addAction(UIAlertAction(title: "Plus tard", style: UIAlertActionStyle.Default, handler: nil))
        // add an "update" button
        myAlert.addAction(UIAlertAction(title: "Mettre à jour maintenant", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        // show the alert
        self.presentViewController(myAlert, animated: true, completion: nil)
    }
    
    func getImageBySubject(subject: Int) -> UIImage {
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
    
    func getModeByType(type: Int) -> String {
        switch type {
        case 0 : //training
            return " - Entraînement"
        case 1 : //solo
            return " - Défi solo"
        case 2 : //duo
            return " - Défi duo"
        case 3 : //contest
            return " - Concours"
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
        let cell = tableView.dequeueReusableCellWithIdentifier("question", forIndexPath: indexPath) as! UITableViewCell
        let question = self.questions[indexPath.row]
        let isTrainingQuestion = self.isTrainingQuestions[indexPath.row]
        let type = isTrainingQuestion ? 0 : question.type
        var image = self.getImageBySubject(question.chapter!.subject!.id)
        cell.imageView!.image = image
        cell.textLabel?.textColor = UIColor.blackColor()
        cell.textLabel!.text = "\(question.chapter!.name)\(self.getModeByType(type))"
        cell.backgroundColor = colorGreyBackground
        cell.detailTextLabel!.text = question.wording.html2String
        cell.detailTextLabel!.font = UIFont(name: "Segoe UI", size: 12)
        cell.detailTextLabel!.textColor = colorGreenAppButtons
        cell.textLabel!.adjustsFontSizeToFitWidth = true
        cell.detailTextLabel!.adjustsFontSizeToFitWidth = false
        cell.textLabel!.font = UIFont(name: "Segoe UI", size: 16)
        cell.tintColor = colorGreenAppButtons
        return cell
    }
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            var question = QuestionHistory()
            Sound.playTrack("calc")
            question.id = self.questions[indexPath.row].id
            FactoryHistory.getHistory().updateQuestionMark(question)
            self.questions.removeAtIndex(indexPath.row)
            self.isTrainingQuestions.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    

    //UITableViewDelegate Methods
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        

    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    

}
