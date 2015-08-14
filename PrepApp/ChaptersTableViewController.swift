//
//  ChaptersTableViewController.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 23/07/15.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import UIKit
import RealmSwift

class ChaptersTableViewController: UITableViewController, UITableViewDataSource {
    
    var subject: Subject?
    var chaptersRealm: Results<Chapter>?
    var chapters: [Chapter] = []
    var image = ""
    let realm = FactoryRealm.getRealm()

    //app methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadChapters()
        self.navigationController!.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Segoe UI", size: 20)!]
        switch (self.subject!.name) {
        case "physique" :
            self.image = "phyBar"
        case "chimie" :
            self.image = "chiBar"
        case "biologie" :
            self.image = "bioBar"
        default :
            self.image = ""
        }
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: image)!, forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.translucent = true

    }
    
    override func viewDidAppear(animated: Bool) {
        
        if User.authenticated == false {
            NSUserDefaults.standardUserDefaults().removeObjectForKey("user")
            NSUserDefaults.standardUserDefaults().synchronize()
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        // Return the number of rows in the section.
        return self.chapters.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("chapter", forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...
        cell.textLabel?.font = UIFont(name: "Segoe UI", size: 14)
        cell.textLabel?.text = "\(self.chapters[indexPath.row].number) : \(self.chapters[indexPath.row].name)"
        return cell
    }
    
    //methods
    private func loadChapters() {
        self.chaptersRealm = self.realm.objects(Chapter).filter("subject == %@", subject!)
        for chapter in self.chaptersRealm! {
            if !self.isChapterEmpty(chapter){
                self.chapters.append(chapter)
            }
        }
    }
    
    private func isChapterEmpty(chapter: Chapter) -> Bool {
        
        var tempQuestions = [Question]()
        //fetching training questions
        var questionsRealm = realm.objects(Question).filter("chapter = %@ AND type = 0", chapter)
        for question in questionsRealm {
            tempQuestions.append(question)
        }
        
        //fetching solo questions already DONE
        questionsRealm = realm.objects(Question).filter("chapter = %@ AND type = 1", chapter)
        for question in questionsRealm {
            if History.isQuestionDone(question.id){
                tempQuestions.append(question)
            }
        }
        
        //fetching duo questions already DONE
        questionsRealm = realm.objects(Question).filter("chapter = %@ AND type = 2", chapter)
        for question in questionsRealm {
            if History.isQuestionDone(question.id){
                tempQuestions.append(question)
            }
            
        }
        if tempQuestions.count == 0 {
            return true
        } else {
            return false
        }
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        var questionVC = segue.destinationViewController as! QuestionViewController
        // Pass the selected object to the new view controller.
        
        if let indexPath = self.tableView.indexPathForSelectedRow() {
            let selectedChapter = chapters[indexPath.row]
            questionVC.currentChapter = selectedChapter
            questionVC.currentSubject = subject
        }

    }
    




}
