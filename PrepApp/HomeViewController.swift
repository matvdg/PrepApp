
import UIKit

class HomeViewController: UIViewController {
	
	
    @IBOutlet weak var menuButton:UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

		if self.revealViewController() != nil {
			menuButton.target = self.revealViewController()
			menuButton.action = "revealToggle:"
			self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
		}
		let sreenSize : CGRect = UIScreen.mainScreen().bounds
		self.revealViewController().rearViewRevealWidth = sreenSize.width * 0.6
		
		hello.text = User.currentUser?.printUser()
		welcome.text = "Bonjour, \(User.currentUser!.firstName) \(User.currentUser!.lastName)"
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
	@IBOutlet var hello: UILabel!
	@IBOutlet weak var welcome: UILabel!
	

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
