//
//  ScoreDuoViewController.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 06/09/2015.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import UIKit

class ScoreDuoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {
    
    //properties
    var score = 0
    var lastName = ""
    var firstName = ""
    var nickname = ""
    var animationScore = 0
    var succeeded = 0
    var numberOfQuestions = 0
    var awardPoints = 0
    var statsTopics = ["Questions réussies", "AwardPoints réussites", "AwardPoints assiduité", "Total AwardPoints"]
    var statsData: [String] = []
    var statsDetails: [String] = []
    var statsPics = ["check","stars","puzzle","awardPoint"]
    var scoreTimer = NSTimer()
    var reviewMode = false
    
    
    //@IBOutlets
    @IBOutlet weak var stats: UITableView!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var greenRound: UILabel!
    @IBOutlet weak var titleBar: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var awardPointImage: UIImageView!
    @IBOutlet weak var infoLabel: UILabel!
    
    //app methods
    override func viewDidLoad() {
        super.viewDidLoad()
        //sync
        FactoryHistory.getHistory().sync()
        self.designScoreVC()
        self.loadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.animateAwardPoint()
    }
    
    //@IBAction
    @IBAction func dismiss(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //methods
    private func designScoreVC() {
        self.dismissButton.layer.cornerRadius = 6
        var textTodisplay = " "
        if FactorySync.getConfigManager().loadNicknamePreference() {
            textTodisplay += "\(self.nickname)"
        } else {
            textTodisplay += "\(self.firstName) \(self.lastName)"
        }
        self.view!.backgroundColor = Colors.greyBackground
        self.titleLabel.text = "Défi duo VS\(textTodisplay)"
        self.titleLabel.textColor = UIColor.blackColor()
        self.titleBar.backgroundColor = Colors.greenLogo
        self.infoLabel.text = "Si\(textTodisplay) a répondu au défi, vous recevrez une notification pour comparer vos résultats et recevoir des AwardPoints en bonus (10pts si gagné, 5pts si égalité)."
        self.greenRound.layer.cornerRadius = self.greenRound.layer.bounds.width / 2
        self.greenRound.backgroundColor = UIColor.whiteColor()
        self.greenRound.layer.borderColor = Colors.greenLogo.CGColor
        self.greenRound.layer.borderWidth = 6
        self.greenRound.layer.masksToBounds = true
        self.scoreLabel.textColor = Colors.wrongAnswer
        self.scoreLabel.text = "\(self.animationScore)"
        self.scoreTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("animateScore"), userInfo: nil, repeats: true)
    }
    
    func animateScore() {
        if !self.reviewMode {
            if self.animationScore != self.score {
                self.scoreLabel.text = "\(self.animationScore)"
                if self.animationScore < 10 {
                    self.scoreLabel.textColor = Colors.wrongAnswer
                } else {
                    self.scoreLabel.textColor = Colors.greenLogo
                }
                self.animationScore++
            } else {
                self.scoreLabel.text = "\(self.animationScore)"
                if self.animationScore < 10 {
                    self.scoreLabel.textColor = Colors.wrongAnswer
                } else {
                    self.scoreLabel.textColor = Colors.greenLogo
                }
                self.animationScore = 0
                self.scoreTimer.invalidate()
            }
        }
    }
    
    private func animateAwardPoint() {
        self.awardPointImage.alpha = 1
        self.awardPointImage.hidden = false
        self.awardPointImage.layer.zPosition = 100
        UIView.animateWithDuration(1, animations: { () -> Void in
            self.awardPointImage.alpha = 0
        })
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.toValue = NSNumber(float: 10)
        animation.duration = 1
        animation.repeatCount = 0
        animation.autoreverses = true
        self.awardPointImage.layer.addAnimation(animation, forKey: nil)
    }
    
    private func grammarQuestionString(int: Int) -> String {
        if int < 2 {
            return "question"
        } else {
            return "questions"
        }
    }
    
    private func grammarFailedString(int: Int) -> String {
        if int < 2 {
            return "échouée"
        } else {
            return "échouées"
        }
    }
    
    private func grammarSucceededString(int: Int) -> String {
        if int < 2 {
            return "réussie"
        } else {
            return "réussies"
        }
    }
    
    private func loadData() {
        self.awardPoints = self.numberOfQuestions + 5 * self.succeeded
        //Questions réussies
        self.statsData.append("\(self.succeeded) / \(self.numberOfQuestions)")
        self.statsDetails.append("\(self.succeeded) \(self.grammarQuestionString(self.succeeded)) \(self.grammarSucceededString(self.succeeded)), \(self.numberOfQuestions-self.succeeded) \(self.grammarQuestionString(self.numberOfQuestions-self.succeeded)) \(self.grammarFailedString(self.numberOfQuestions-self.succeeded)) sur un total de \(self.numberOfQuestions) \(self.grammarQuestionString(self.numberOfQuestions)), soit une note de \(self.score) sur 20.")
        //AwardPoints réussites
        self.statsData.append((self.succeeded*5).toStringPoints())
        self.statsDetails.append("5 points par question réussie = 5 pts X \(self.succeeded) \(self.grammarQuestionString(self.succeeded)) \(self.grammarSucceededString(self.succeeded)) = \((self.succeeded*5).toStringPoints())")
        //AwardPoints assiduité
        self.statsData.append(self.numberOfQuestions.toStringPoints())
        self.statsDetails.append("L'assiduité est récompensée ! 1 point par question faite = \(self.numberOfQuestions.toStringPoints())")
        //Total AwardPoints
        self.statsData.append(self.awardPoints.toStringPoints())
        self.statsDetails.append("AwardPoints réussites (\((self.succeeded*5).toStringPoints())) + AwardPoints assiduité (\(self.numberOfQuestions.toStringPoints())) = total AwardPoints (\(self.awardPoints.toStringPoints()))")
        //save scoring
        if !self.reviewMode {
            User.currentUser!.awardPoints += self.awardPoints
            User.currentUser!.saveUser()
            User.currentUser!.updateAwardPoints(User.currentUser!.awardPoints)
        }
    }
    
    //UITableViewDataSource Methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.statsTopics.count
    }
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("stat", forIndexPath: indexPath)
        let image = self.statsPics[indexPath.row]
        cell.imageView!.image = UIImage(named: image)
        cell.textLabel?.textColor = UIColor.blackColor()
        cell.textLabel!.font = UIFont(name: "Segoe UI", size: 18)
        cell.textLabel!.text = self.statsTopics[indexPath.row]
        cell.backgroundColor = Colors.greyBackground
        cell.detailTextLabel!.text = statsData[indexPath.row]
        cell.detailTextLabel!.font = UIFont(name: "Segoe UI", size: 18)
        cell.detailTextLabel!.textColor = Colors.green
        cell.textLabel!.adjustsFontSizeToFitWidth = true
        cell.detailTextLabel!.adjustsFontSizeToFitWidth = true
        cell.textLabel!.font = UIFont(name: "Segoe UI", size: 12)
        cell.tintColor = Colors.green
        return cell
    }
    
    //UITableViewDelegate Methods
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        let myAlert = UIAlertController(title: self.statsTopics[indexPath.row], message: self.statsDetails[indexPath.row] , preferredStyle: UIAlertControllerStyle.Alert)
        myAlert.view.tintColor = Colors.green
        myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        // show the alert
        self.presentViewController(myAlert, animated: true, completion: nil)
    }
    
    
}