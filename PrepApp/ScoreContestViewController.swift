//
//  ScoreContestViewController.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 11/11/2015.
//  Copyright © 2015 PrepApp. All rights reserved.
//

import UIKit

class ScoreContestViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {
    
    //properties
    var emptyAnswers = 0
    var reviewMode = false
    var score: Int = 0
    var contest: Contest?
    var animationScore = 0
    var animationBonus = 0
    var succeeded = 0
    var numberOfQuestions = 0
    var awardPoints = 0
    var statsTopics = ["Réponses justes", "Réponses vides", "Réponses fausses", "Total", "AwardPoints réussites", "AwardPoints assiduité", "Total AwardPoints"]
    var statsData: [String] = []
    var statsDetails: [String] = []
    var statsPics = ["true", "empty", "false", "check","stars","puzzle","awardPoint"]
    var scoreTimer = NSTimer()
    
    //@IBOutlets
    @IBOutlet weak var stats: UITableView!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var greenRound: UILabel!
    @IBOutlet weak var titleBar: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var awardPointImage: UIImageView!
    
    //app methods
    override func viewDidLoad() {
        super.viewDidLoad()
        //sync
        FactoryHistory.getHistory().sync()
        self.view!.backgroundColor = colorGreyBackground
        self.loadData()
        self.dismissButton.layer.cornerRadius = 6
        self.designScoreVC()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.animateAwardPoint()
    }
    
    
    //methods
    @IBAction func dismiss(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func designScoreVC() {
        self.dismissButton.layer.cornerRadius = 6
        self.view!.backgroundColor = colorGreyBackground
        self.titleLabel.text = "Résultats du concours"
        self.titleLabel.textColor = UIColor.blackColor()
        self.titleBar.backgroundColor = colorGreenLogo
        self.greenRound.layer.cornerRadius = self.greenRound.layer.bounds.width / 2
        self.greenRound.backgroundColor = UIColor.whiteColor()
        self.greenRound.layer.borderColor = colorGreenLogo.CGColor
        self.greenRound.layer.borderWidth = 6
        self.greenRound.layer.masksToBounds = true
        self.scoreLabel.textColor = colorWrongAnswer
        let maxPoints = Float(self.numberOfQuestions) * abs(self.contest!.goodAnswer)
        let min = -abs(self.contest!.wrongAnswer) * Float(self.numberOfQuestions) * Float(20) / maxPoints
        self.animationScore = Int(floor(min))
        self.scoreLabel.text = "\(self.animationScore)"
        self.scoreTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("animateScore"), userInfo: nil, repeats: true)
        if self.reviewMode {
            self.dismissButton.setTitle("OK", forState: UIControlState.Normal)
        }
    }
    
    func animateScore() {
        if self.animationScore != self.score {
            
            self.scoreLabel.text = "\(self.animationScore)"
            if self.animationScore < 10 {
                self.scoreLabel.textColor = colorWrongAnswer
            } else {
                self.scoreLabel.textColor = colorGreenLogo
            }
            self.animationScore++
        } else {
            self.scoreLabel.text = "\(self.animationScore)"
            if self.animationScore < 10 {
                self.scoreLabel.textColor = colorWrongAnswer
            } else {
                self.scoreLabel.textColor = colorGreenLogo
            }
            self.animationScore = 0
            self.scoreTimer.invalidate()
        }
    }
    
    private func animateAwardPoint() {
        if !self.reviewMode {
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
        let failed = self.numberOfQuestions - self.succeeded - self.emptyAnswers
        let goodAnswer = abs(self.contest!.goodAnswer)
        let badAnswer = -abs(self.contest!.wrongAnswer)
        let emptyAnswer = -abs(self.contest!.noAnswer)
        let goodAnswers = Float(self.succeeded)*goodAnswer
        let wrongAnswers = Float(failed)*(badAnswer)
        let noAnswers = Float(self.emptyAnswers)*emptyAnswer
        let total = goodAnswers + wrongAnswers + noAnswers
        let maxPoints = Float(self.numberOfQuestions) * abs(self.contest!.goodAnswer)
        //Bonnes réponses
        self.statsData.append(goodAnswers.toStringPoints())
        self.statsDetails.append("\(goodAnswer.toStringPoints()) X \(self.succeeded) = \(goodAnswers.toStringPoints())")
        //Réponses vides
        self.statsData.append(noAnswers.toStringPoints())
        self.statsDetails.append("\(emptyAnswer.toStringPoints()) X \(self.emptyAnswers) = \(noAnswers.toStringPoints())")
        //Mauvaises réponses
        self.statsData.append(wrongAnswers.toStringPoints())
        self.statsDetails.append("\((badAnswer).toStringPoints()) X \(failed) = \(wrongAnswers.toStringPoints())")
        //Total
        self.statsData.append(total.toStringPoints())
        self.statsDetails.append("\(total.toStringPoints()) sur \(maxPoints.toStringPoints()), soit une note de \(self.score) sur 20.")
        //AwardPoints succeeded
        self.statsData.append((self.succeeded*5).toStringPoints())
        self.statsDetails.append("5 points par question réussie = 5 pts X \(self.succeeded) \(self.grammarQuestionString(self.succeeded)) \(self.grammarSucceededString(self.succeeded)) = \((self.succeeded*5).toStringPoints())")
        //AwardPoints assiduity
        self.statsData.append(self.numberOfQuestions.toStringPoints())
        self.statsDetails.append("L'assiduité est récompensée ! 1 point par question faite = \(self.numberOfQuestions.toStringPoints())")
        //Total AwardPoints
        self.statsData.append(self.awardPoints.toStringPoints())
        self.statsDetails.append("AwardPoints réussites (\((self.succeeded*5).toStringPoints())) + AwardPoints assiduité (\(self.numberOfQuestions.toStringPoints())) = total AwardPoints (\(self.awardPoints.toStringPoints())) Consultez le fil d'actualités après la fin du concours pour voir votre classement et recevoir éventuellement des AwardPoints Bonus !")
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
   
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("stat", forIndexPath: indexPath)
        let image = self.statsPics[indexPath.row]
        cell.imageView!.image = UIImage(named: image)
        cell.textLabel?.textColor = UIColor.blackColor()
        cell.textLabel!.font = UIFont(name: "Segoe UI", size: 18)
        cell.textLabel!.text = self.statsTopics[indexPath.row]
        cell.backgroundColor = colorGreyBackground
        cell.detailTextLabel!.text = statsData[indexPath.row]
        cell.detailTextLabel!.font = UIFont(name: "Segoe UI", size: 18)
        cell.detailTextLabel!.textColor = colorGreen
        cell.textLabel!.adjustsFontSizeToFitWidth = true
        cell.detailTextLabel!.adjustsFontSizeToFitWidth = true
        cell.textLabel!.font = UIFont(name: "Segoe UI", size: 12)
        cell.tintColor = colorGreen
        return cell
    }
    
    //UITableViewDelegate Methods
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        let myAlert = UIAlertController(title: self.statsTopics[indexPath.row], message: self.statsDetails[indexPath.row] , preferredStyle: UIAlertControllerStyle.Alert)
        myAlert.view.tintColor = colorGreen
        myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        // show the alert
        self.presentViewController(myAlert, animated: true, completion: nil)
    }
    
    
}