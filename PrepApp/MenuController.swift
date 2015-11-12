import UIKit

class MenuController: UITableViewController {
    
    let proportionMenuBar: CGFloat = 0.7
    let sreenSize : CGRect = UIScreen.mainScreen().bounds
	
    override func viewDidLoad() {
        self.revealViewController().rearViewRevealWidth = 220
        let name = "\(User.currentUser!.firstName) \(User.currentUser!.lastName)"
        self.name.text = name
        self.menu.backgroundColor = colorDarkGrey
        self.topCell.backgroundColor = colorDarkGrey
        self.homeCell.backgroundColor = colorDarkGrey
        self.separatorA.backgroundColor = colorDarkGrey
        self.trainingCell.backgroundColor = colorDarkGrey
        self.soloCell.backgroundColor = colorDarkGrey
        self.duoCell.backgroundColor = colorDarkGrey
        self.contestCell.backgroundColor = colorDarkGrey
        self.separatorB.backgroundColor = colorDarkGrey
        self.statsCell.backgroundColor = colorDarkGrey
        self.markedCell.backgroundColor = colorDarkGrey
        self.leaderboardCell.backgroundColor = colorDarkGrey
        self.feedbackCell.backgroundColor = colorDarkGrey
        self.separatorC.backgroundColor = colorDarkGrey
        self.logoutCell.backgroundColor = colorDarkGrey
    }

    @IBOutlet var menu: UITableView!
    @IBOutlet weak var name: UILabel!
	@IBAction func logout(sender: AnyObject) {
        
        // create alert controller
        let myAlert = UIAlertController(title: "Déconnexion", message: "Voulez-vous vraiment vous déconnecter ?", preferredStyle: UIAlertControllerStyle.Alert)
        myAlert.view.tintColor = colorGreen
        // add "OK" button
        myAlert.addAction(UIAlertAction(title: "OUI", style: UIAlertActionStyle.Destructive, handler: { (action) -> Void in
            SwiftSpinner.show("Déconnexion...")
            SwiftSpinner.setTitleFont(UIFont(name: "Segoe UI", size: 22.0))

            self.syncNclearHistory()
        }))
        myAlert.addAction(UIAlertAction(title: "NON", style: UIAlertActionStyle.Cancel, handler: nil))
        
        // show the alert
        self.presentViewController(myAlert, animated: true, completion: nil)

        
        
			}
    
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
    
    
    
    func syncNclearHistory(){
        FactoryHistory.getHistory().syncHistory({ (result) -> Void in
            SwiftSpinner.hide()
            if result {
                FactoryDuo.getFriendManager().syncFriendsList({ (result) -> Void in
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
                        myAlert.view.tintColor = colorGreen
                        // add "OK" button
                        myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                        // show the alert
                        self.presentViewController(myAlert, animated: true, completion: nil)
                    }
                })
            } else {
                let myAlert = UIAlertController(title: "Erreur de connexion", message: "Prep'App n'a pas pu sauvegarder vos données sur le cloud, cette opération est nécessaire avant la déconnexion. Veuillez vérifier que vous êtes connecté à internet avec une bonne couverture cellulaire ou WiFi, puis réessayez.", preferredStyle: UIAlertControllerStyle.Alert)
                myAlert.view.tintColor = colorGreen
                // add "OK" button
                myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                // show the alert
                self.presentViewController(myAlert, animated: true, completion: nil)
            }
        })

    }

}
