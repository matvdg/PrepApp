//
//  ScoreSoloViewController.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 06/09/2015.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import UIKit

class ScoreSoloViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {
    
    //properties
    var choice = 0
    var score = 0
    var animationScore = 0
    var animationBonus = 0
    var succeeded = 0
    var numberOfQuestions = 0
    var awardPoints = 0
    var awardPointsBonus = 0
    var statsTopics = ["Questions réussies", "AwardPoints réussites", "AwardPoints assiduité",  "AwardPoints bonus", "Total AwardPoints"]
    var statsData: [String] = []
    var statsDetails: [String] = []
    var statsPics = ["check","stars","puzzle","bonus","awardPoint"]
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

    //app methods
    override func viewDidLoad() {
        super.viewDidLoad()
        //sync
        FactoryHistory.getHistory().sync()
        self.view!.backgroundColor = Colors.greyBackground
        self.loadData()
        self.dismissButton.layer.cornerRadius = 6
        self.designScore()
        self.designSoloChallengeTitleBar()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.animateAwardPoint()
    }
    
    //@IBAction
    @IBAction func dismiss(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    //methods
    private func designSoloChallengeTitleBar() {
        switch self.choice {
            
        case 1: //biology
            self.titleLabel.text = "Défi solo Biologie"
            self.titleLabel.textColor = UIColor.blackColor()
            self.titleBar.backgroundColor = Colors.bio
            
        case 2: //physics
            self.titleLabel.text = "Défi solo Physique"
            self.titleLabel.textColor = UIColor.blackColor()
            self.titleBar.backgroundColor = Colors.phy
            
            
        case 3: //chemistry
            self.titleLabel.text = "Défi solo Chimie"
            self.titleLabel.textColor = UIColor.blackColor()
            self.titleBar.backgroundColor = Colors.che
            
            
        case 4: //bioPhy
            self.titleLabel.text = "Défi solo Biologie/Physique"
            self.titleLabel.textColor = UIColor.blackColor()
            self.titleBar.backgroundColor = Colors.bioPhy
            
            
        case 5: //bioChe
            self.titleLabel.text = "Défi solo Biologie/Chimie"
            self.titleLabel.textColor = UIColor.blackColor()
            self.titleBar.backgroundColor = Colors.bioChe
            
        case 6: //chePhy
            self.titleLabel.text = "Défi solo Chimie/Physique"
            self.titleLabel.textColor = UIColor.blackColor()
            self.titleBar.backgroundColor = Colors.chePhy
            
        case 7: //all
            self.titleLabel.text = "Défi solo Biologie/Physique/Chimie"
            self.titleLabel.textColor = UIColor.blackColor()
            self.titleBar.backgroundColor = Colors.greenLogo
            
        default:
            print("default")
        }
        
    }
    
    private func designScore() {
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
        self.awardPointsBonus = (((self.score - 10) > 1) ? (self.score - 10) : 0) * 2
        self.awardPoints = self.awardPointsBonus + self.numberOfQuestions + 5 * self.succeeded
        //Questions succeeded
        self.statsData.append("\(self.succeeded) / \(self.numberOfQuestions)")
        self.statsDetails.append("\(self.succeeded) \(self.grammarQuestionString(self.succeeded)) \(self.grammarSucceededString(self.succeeded)), \(self.numberOfQuestions-self.succeeded) \(self.grammarQuestionString(self.numberOfQuestions-self.succeeded)) \(self.grammarFailedString(self.numberOfQuestions-self.succeeded)) sur un total de \(self.numberOfQuestions) \(self.grammarQuestionString(self.numberOfQuestions)), soit une note de \(self.score) sur 20.")
        //AwardPoints succeeded
        self.statsData.append((self.succeeded*5).toStringPoints())
        self.statsDetails.append("5 points par question réussie = 5 pts X \(self.succeeded) \(self.grammarQuestionString(self.succeeded)) \(self.grammarSucceededString(self.succeeded)) = \((self.succeeded*5).toStringPoints())")
        //AwardPoints assiduity
        self.statsData.append(self.numberOfQuestions.toStringPoints())
        self.statsDetails.append("L'assiduité est récompensée ! 1 point par question faite = \(self.numberOfQuestions.toStringPoints())")
        //AwardPoints Bonus
        self.statsData.append(self.awardPointsBonus.toStringPoints())
        self.statsDetails.append("Tous les points au dessus de la note 10/20 vous rapportent deux AwardPoints en bonus. Vous gagnez \(self.awardPointsBonus.toStringPoints()).")
        //Total AwardPoints
        self.statsData.append(self.awardPoints.toStringPoints())
        self.statsDetails.append("AwardPoints réussites (\((self.succeeded*5).toStringPoints())) + AwardPoints assiduité (\(self.numberOfQuestions.toStringPoints())) + AwardPoints bonus (\(self.awardPointsBonus.toStringPoints())) = total AwardPoints (\(self.awardPoints.toStringPoints()))")
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