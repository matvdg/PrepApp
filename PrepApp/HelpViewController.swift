//
//  HelpViewController.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 14/05/15.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var helpPics = ["home","training","solo","duo","contest","profile","settings","credits"]
    var helpTopics = ["Accueil","Entraînement","Défi solo","Défi duo","Concours","Profil","Réglages","Mentions légales"]
    var helpTexts = [
        "Dans l'accueil Prep'App vous pouvez consulter d'un coup d'oeil votre niveau, votre assiduité.  Glissez vers la droite pour accéder à votre graphe ANP (assiduité/niveau/performance) et glissez encore pour consulter le fil d'actualité.",
        "Entraînez-vous à volonté en choisissant vos matières, chapitres et questions.",
        "Mesurez-vous contre la montre. Utilisez le trigramme pour choisir une matière précise, ou une combinaison de deux ou trois matièrs. 6 questions de biologie, 2 de physique, 1 de chimie. Vous avez 20 minutes. Les questions du défi solo n'ont jamais été rencontrées dans entraînement et basculent dans la section entraînement une fois le défi terminé, afin de voir les corrections et de refaire les questions échouées. ",
        "Affrontez un ami en lui envoyant un défi ! Il recevra une notification Prep'App et pourra répondre au challenge dans les 24h. Vous pourrez alors comparer vos résultats. 6 questions de biologie, 2 de physique, 1 de chimie. Vous avez 20 minutes. Les questions du défi duo n'ont jamais été rencontrées dans entraînement ou défi solo et basculent dans la section entraînement une fois le défi duo terminé, afin de voir les corrections et de refaire les questions échouées.",
        "Participez aux concours Prep'App et comparez-vous aux autres étudiants. 60 questions de biologie, 20 de physique, 10 de chimie. Vous avez 3h20. Les questions du concours n'ont jamais été rencontrées dans entraînement ou défi solo/duo et sont uniques (crées pour Prep'App, elles ne proviennent pas d'annales). Elles basculent dans la section entraînement une fois le concours terminé, ou dans défi duo si vous n'avez pas participé au concours, afin de voir les corrections et de refaire les questions échouées.",
        "ANP c'est votre assiduité, votre niveau et votre performance mesurées dans cette section. Votre assiduité est calculée aux nombres de questions passées, réussies ou échouées, tandis que votre niveau mesure votre succès. Votre performance est l'indice mesurant votre taux de réussite par rapport à vos échecs. ",
        "Dans cette section vous pouvez changer votre mot de passe, activer la protection Touch ID si disponible et activer/désactiver les bruitages dans Prep'App",
        "©Prep'App est une société par actions simplifiées au capital social de 10000€. L'équipe Prep'App est composée de Maximilien Rochaix, Julien Perennou, Julien Sergent, Jonathan Carsalade et de Mathieu Vandeginste. Cette app a été développée en Swift à l'aide de ©Realm, base de donnée locale orientée objects -www.realm.io-"]
    var selectedHelp: Int = -1


	@IBOutlet var menuButton: UIBarButtonItem!
	
    override func viewDidLoad() {
        self.navigationController!.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Segoe UI", size: 20)!]
        self.navigationController!.navigationBar.tintColor = colorGreenAppButtons
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "logout", name: "failed", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "update", name: "update", object: nil)
		super.viewDidLoad()
		if self.revealViewController() != nil {
			menuButton.target = self.revealViewController()
			menuButton.action = "revealToggle:"
			self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
		}
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.helpPics.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("helpTopic", forIndexPath: indexPath) as! UITableViewCell
        var image = UIImage(named: self.helpPics[indexPath.row])
        cell.imageView?.image = image
        cell.textLabel?.textColor = UIColor.blackColor()
        cell.textLabel!.font = UIFont(name: "Segoe UI", size: 18)
        cell.textLabel!.text = self.helpTopics[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selectedHelp = indexPath.row
        if self.revealViewController() != nil {
            self.revealViewController().setFrontViewPosition(FrontViewPosition.Left, animated: true)
        }
        self.performSegueWithIdentifier("presentHelp", sender: self)
    }

    func logout() {
        println("logging out")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func update() {
        // create alert controller
        let myAlert = UIAlertController(title: "Une mise à jour des questions est disponible", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        // add an "later" button
        myAlert.addAction(UIAlertAction(title: "Plus tard", style: UIAlertActionStyle.Default, handler: nil))
        // add an "update" button
        myAlert.addAction(UIAlertAction(title: "Mettre à jour maintenant", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        // show the alert
        self.presentViewController(myAlert, animated: true, completion: nil)
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        var helpVC = segue.destinationViewController as! DetailHelpViewController
        // Pass the selected object to the new view controller.
        
        if self.selectedHelp != -1 {
            helpVC.help = self.helpTexts[self.selectedHelp]
            helpVC.helpTopic = self.helpTopics[self.selectedHelp]
            helpVC.helpPic = self.helpPics[self.selectedHelp]
        }

    }
    

}


