
import UIKit

class HomeViewController: UIViewController {
	
	
    @IBOutlet weak var menuButton:UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Segoe UI", size: 20)!]

		if self.revealViewController() != nil {
			menuButton.target = self.revealViewController()
			menuButton.action = "revealToggle:"
			self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
		}
				
		hello.text = User.currentUser?.printUser()
		welcome.text = "Bonjour, \(User.currentUser!.firstName) \(User.currentUser!.lastName)"
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
	@IBOutlet var hello: UILabel!
	@IBOutlet weak var welcome: UILabel!
	

}
