//
//  ScoreViewController.swift
//  PrepApp
//
//  Created by Mikael Vandeginste on 06/09/2015.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import UIKit

class ScoreViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {
    
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
    var statsPics = ["check","stars","puzzle","bonus","awardPoint"]
    var scoreTimer = NSTimer()

    
    
    @IBOutlet weak var stats: UITableView!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var greenRound: UILabel!
    @IBOutlet weak var titleBar: UILabel!
    @IBOutlet weak var titleLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadData()
        self.dismissButton.layer.cornerRadius = 6
        self.designScore()
        self.designSoloChallengeTitleBar()
    }


    @IBAction func dismiss(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func designSoloChallengeTitleBar() {
        switch self.choice {
            
        case 1: //biology
            self.titleLabel.text = "Défi solo Biologie"
            self.titleLabel.textColor = UIColor.blackColor()
            self.titleBar.backgroundColor = colorBio
            
        case 2: //physics
            self.titleLabel.text = "Défi solo Physique"
            self.titleLabel.textColor = UIColor.blackColor()
            self.titleBar.backgroundColor = colorPhy
            
            
        case 3: //chemistry
            self.titleLabel.text = "Défi solo Chimie"
            self.titleLabel.textColor = UIColor.blackColor()
            self.titleBar.backgroundColor = colorChe
            
            
        case 4: //bioPhy
            self.titleLabel.text = "Défi solo Biologie/Physique"
            self.titleLabel.textColor = UIColor.blackColor()
            self.titleBar.backgroundColor = colorBioPhy
            
            
        case 5: //bioChe
            self.titleLabel.text = "Défi solo Biologie/Chimie"
            self.titleLabel.textColor = UIColor.blackColor()
            self.titleBar.backgroundColor = colorBioChe
            
        case 6: //chePhy
            self.titleLabel.text = "Défi solo Chimie/Physique"
            self.titleLabel.textColor = UIColor.whiteColor()
            self.titleBar.backgroundColor = colorChePhy
            
        case 7: //all
            self.titleLabel.text = "Défi solo Biologie/Physique/Chimie"
            self.titleLabel.textColor = UIColor.whiteColor()
            self.titleBar.backgroundColor = colorGreenLogo
            
        default:
            println("default")
        }
        
    }
    
    private func designScore() {
        self.greenRound.layer.cornerRadius = self.greenRound.layer.bounds.width / 2
        self.greenRound.backgroundColor = UIColor.whiteColor()
        self.greenRound.layer.borderColor = colorGreenLogo.CGColor
        self.greenRound.layer.borderWidth = 6
        self.greenRound.layer.masksToBounds = true
        self.scoreLabel.textColor = colorWrongAnswer
        self.scoreLabel.text = "\(self.animationScore)"
        self.scoreTimer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: Selector("animateScore"), userInfo: nil, repeats: true)
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
    
    private func loadData() {
        self.awardPointsBonus = ((self.score - 10) > 1) ? (self.score - 10) : 0
        self.awardPoints = self.awardPointsBonus + self.numberOfQuestions + 5*self.succeeded
        //"Questions réussies", "AwardPoints réussites", "AwardPoints assiduité",  "AwardPoints bonus", "Total AwardPoints"
        self.statsData.append("\(self.succeeded) / \(self.numberOfQuestions)")
        self.statsData.append("5pts 𝗫 \(self.succeeded) = \((self.succeeded*5).toStringPoints())")
        self.statsData.append("1pt 𝗫 \(self.numberOfQuestions) = \(self.numberOfQuestions.toStringPoints())")
        self.statsData.append(self.awardPointsBonus.toStringPoints())
        self.statsData.append(self.awardPoints.toStringPoints())
        //save scoring
        User.currentUser!.awardPointsApp += self.awardPoints
        User.currentUser!.saveUser()

    }
    
    //UITableViewDataSource Methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("stat", forIndexPath: indexPath) as! UITableViewCell
        var image = self.statsPics[indexPath.row]
        cell.imageView!.image = UIImage(named: image)
        cell.textLabel?.textColor = UIColor.blackColor()
        cell.textLabel!.font = UIFont(name: "Segoe UI", size: 18)
        cell.textLabel!.text = self.statsTopics[indexPath.row]
        cell.backgroundColor = colorGreyBackground
        cell.detailTextLabel!.text = statsData[indexPath.row]
        cell.detailTextLabel!.font = UIFont(name: "Segoe UI", size: 18)
        cell.detailTextLabel!.textColor = colorGreenAppButtons
        cell.textLabel!.adjustsFontSizeToFitWidth = true
        cell.detailTextLabel!.adjustsFontSizeToFitWidth = true
        cell.textLabel!.font = UIFont(name: "Segoe UI", size: 12)
        return cell
    }
    //UITableViewDelegate Methods
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }


}