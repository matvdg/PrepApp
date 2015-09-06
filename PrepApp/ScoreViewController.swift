//
//  ScoreViewController.swift
//  PrepApp
//
//  Created by Mikael Vandeginste on 06/09/2015.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import UIKit

class ScoreViewController: UIViewController {
    
    var choice = 0
    var score = 0
    var succeeded = 0
    var numberOfQuestions = 0
    
    
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var succeededLabel: UILabel!
    @IBOutlet weak var greenRound: UILabel!
    @IBOutlet weak var titleBar: UILabel!
    @IBOutlet weak var titleLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
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
        self.greenRound.layer.cornerRadius = 100
        self.greenRound.backgroundColor = UIColor.whiteColor()
        self.greenRound.layer.borderColor = colorGreenLogo.CGColor
        self.greenRound.layer.borderWidth = 6
        self.greenRound.layer.masksToBounds = true
        self.scoreLabel.text = "\(self.score)"
        if self.score < 10 {
            self.scoreLabel.textColor = colorWrongAnswer
        } else {
            self.scoreLabel.textColor = colorRightAnswer
        }
        self.succeededLabel.text = "Questions réussies: \(self.succeeded) / \(self.numberOfQuestions)"
        self.dismissButton.layer.cornerRadius = 6
    }
}