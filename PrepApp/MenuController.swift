import UIKit

class MenuController: UITableViewController {
    
    let proportionMenuBar: CGFloat = 0.7
    let sreenSize : CGRect = UIScreen.mainScreen().bounds
	
    override func viewDidLoad() {
        self.revealViewController().rearViewRevealWidth = 220
        let name = "\(User.currentUser!.firstName) \(User.currentUser!.lastName)"
        self.name.text = name
        
        
    }

    @IBOutlet weak var name: UILabel!
	@IBAction func logout(sender: AnyObject) {
        
        // create alert controller
        let myAlert = UIAlertController(title: "Déconnexion", message: "Voulez-vous vraiment vous déconnecter ?", preferredStyle: UIAlertControllerStyle.Alert)
        myAlert.view.tintColor = colorGreen
        // add an "OK" button
        myAlert.addAction(UIAlertAction(title: "OUI", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            self.syncNclearHistory()
        }))
        myAlert.addAction(UIAlertAction(title: "NON", style: UIAlertActionStyle.Default, handler: nil))
        
        // show the alert
        self.presentViewController(myAlert, animated: true, completion: nil)

        
        
			}
    
    func syncNclearHistory(){
        FactoryHistory.getHistory().syncHistory({ (result) -> Void in
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
                        // add an "OK" button
                        myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                        // show the alert
                        self.presentViewController(myAlert, animated: true, completion: nil)
                    }
                })
            } else {
                let myAlert = UIAlertController(title: "Erreur de connexion", message: "Prep'App n'a pas pu sauvegarder vos données sur le cloud, cette opération est nécessaire avant la déconnexion. Veuillez vérifier que vous êtes connecté à internet avec une bonne couverture cellulaire ou WiFi, puis réessayez.", preferredStyle: UIAlertControllerStyle.Alert)
                myAlert.view.tintColor = colorGreen
                // add an "OK" button
                myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                // show the alert
                self.presentViewController(myAlert, animated: true, completion: nil)
            }
        })

    }

}
