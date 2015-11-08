//
//  ResultsDuoViewController.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 07/11/2015.
//  Copyright © 2015 PrepApp. All rights reserved.
//

import UIKit

class ResultsDuoViewController: UIViewController {
    
    //properties
    var resultsDuo: [ResultDuo]?
    var resultDuo: ResultDuo?
    var scoreTimerA = NSTimer()
    var scoreTimerB = NSTimer()
    var animationScoreA = 0
    var animationScoreB = 0
    var scorePlayerA: Int = 0
    var scorePlayerB: Int = 0
    var awardPoints = 0
    var realm = FactoryRealm.getRealm()
    
    //@IBOutlets
    @IBOutlet weak var titleBar: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var playerA: UILabel!
    @IBOutlet weak var playerB: UILabel!
    @IBOutlet weak var greenRoundA: UILabel!
    @IBOutlet weak var greenRoundB: UILabel!
    @IBOutlet weak var scoreA: UILabel!
    @IBOutlet weak var scoreB: UILabel!
    @IBOutlet weak var bonusA: UILabel!
    @IBOutlet weak var bonusB: UILabel!
    @IBOutlet weak var designButtonDismiss: UIButton!
    @IBOutlet weak var awardPointImage: UIImageView!
    
    //@IBAction
    @IBAction func dismiss(sender: AnyObject) {
        let myAlert = UIAlertController(title: "Voulez-vous vraiment quitter ?", message: "Cette page ne pourra plus être consultée", preferredStyle: UIAlertControllerStyle.Alert)
        myAlert.view.tintColor = colorGreen
        // add buttons
        myAlert.addAction(UIAlertAction(title: "NON", style: UIAlertActionStyle.Default, handler: nil))
        myAlert.addAction(UIAlertAction(title: "OUI", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            if self.resultsDuo!.count == 1 {
                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                self.resultsDuo!.removeFirst()
                self.resultDuo = self.resultsDuo![0]
                self.loadData()
                self.designScore()
                self.titleLabel.text = "Résultat du défi duo n°\(self.resultDuo!.idDuo)"
            }
            
        }))
        // show the alert
        self.presentViewController(myAlert, animated: true, completion: nil)
    }

    //app methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.resultDuo = self.resultsDuo![0]
        //sync
        FactoryHistory.getHistory().sync()
        self.view!.backgroundColor = colorGreyBackground
        self.loadData()
        self.designButtonDismiss.layer.cornerRadius = 6
        self.designScore()
        self.titleLabel.text = "Résultat du défi duo n°\(self.resultDuo!.idDuo)"
        self.titleLabel.textColor = UIColor.whiteColor()
        self.titleBar.backgroundColor = colorGreenLogo
    }
    
    //methods
    private func designScore() {
        self.greenRoundA.layer.cornerRadius = self.greenRoundA.layer.bounds.width / 2
        self.greenRoundA.backgroundColor = UIColor.whiteColor()
        self.greenRoundA.layer.borderColor = colorGreenLogo.CGColor
        self.greenRoundA.layer.borderWidth = 6
        self.greenRoundA.layer.masksToBounds = true
        self.greenRoundB.layer.cornerRadius = self.greenRoundB.layer.bounds.width / 2
        self.greenRoundB.backgroundColor = UIColor.whiteColor()
        self.greenRoundB.layer.borderColor = colorGreenLogo.CGColor
        self.greenRoundB.layer.borderWidth = 6
        self.greenRoundB.layer.masksToBounds = true
        self.scoreA.textColor = colorWrongAnswer
        self.scoreA.text = "\(self.animationScoreA)"
        self.scoreB.textColor = colorWrongAnswer
        self.scoreB.text = "\(self.animationScoreB)"
        self.scoreTimerA = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("animateScoreA"), userInfo: nil, repeats: true)
        self.scoreTimerB = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("animateScoreB"), userInfo: nil, repeats: true)
    }
    
    func animateScoreA() {
        if self.animationScoreA != self.scorePlayerA {
            self.scoreA.text = "\(self.animationScoreA)"
            if self.animationScoreA < 10 {
                self.scoreA.textColor = colorWrongAnswer
            } else {
                self.scoreA.textColor = colorGreenLogo
            }
            self.animationScoreA++
        } else {
            self.scoreA.text = "\(self.animationScoreA)"
            if self.animationScoreA < 10 {
                self.scoreA.textColor = colorWrongAnswer
            } else {
                self.scoreA.textColor = colorGreenLogo
            }
            self.animationScoreA = 0
            self.scoreTimerA.invalidate()
        }
    }
    
    func animateScoreB() {
        if self.animationScoreB != self.scorePlayerB {
            self.scoreB.text = "\(self.animationScoreB)"
            if self.animationScoreB < 10 {
                self.scoreB.textColor = colorWrongAnswer
            } else {
                self.scoreB.textColor = colorGreenLogo
            }
            self.animationScoreB++
        } else {
            self.scoreB.text = "\(self.animationScoreB)"
            if self.animationScoreB < 10 {
                self.scoreB.textColor = colorWrongAnswer
            } else {
                self.scoreB.textColor = colorGreenLogo
            }
            self.animationScoreB = 0
            self.scoreTimerB.invalidate()
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
    
    private func loadData() {
        let resultDuo = self.resultDuo!
        let resultA = resultDuo.resultDuo[0]
        let resultB = resultDuo.resultDuo[1]
        //computing number of questions in this duo
        let questionsNumber = self.realm.objects(Question).filter("idDuo = \(resultDuo.idDuo)").count
        
        var playerA = ""
        if FactorySync.getConfigManager().loadNicknamePreference() {
            playerA += "\(resultA.nickname)"
        } else {
            playerA += "\(resultA.firstName) \(resultA.lastName)"
        }
        var playerB = " "
        if FactorySync.getConfigManager().loadNicknamePreference() {
            playerB += "\(resultB.nickname)"
        } else {
            playerB += "\(resultB.firstName) \(resultB.lastName)"
        }
        self.playerA.text = playerA
        self.playerB.text = playerB
        self.scorePlayerA = resultA.score*20/questionsNumber
        self.scorePlayerB = resultB.score*20/questionsNumber
        
        if resultA.id == User.currentUser!.id {
            //you're player A
            if resultA.score == resultB.score {
                Sound.playTrack("notif")
                //it's a draw!
                self.awardPoints = 5
                self.animateAwardPoint()
                self.playerA.text = "VOUS - égalité"
                self.playerB.text! += " - égalité"
                self.playerA.textColor = colorAwardPoints
                self.playerB.textColor = colorAwardPoints
                self.bonusA.text = self.awardPoints.toStringPoints()
                self.bonusB.text = self.awardPoints.toStringPoints()
            } else {
                if resultA.score > resultB.score {
                    //you win!
                    Sound.playTrack("true")
                    self.awardPoints = 10
                    self.animateAwardPoint()
                    self.playerA.text = "VOUS - gagnant"
                    self.playerB.text! += " - perdant"
                    self.playerA.textColor = colorGreen
                    self.playerB.textColor = colorWrongAnswer
                    self.bonusA.text = self.awardPoints.toStringPoints()
                    self.bonusB.text = "0pt"

                } else {
                    //you loose!
                    Sound.playTrack("false")
                    self.awardPoints = 0
                    self.playerA.text = "VOUS - perdant"
                    self.playerB.text! += " - gagnant"
                    self.playerA.textColor = colorWrongAnswer
                    self.playerB.textColor = colorGreen
                    self.bonusA.text = self.awardPoints.toStringPoints()
                    self.bonusB.text = "10pts"
                }
            }
        } else {
            //you're player B
            if resultA.score == resultB.score {
                //it's a draw!
                Sound.playTrack("notif")
                self.awardPoints = 5
                self.animateAwardPoint()
                self.playerA.text! += " - égalité"
                self.playerB.text! = "VOUS - égalité"
                self.playerA.textColor = colorAwardPoints
                self.playerB.textColor = colorAwardPoints
                self.bonusA.text = self.awardPoints.toStringPoints()
                self.bonusB.text = self.awardPoints.toStringPoints()
            } else {
                if resultA.score < resultB.score {
                    //you win!
                    Sound.playTrack("true")
                    self.awardPoints = 10
                    self.animateAwardPoint()
                    self.playerB.text! = "VOUS - gagnant"
                    self.playerA.text! += " - perdant"
                    self.playerB.textColor = colorGreen
                    self.playerA.textColor = colorWrongAnswer
                    self.bonusB.text = self.awardPoints.toStringPoints()
                    self.bonusA.text = "0pt"
                    
                } else {
                    //you loose!
                    Sound.playTrack("false")
                    self.awardPoints = 0
                    self.playerB.text! = "VOUS - perdant"
                    self.playerA.text! += " - gagnant"
                    self.playerB.textColor = colorWrongAnswer
                    self.playerA.textColor = colorGreen
                    self.bonusB.text = self.awardPoints.toStringPoints()
                    self.bonusA.text = "10pts"
                }
            }
        }
        User.currentUser!.awardPoints += self.awardPoints
        User.currentUser!.saveUser()
        User.currentUser!.updateAwardPoints(User.currentUser!.awardPoints)
    }


}
