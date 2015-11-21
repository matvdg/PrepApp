//
//  StatsViewController.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 15/09/2015.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import UIKit

class StatsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //properties
    var statsTopics = ["Niveau", "Assiduité", "Questions réussies", "Echéance", "AwardPoints"]
    var statsData: [String] = []
    var statsDetails: [String] = []
    var statsPics = ["level","puzzle","check","term","awardPoint"]
    var refreshIsNeeded = false
    
    //@IBOutlets
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var nickname: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var badge: UIButton!
    @IBOutlet weak var statsTable: UITableView!
    
    //app methods
    override func viewDidLoad() {
        super.viewDidLoad()
        //sync
        FactoryHistory.getHistory().sync()
        self.view!.backgroundColor = colorGreyBackground
        self.loadData()
        self.statsTable.backgroundColor = colorGreyBackground
        self.renderBadge()
        self.name.text = "\(User.currentUser!.firstName) \(User.currentUser!.lastName)"
        if FactorySync.getConfigManager().loadNicknamePreference() {
            self.nickname.text = User.currentUser!.nickname
        } else {
            self.nickname.hidden = true
        }
        self.email.text = "\(User.currentUser!.email)"
        self.navigationController!.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Segoe UI", size: 20)!]
        self.navigationController!.navigationBar.tintColor = colorGreen
        self.title = "Statistiques"
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "logout", name: "failed", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "update", name: "update", object: nil)
        
        if self.revealViewController() != nil {
            self.menuButton.target = self.revealViewController()
            self.menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        if self.refreshIsNeeded {
            self.renderBadge()
        } else {
            self.refreshIsNeeded = true
        }
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
    
    //methods
    func renderBadge(){
        self.badge.titleLabel!.font = UIFont(name: "Times New Roman", size: 50)!
        self.badge.backgroundColor = colors[User.currentUser!.color]
        self.badge.layer.zPosition = 100
        self.badge.layer.borderColor = UIColor.whiteColor().CGColor
        self.badge.layer.borderWidth = 6
        let firstName = User.currentUser!.firstName
        let lastName = User.currentUser!.lastName
        let firstChar = firstName[firstName.startIndex.advancedBy(0)]
        let secondChar = lastName[lastName.startIndex.advancedBy(0)]
        let initials = String(stringInterpolationSegment: firstChar).uppercaseString + String(stringInterpolationSegment: secondChar).uppercaseString
        self.badge.setTitle(initials, forState: .Normal)
        self.badge.titleLabel!.adjustsFontSizeToFitWidth = true
        self.badge.titleLabel!.numberOfLines = 1
        self.badge.titleLabel!.baselineAdjustment = UIBaselineAdjustment.AlignCenters
        self.badge.layer.cornerRadius = self.badge.frame.width / 2
    }
    
    func loadData() {
        //level
        self.statsData.append(User.currentUser!.level.levelPrepApp())
        self.statsDetails.append("Niveau \(User.currentUser!.level). Le niveau est calculé à partir des questions réussies dans chaque matière et ce dans les proportions de l'examen final. Dans l'accueil, le graphe vous indique la progression du niveau en cours pour chaque matière.")
        //assiduity
        self.statsData.append(FactoryHistory.getScoring().getAssiduity().toStringPoints())
        self.statsDetails.append("L'assiduité est récompensée ! 1 AwardPoint par question faite = \((FactoryHistory.getScoring().getFailed() + FactoryHistory.getScoring().getSucceeded()).toStringPoints())  Les questions basculées dans entraînement (provenant des défis solo/duo ou d’un concours) que vous avez revues vous ont rapporté \((FactoryHistory.getScoring().getAssiduity()-(FactoryHistory.getScoring().getFailed() + FactoryHistory.getScoring().getSucceeded())).toStringPoints()) d'assiduité double en bonus. Soit un total de \(FactoryHistory.getScoring().getAssiduity().toStringPoints())")
        //questions succeeded
        self.statsData.append("\(FactoryHistory.getScoring().getSucceeded())/\(FactoryHistory.getScoring().getSucceeded() + FactoryHistory.getScoring().getFailed())")
        self.statsDetails.append("\(FactoryHistory.getScoring().getSucceeded()) \(self.grammarQuestionString(FactoryHistory.getScoring().getSucceeded())) \(self.grammarSucceededString(FactoryHistory.getScoring().getSucceeded())), \(FactoryHistory.getScoring().getFailed()) \(self.grammarQuestionString(FactoryHistory.getScoring().getFailed())) \(self.grammarFailedString(FactoryHistory.getScoring().getFailed())) sur un total de \(FactoryHistory.getScoring().getFailed()+FactoryHistory.getScoring().getSucceeded()) \(self.grammarQuestionString(FactoryHistory.getScoring().getFailed()+FactoryHistory.getScoring().getSucceeded())).")
        //term
        self.statsData.append("\(FactorySync.getConfigManager().loadWeeksBeforeExam()) \(self.grammarWeekString(FactorySync.getConfigManager().loadWeeksBeforeExam()))")
        self.statsDetails.append("Vous avez \(FactorySync.getConfigManager().loadWeeksBeforeExam()) \(self.grammarWeekString(FactorySync.getConfigManager().loadWeeksBeforeExam())) avant l'échéance fixée par votre établissement (concours/examen/partiels) le \(FactorySync.getConfigManager().loadDate())")
        //awardPoints
        self.statsData.append(User.currentUser!.awardPoints.toStringPoints())
        self.statsDetails.append("\(User.currentUser!.awardPoints.toStringPoints()) AwardPoints gagnés dans Prep'App Kiné, total des AwardPoints réussites, assiduité et bonus.")
        //awardPoints global
        self.statsData.append(User.currentUser!.awardPoints.toStringPoints())
        self.statsDetails.append("\(User.currentUser!.awardPoints.toStringPoints()) AwardPoints gagnés dans toutes les applications Prep'App, total des AwardPoints réussites, assiduité et bonus.")
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
    
    private func grammarWeekString(int: Int) -> String {
        if int < 2 {
            return "semaine"
        } else {
            return "semaines"
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
        cell.textLabel!.text = self.statsTopics[indexPath.row]
        cell.backgroundColor = colorGreyBackground
        cell.detailTextLabel!.text = statsData[indexPath.row]
        cell.detailTextLabel!.font = UIFont(name: "Segoe UI", size: 16)
        cell.detailTextLabel!.textColor = colorGreen
        cell.textLabel!.adjustsFontSizeToFitWidth = true
        cell.detailTextLabel!.adjustsFontSizeToFitWidth = true
        cell.textLabel!.font = UIFont(name: "Segoe UI", size: 16)
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
