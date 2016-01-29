import UIKit

class MenuController: UITableViewController {
    
    //properties
    let proportionMenuBar: CGFloat = 0.7
    let sreenSize : CGRect = UIScreen.mainScreen().bounds
	
    //app method
    override func viewDidLoad() {
        self.revealViewController().rearViewRevealWidth = 220
        let name = "\(User.currentUser!.firstName) \(User.currentUser!.lastName)"
        self.name.text = name
        self.menu.backgroundColor = Colors.darkGrey
        self.topCell.backgroundColor = Colors.darkGrey
        self.homeCell.backgroundColor = Colors.darkGrey
        self.separatorA.backgroundColor = Colors.darkGrey
        self.trainingCell.backgroundColor = Colors.darkGrey
        self.soloCell.backgroundColor = Colors.darkGrey
        self.duoCell.backgroundColor = Colors.darkGrey
        self.contestCell.backgroundColor = Colors.darkGrey
        self.separatorB.backgroundColor = Colors.darkGrey
        self.statsCell.backgroundColor = Colors.darkGrey
        self.markedCell.backgroundColor = Colors.darkGrey
        self.leaderboardCell.backgroundColor = Colors.darkGrey
        self.feedbackCell.backgroundColor = Colors.darkGrey
        self.separatorC.backgroundColor = Colors.darkGrey
        self.logoutCell.backgroundColor = Colors.darkGrey
        self.separatorD.backgroundColor = Colors.darkGrey
        self.newsfeedCell.backgroundColor = Colors.darkGrey
        self.helpCell.backgroundColor = Colors.darkGrey
        self.settingsCell.backgroundColor = Colors.darkGrey
    }
    
    //@IBAction
    @IBAction func logout(sender: AnyObject) {
        // create alert controller
        let myAlert = UIAlertController(title: "Déconnexion", message: "Voulez-vous vraiment vous déconnecter ?", preferredStyle: UIAlertControllerStyle.Alert)
        myAlert.view.tintColor = Colors.green
        // add "OK" button
        myAlert.addAction(UIAlertAction(title: "Oui", style: UIAlertActionStyle.Destructive, handler: { (action) -> Void in
            SwiftSpinner.setTitleFont(UIFont(name: "Segoe UI", size: 22.0))
            SwiftSpinner.show("")
            self.syncNclearHistory()
            FactorySync.getConfigManager().saveCurrentDay(-1)
        }))
        myAlert.addAction(UIAlertAction(title: "Non", style: UIAlertActionStyle.Cancel, handler: nil))
        // show the alert
        self.presentViewController(myAlert, animated: true, completion: nil)
    }

    //@IBOutlets
    @IBOutlet var menu: UITableView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var topCell: UITableViewCell!
    @IBOutlet weak var homeCell: UITableViewCell!
    @IBOutlet weak var separatorA: UITableViewCell!
    @IBOutlet weak var trainingCell: UITableViewCell!
    @IBOutlet weak var soloCell: UITableViewCell!
    @IBOutlet weak var duoCell: UITableViewCell!
    @IBOutlet weak var contestCell: UITableViewCell!
    @IBOutlet weak var separatorB: UITableViewCell!
    @IBOutlet weak var statsCell: UITableViewCell!
    @IBOutlet weak var markedCell: UITableViewCell!
    @IBOutlet weak var leaderboardCell: UITableViewCell!
    @IBOutlet weak var feedbackCell: UITableViewCell!
    @IBOutlet weak var separatorC: UITableViewCell!
    @IBOutlet weak var logoutCell: UITableViewCell!
    @IBOutlet weak var separatorD: UITableViewCell!
    @IBOutlet weak var settingsCell: UITableViewCell!
    @IBOutlet weak var helpCell: UITableViewCell!
    @IBOutlet weak var newsfeedCell: UITableViewCell!
    
    
    //methods
    func syncNclearHistory(){
        FactoryHistory.getHistory().syncHistory({ (result) -> Void in
            SwiftSpinner.hide()
            if result {
                //Clear the local user
                NSUserDefaults.standardUserDefaults().removeObjectForKey("user")
                NSUserDefaults.standardUserDefaults().synchronize()
                User.authenticated = false
                self.dismissViewControllerAnimated(true, completion: nil)
                //Clear Ream History local DB
                FactoryRealm.clearUserDB()
            } else {
                let myAlert = UIAlertController(title: "Erreur de connexion", message: "Prep'App n'a pas pu sauvegarder vos données sur le cloud, cette opération est nécessaire avant la déconnexion. Veuillez vérifier que vous êtes connecté à internet avec une bonne couverture cellulaire ou WiFi, puis réessayez.", preferredStyle: UIAlertControllerStyle.Alert)
                myAlert.view.tintColor = Colors.green
                // add "OK" button
                myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                // show the alert
                self.presentViewController(myAlert, animated: true, completion: nil)
            }
        })

    }
    
}
