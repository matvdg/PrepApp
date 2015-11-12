//
//  ScoreContestViewController.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 11/11/2015.
//  Copyright © 2015 PrepApp. All rights reserved.
//

import UIKit

class ScoreContestViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {
    
    var emptyAnswers = 0
    var score: Int = 0
    var contest: Contest?
    var animationScore = 0
    var animationBonus = 0
    var succeeded = 0
    var numberOfQuestions = 0
    var awardPoints = 0
    var statsTopics = ["Bonnes réponses", "Réponses vides", "Mauvaises réponses", "Total", "AwardPoints réussites", "AwardPoints assiduité", "Total AwardPoints"]
    var statsData: [String] = []
    var statsDetails: [String] = []
    var statsPics = ["true", "empty", "false", "check","stars","puzzle","awardPoint"]
    var scoreTimer = NSTimer()
    
    @IBOutlet weak var stats: UITableView!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var greenRound: UILabel!
    @IBOutlet weak var titleBar: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var awardPointImage: UIImageView!
    
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
    
    @IBAction func dismiss(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func designScoreVC() {
        self.dismissButton.layer.cornerRadius = 6
        self.view!.backgroundColor = colorGreyBackground
        self.titleLabel.text = "Résultats du concours n°\(self.contest!.id)"
        self.titleLabel.textColor = UIColor.whiteColor()
        self.titleBar.backgroundColor = colorGreenLogo
        self.greenRound.layer.cornerRadius = self.greenRound.layer.bounds.width / 2
        self.greenRound.backgroundColor = UIColor.whiteColor()
        self.greenRound.layer.borderColor = colorGreenLogo.CGColor
        self.greenRound.layer.borderWidth = 6
        self.greenRound.layer.masksToBounds = true
        self.scoreLabel.textColor = colorWrongAnswer
        self.scoreLabel.text = "\(self.animationScore)"
        self.scoreTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("animateScore"), userInfo: nil, repeats: true)
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
            print("+ animation")
        } else {
            self.scoreLabel.text = "\(self.animationScore)"
            if self.animationScore < 10 {
                self.scoreLabel.textColor = colorWrongAnswer
            } else {
                self.scoreLabel.textColor = colorGreenLogo
            }
            self.animationScore = 0
            self.scoreTimer.invalidate()
            print("timer invalidate")
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
        let failed = self.numberOfQuestions - self.succeeded - self.emptyAnswers
        let goodAnswers = Float(self.succeeded)*self.contest!.goodAnswer
        let wrongAnswers = Float(failed)*(-self.contest!.wrongAnswer)
        let noAnswers = Float(self.emptyAnswers)*self.contest!.noAnswer
        let total = goodAnswers + wrongAnswers + noAnswers
        let maxPoints = Float(self.numberOfQuestions) * self.contest!.goodAnswer
        //Bonnes réponses
        self.statsData.append(goodAnswers.toStringPoints())
        self.statsDetails.append("\(self.contest!.goodAnswer.toStringPoints()) X \(self.succeeded) = \(goodAnswers.toStringPoints())")
        //Réponses vides
        self.statsData.append(noAnswers.toStringPoints())
        self.statsDetails.append("\(self.contest!.noAnswer.toStringPoints()) X \(self.emptyAnswers) = \(noAnswers.toStringPoints())")
        //Mauvaises réponses
        self.statsData.append(wrongAnswers.toStringPoints())
        self.statsDetails.append("\((-self.contest!.wrongAnswer).toStringPoints()) X \(failed) = \(wrongAnswers.toStringPoints())")
        //Total
        self.statsData.append(total.toStringPoints())
        self.statsDetails.append("\(total.toStringPoints()) sur \(maxPoints.toStringPoints()) ce qui fait une note de \(self.score)/20")
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
        User.currentUser!.awardPoints += self.awardPoints
        User.currentUser!.saveUser()
        User.currentUser!.updateAwardPoints(User.currentUser!.awardPoints)
        
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