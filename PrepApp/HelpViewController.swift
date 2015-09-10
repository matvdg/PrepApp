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
        //Aide accueil
        "Consultez d’un coup d’oeil votre diagramme de niveau et ciblez vos révisions. Glissez vers la droite pour avoir accès au fil d’actualité de votre établissement. Tournez votre appareil en mode paysage pour accéder à votre graphique performance.",
        //Aide Entraînement
        "Orientez vos révisions en choisissant la matière et le chapitre que vous souhaitez. Si la solution de la question est incomprise, marquez-la afin de faire part à vos professeurs de vos difficultés. Vous pouvez également retrouver les questions marquées dans la section profil afin de les retravailler. Appuyez sur \"Question\" pour afficher la barre des filtres et retrouvez les nouvelles questions, celles réussies, marquées ou échouées.",
        //Aide défi solo
        "Vous disposez de 20 minutes ? Grâce au trigramme choisissez la matière, ou la combinaison de matières afin de créer le défi qui vous convient. Les questions du défi solo n’ont jamais été vues auparavant et basculent dans la section entraînement une fois le défi terminé. Chaque point gagné au dessus de 10/20 vous fait gagner un bonus KP (KeyPoints)",
        //Aide défi duo
        "Vous disposez de 20 minutes ? Affrontez un ami et envoyez lui un défi. Il recevra une notification Prep’App et aura 24h pour répondre au défi. Vous pourrez ensuite comparer vos résultats et recevoir vos points. En plus des points gagnés par chacun, le vainqueur reçoit 10 KP (KeyPoints) en bonus. Les questions du défi duo n’ont jamais été vues auparavant et basculent dans la section entrainement une fois le défi terminé. Pour démarrer un défi duo, vous pouvez soit lancer un défi à une personne aléatoire soit choisir parmi votre liste d'amie. Vous pouvez rajouter ou supprimer des amis grâce à un code unique généré que vous amis vous ont donné ou que vous pouvez partager.",
        //Aide concours
        "Participez au concours Prep’App dans les mêmes conditions que le jour J. Cet évènement est accessible pendant un certain temps déterminé par votre établissement. Les questions du concours n’ont jamais été vues auparavant dans aucun des autres modes et basculent dans la section entraînement une fois le concours terminé ou dans défi solo si vous n'avez pas participé au concours. Les premiers du classement recevront des bonus KP (KeyPoints) en fonction de leur position !",
        //Aide profil
        "Dans cette section, vous pouvez consulter vos statistiques, votre classement, consulter ou supprimer vos questions marquées et envoyer un commentaire au professeur, ou encore nous envoyer des suggestions ou des remarques pour l'app Prep'App. Dans statistiques, découvrez le concept ANP : Assiduité, niveau et performance sont les 3 critères qui valorisent votre progression. Votre assiduité représente le nombre de questions répondues quelles soient justes ou fausses tandis que votre niveau ne tient compte que de vos questions réussies. Votre performance est l’indice mesurant votre taux de réussite par rapport aux questions répondues et ce toutes les semaines. Les KeyPoints (KP) sont une combinaison de votre niveau et de votre assiduité. Dans les défis et les concours vous pourrez gagner des KP bonus. ",
        //Aide réglages
        "Dans cette section vous pouvez changer votre mot de passe, activer la protection Touch ID si disponible et activer/désactiver les bruitages dans Prep'App",
        //Aide mentions légales
        "©Prep'App est une société par actions simplifiées au capital social de 10000€. L'équipe Prep'App est composée de Maximilien Rochaix, Julien Perennou, Julien Sergent, Jonathan Carsalade et de Mathieu Vandeginste. Cette app a été développée en Swift à l'aide de ©Realm, base de donnée locale orientée objets."]
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


