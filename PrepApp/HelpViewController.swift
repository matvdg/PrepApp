//
//  HelpViewController.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 30/09/15.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController {
    
    @IBOutlet weak var helpText: UITextView!
    
    @IBOutlet weak var helpImage: UIImageView!
    
    @IBOutlet var menuButton: UIBarButtonItem!
    
    @IBOutlet weak var roundCircle: UILabel!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBAction func changePage(sender: AnyObject) {
        self.selectedHelp = self.pageControl.currentPage
        self.displayHelp()
    }
    
    var selectedHelp = 0
    var helpPics = ["home", "training",  "solo", "duo", "contest", "stats", "marked", "leaderboard", "feedback", "settings", "credits"]
    var helpTopics = ["Aide accueil","Aide entraînement","Aide défi solo","Aide défi duo","Aide concours","Aide statistiques","Aide questions marquées", "Aide classement", "Aide suggestions", "Aide réglages","Mentions légales"]
    var helpTexts = [
        //Aide accueil
        "Consultez d’un coup d’oeil votre diagramme de niveau et ciblez vos révisions. Glissez vers la droite pour avoir accès au fil d’actualité de votre établissement. Tournez votre appareil en mode paysage pour accéder à votre graphe performance. Votre performance est l’indice mesurant votre taux de réussite par rapport aux questions répondues et ce toutes les semaines et par matière. Le graphe en bâtons représente quant à lui le nombre de questions répondues (plus le bâton est haut, plus votre performance est significative.) ",
        //Aide Entraînement
        "Orientez vos révisions en choisissant la matière et le chapitre que vous souhaitez. Si la solution de la question est incomprise, marquez-la en appuyant sur le bouton en forme de point d'exclamation afin de faire part à vos professeurs de vos difficultés. Vous pouvez également retrouver les questions marquées dans la section profil afin de les retravailler. Appuyez sur \"Question\" pour afficher la barre des filtres et retrouvez les nouvelles questions, celles réussies, marquées ou échouées. Une question faite vous rapporte 1 AwardPoint pour l'assiduité et 5 AwardPoints si elle a été réussie pour la première fois. Si une question provent d'un défi, vous allez gagné un second AwardPoint d'assiduité !",
        //Aide défi solo
        "Vous disposez de 20 minutes ? Grâce au trigramme choisissez la matière, ou la combinaison de matières afin de créer le défi qui vous convient. Les questions du défi solo n’ont jamais été vues auparavant et basculent dans la section entraînement une fois le défi terminé. Une question faite vous rapporte 1 AwardPoint pour l'assiduité et 5 AwardPoints si elle a été réussie pour la première fois. Chaque point gagné au dessus de 10/20 vous fait gagner un bonus de 2 AwardPoints.",
        //Aide défi duo
        "Vous disposez de 20 minutes ? Affrontez un ami et envoyez lui un défi. Il recevra une notification Prep’App et aura 24h pour répondre au défi. Vous pourrez ensuite comparer vos résultats et recevoir vos points. Une question faite vous rapporte 1 AwardPoint pour l'assiduité et 5 AwardPoints si elle a été réussie pour la première fois. En plus des points gagnés par chacun, le vainqueur reçoit 10 AwardPoints en bonus ou 5pts si égalité. Les questions du défi duo n’ont jamais été vues auparavant et basculent dans la section entraînement une fois le défi terminé. Pour démarrer un défi duo, vous pouvez soit lancer un défi à une personne aléatoire soit choisir parmi votre liste d'amis. Vous pouvez rajouter des amis grâce à un code unique généré que vos amis vous ont donné. Vous pouvez également être invité par vos amis en leur partageant un code unique. Supprimez un ami en glissant vers la gauche.",
        //Aide concours
        "Participez au concours Prep’App dans les mêmes conditions que le jour J. Cet évènement est accessible pendant un certain temps déterminé par votre établissement. Les questions du concours n’ont jamais été vues auparavant dans aucun des autres modes et basculent dans la section entraînement une fois le concours terminé ou dans défi solo si vous n'avez pas participé au concours. Une question faite vous rapporte 1 AwardPoint pour l'assiduité et 5 AwardPoints si elle a été réussie pour la première fois. Les premiers du classement recevront des bonus AwardPoints en fonction de leur position !",
        //Aide statistiques
        "Consultez ici vos statistiques Prep'App Kiné ! Votre assiduité représente le nombre de questions répondues qu'elles soient justes ou fausses tandis que votre niveau ne tient compte que de vos questions réussies. Les AwardPoints sont une combinaison de votre niveau et de votre assiduité. Dans les défis et les concours vous pourrez gagner des AwardPoints bonus. Vous pouvez également consulter votre échéance fixée par votre établissement (date et nombre de semaines restantes).",
        //Aide questions marquées
        "Retrouvez ici toutes les questions que vous avez marqué dans l'app. Appuyez sur i pour afficher la question et sa correction, touchez pour envoyer une question à votre professeur ou glissez vers la gauche pour enlever le marquage de la question.",
        //Aide classement
        "Situez-vous dans votre établissement avec notre classement global Prep'App grâce aux AwardPoints.",
        //Aide suggestions
        "Envoyez-nous votre feedback en nous faisant directement parvenir vos remarques ou suggestions pour l'app. Choisissez un sujet et tapez simplement votre message. Nous récupèrerons votre adresse email afin de vous répondre éventuellement pour des informations complémentaires.",
        //Aide réglages
        "Dans cette section vous pouvez changer votre mot de passe, activer la protection Touch ID si disponible et activer/désactiver les bruitages dans Prep'App. Si votre établissement le permet, vous pourrez modifier votre pseudonyme qui paraîtra dans le classement Prep'App et dans les listes d'amis pour le défi duo. Si vous ne voulez pas être anonyme, vous pourrez toujours mettre votre prénom et nom en tant que pseudonyme.",
        //Aide mentions légales
        "©Prep'App est une société par actions simplifiées au capital social de 10000€. L'équipe Prep'App est composée de Maximilien Rochaix, Julien Perennou, Julien Sergent, Jonathan Carsalade et de Mathieu Vandeginste. Cette app a été développée en Swift à l'aide de ©Realm (base de donnée locale orientée objets) et du framework ios-charts. Mentions légales : ios-charts créé par Daniel Cohen Gindi, inspiré des travaux de Philipp Jahoda, un portage iOS de MPAndroidChart. Realm Objective-C & Realm Swift, ios-charts sont publiés sous licence Apache 2.0. Vous pouvez obtenir une copie de cette licence à http://www.apache.org/licenses/LICENSE-2.0"]

    override func viewDidLoad() {
        super.viewDidLoad()
        //sync
        FactoryHistory.getHistory().sync()
        self.view!.backgroundColor = colorGreyBackground
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "update", name: "update", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "logout", name: "failed", object: nil)
        
        if self.revealViewController() != nil {
            self.menuButton.target = self.revealViewController()
            self.menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        //handling swipe gestures
        var swipeRight = UISwipeGestureRecognizer(target: self, action: "swiped:")
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRight)
        
        var swipeLeft = UISwipeGestureRecognizer(target: self, action: "swiped:")
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(swipeLeft)

        self.displayHelp()
        
        self.navigationController!.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Segoe UI", size: 20)!]
        self.navigationController!.navigationBar.tintColor = colorGreen
        self.roundCircle.layer.cornerRadius = 50
        self.roundCircle.backgroundColor = UIColor.clearColor()
        self.roundCircle.layer.borderColor = colorGreenLogo.CGColor!
        self.roundCircle.layer.borderWidth = 3.0
        
    }
    
    func swiped(gesture : UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            switch swipeGesture.direction {
                
            case UISwipeGestureRecognizerDirection.Left:
                self.selectedHelp = (self.selectedHelp == 10) ? 0 : ++self.selectedHelp
                
            case UISwipeGestureRecognizerDirection.Right:
                self.selectedHelp = (self.selectedHelp == 0) ? 10 : --self.selectedHelp
                
            default:
                println("error")
                break
            }
            
        }
        self.displayHelp()
    }
    
    func displayHelp() {
        self.pageControl.currentPage = self.selectedHelp
        self.pageControl.updateCurrentPageDisplay()
        self.helpImage.image = UIImage(named: self.helpPics[self.selectedHelp])
        self.title = self.helpTopics[self.selectedHelp]
        self.helpText.text = self.helpTexts[self.selectedHelp]
        self.helpText.textColor = UIColor.blackColor()
        self.helpText.font = UIFont(name: "Segoe UI", size: 16)
        self.helpText.setContentOffset(CGPointZero, animated: true)
        self.helpText.scrollRangeToVisible(NSRange(location: 0, length: 0))
        self.helpText.textAlignment = NSTextAlignment.Justified
    }
    
    func logout() {
        println("logging out")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func update() {
        // create alert controller
        let myAlert = UIAlertController(title: "Une mise à jour des questions est disponible", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        myAlert.view.tintColor = colorGreen
        // add an "later" button
        myAlert.addAction(UIAlertAction(title: "Plus tard", style: UIAlertActionStyle.Default, handler: nil))
        // add an "update" button
        myAlert.addAction(UIAlertAction(title: "Mettre à jour maintenant", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        // show the alert
        self.presentViewController(myAlert, animated: true, completion: nil)
    }
    
   
    
   

}
