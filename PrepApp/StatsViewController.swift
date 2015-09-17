//
//  StatsViewController.swift
//  PrepApp
//
//  Created by Mikael Vandeginste on 15/09/2015.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import UIKit

class StatsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var statsTopics = ["Niveau", "Assiduité", "Questions réussies", "Temps restant avant concours", "AwardPoints"]
    var statsData: [String] = []
    var statsPics = ["level","puzzle","check","solo","awardPoint"]
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var level: UILabel!
    @IBOutlet weak var statsTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FactoryHistory.getScoring().sync()
        self.loadData()
        self.statsTable.backgroundColor = colorGreyBackground
        self.renderLevel()
        self.name.text = "\(User.currentUser!.firstName) \(User.currentUser!.lastName)"
        self.email.text = "\(User.currentUser!.email)"
        self.navigationController!.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Segoe UI", size: 20)!]
        self.navigationController!.navigationBar.tintColor = colorGreenAppButtons
        self.title = "Statistiques"
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
    
    func renderLevel(){
        self.level.font = UIFont(name: "Times New Roman", size: 70)
        self.level.backgroundColor = colorGreenLogo
        self.level.layer.zPosition = 100
        self.level.layer.borderColor = UIColor.whiteColor().CGColor
        self.level.layer.borderWidth = 6
        self.level.text = User.currentUser!.level.levelPrepApp()
        self.level.adjustsFontSizeToFitWidth = true
        self.level.numberOfLines = 1
        self.level.baselineAdjustment = UIBaselineAdjustment.AlignCenters
        self.level.layer.cornerRadius = self.level.frame.width / 2
        self.level.layer.masksToBounds = true
    }
    
    func loadData() {
        self.statsData.append("\(User.currentUser!.level + 1)")
        self.statsData.append(User.currentUser!.assiduity.toStringPoints())
        self.statsData.append("\(User.currentUser!.success)/\(User.currentUser!.success + User.currentUser!.failed)")
        self.statsData.append("\(User.currentUser!.weeksBeforeExam) semaines")
        self.statsData.append(User.currentUser!.awardPointsApp.toStringPoints())
        self.statsData.append(User.currentUser!.awardPointsGlobal.toStringPoints())
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
