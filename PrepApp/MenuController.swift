import UIKit

class MenuController: UITableViewController {
    
    let proportionMenuBar: CGFloat = 0.7
    let sreenSize : CGRect = UIScreen.mainScreen().bounds
	
    override func viewDidLoad() {
        self.revealViewController().rearViewRevealWidth = 200
    }

	@IBAction func logout(sender: AnyObject) {
		//Clear the local user
		NSUserDefaults.standardUserDefaults().removeObjectForKey("user")
		NSUserDefaults.standardUserDefaults().synchronize()
        User.authenticated = false
        self.dismissViewControllerAnimated(true, completion: nil)
	}

}
