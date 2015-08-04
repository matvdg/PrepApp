//
//  HelpViewController.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 14/05/15.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var helpPics = ["training","solo","duo","concours","profile","settings","home"]
    var helpTopics = ["Entraînement","Défi solo","Défi duo","Concours","Profil","Réglages","Crédits"]
    var helpText = ["Entraînement : entraînez-vous à volonté en choisissant vos matières, chapitres et questions.","Défi solo : mesurez-vous contre la montre ","Défi duo : Affrontez un ami","Concours : participez aux concours Prep'App et comparez-vous aux autres étudiants","Profil : ANP c'est votre assiduité, votre niveau et votre performance mesurées dans cette section ","Réglages : changez votre mot de passe, activez la protection Touch ID si disponible","Crédits Prep'App© Maximilien Rochaix, Julien Perennou, Julien Sergent, Jonathan Carlasade, Mathieu Vandeginste"]
    var selectedHelp: Int = -1

    @IBOutlet weak var collectionView: UICollectionView!

	@IBOutlet var menuButton: UIBarButtonItem!
	
	override func viewDidLoad() {
		super.viewDidLoad()
        self.collectionView.backgroundColor = UIColor.clearColor()
		if self.revealViewController() != nil {
			menuButton.target = self.revealViewController()
			menuButton.action = "revealToggle:"
			self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
		}
	}
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController!.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Segoe UI", size: 20)!]
        if User.authenticated == false {
            NSUserDefaults.standardUserDefaults().removeObjectForKey("user")
            NSUserDefaults.standardUserDefaults().synchronize()
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.helpPics.count
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! UICollectionViewCellHelp
        var image = UIImage(named: self.helpPics[indexPath.row])
        cell.image.image = image
        cell.label.text = self.helpTopics[indexPath.row]
        cell.label.textColor = UIColor.whiteColor()
        cell.label.font = UIFont(name: "Segoe UI", size: 17)
        // Configure the cell
        return cell
    
    }
    
    func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        self.selectedHelp = indexPath.row
        self.performSegueWithIdentifier("presentHelp", sender: self)
        return true
    }

    

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        var helpVC = segue.destinationViewController as! HelpPopUpViewController
        // Pass the selected object to the new view controller.
        
        if self.selectedHelp != -1 {
            helpVC.help = self.helpText[self.selectedHelp]
        }

    }
    

}

class UICollectionViewCellHelp: UICollectionViewCell {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var image: UIImageView!
    
}
