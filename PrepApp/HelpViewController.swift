//
//  HelpViewController.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 31/10/2015.
//  Copyright © 2015 PrepApp. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController {
    
    
    var selectedHelp = 0
    var helpPics = ["home", "training",  "solo", "duo", "contest", "stats", "marked", "leaderboard", "feedback", "settings", "credits"]
    var helpTopics = ["Accueil","Entraînement","Défi solo","Défi duo","Concours","Statistiques","Marquages", "Classement", "Suggestions", "Réglages","Mentions légales"]
    var helpTexts = [
        //0- Aide accueil
        "Consultez d’un coup d’oeil votre diagramme de niveau et ciblez vos révisions. Obtenez le détail de votre progression pour chaque matière en touchant les boutons de la légende.\n\nTournez votre appareil en mode paysage pour accéder à votre graphique Performances. Votre performance est l’indice mesurant votre taux de réponses justes par matière et ce toutes les semaines. Le graphe en bâtons représente quant à lui le nombre de questions répondues (plus le bâton est haut, plus votre performance est significative.)\n\nGlissez vers la droite pour avoir accès au fil d’actualités de votre établissement. Vous pouvez glisser vers le bas dans le fil d'actualités pour actualiser la page.",
        
        //1- Aide Entraînement
        "Orientez vos révisions en choisissant la matière et le chapitre que vous souhaitez.\n\nSi la solution de la question est incomprise, marquez-la en appuyant sur le drapeau afin de faire part à vos professeurs de vos difficultés. Vous pouvez y ajouter un commentaire destiné à vos professeurs. Toutes les marquages sont accessible dans le menu afin de les retravailler par la suite.\n\nAppuyez sur \"Question\" pour afficher la barre des filtres et retrouvez les nouvelles questions, celles réussies, marquées ou échouées.\n\nUne question faite vous rapporte 1 AwardPoint pour l'assiduité et 5 AwardPoints si elle a été réussie pour la première fois. Si une question provient d'un défi ou concours, vous gagnez un second AwardPoint d'assiduité !",
        
        //2- Aide défi solo
        "Vous disposez de \(FactorySync.getConfigManager().loadDuration()) minutes ? Grâce au trigramme choisissez la matière, ou la combinaison de matières afin de créer le défi qui vous convient.\n\nLes questions du défi solo n’ont jamais été vues auparavant et basculent dans la section entraînement une fois le défi terminé. Une question faite vous rapporte 1 AwardPoint pour l'assiduité et 5 AwardPoints si elle a été réussie pour la première fois. Chaque point gagné au dessus de 10/20 vous fait gagner un bonus de 2 AwardPoints.\n\nUne fois le défi terminé, vous accédez à votre score et à votre correction. Si la solution de la question est incomprise, marquez-la en appuyant sur le drapeau afin de faire part à vos professeurs de vos difficultés.",
        
        //3- Aide défi duo
        "Vous disposez de \(FactorySync.getConfigManager().loadDuration()) minutes ? Affrontez un ami et envoyez lui un défi. Il recevra une notification Prep’App et aura 24h pour répondre au défi. Vous pourrez ensuite comparer vos résultats et recevoir vos points.\n\nUne question faite vous rapporte 1 AwardPoint pour l'assiduité et 5 AwardPoints si elle a été réussie pour la première fois. En plus des points gagnés par chacun, le vainqueur reçoit 10 AwardPoints en bonus ou 5 AwardPoints en cas d’égalité. Les questions du défi duo n’ont jamais été vu auparavant et basculent dans la section entraînement une fois le défi terminé.\n\nPour démarrer un défi duo, vous pouvez soit défier une personne aléatoirement soit choisir dans votre liste d'amis.\n\nVous pouvez rajouter des amis grâce au code unique qu’ils vous auront donné. Vous pouvez également être invité par vos amis en leur partageant votre code. Supprimez un ami en glissant vers la gauche. Glissez vers le bas pour actualiser la liste de vos amis et de vos défis en attente.\n\nUne fois le défi terminé, vous accédez à votre score et à votre correction. Si la solution de la question est incomprise, marquez-la en appuyant sur le drapeau afin de faire part à vos professeurs de vos difficultés.",
        //4- Aide concours
        "Participez au concours Prep’App dans les mêmes conditions que le jour J. Le classement respecte le barème de points propre à votre concours. Cet évènement est accessible pendant un certain temps déterminé par votre établissement.\n\nLes questions du concours n’ont jamais été vues auparavant dans aucun des autres modes et basculent dans la section entraînement une fois le concours terminé ou dans défi solo si vous n'avez pas participé au concours. Une question faite vous rapporte 1 AwardPoint pour l'assiduité et 5 AwardPoints si elle a été réussie pour la première fois. Les premiers du classement recevront des AwardPoints Bonus en fonction de leur position !\n\nUne fois le concours terminé, vous pourrez également consulter vos résultats et les classements des concours pendant une durée limitée.",
        
        //5- Aide statistiques
        "Consultez ici vos statistiques Prep'App Kiné ! Votre assiduité représente le nombre de questions répondues qu'elles soient justes ou fausses (chaque question rapporte un AwardPoint) tandis que votre niveau ne tient compte que de vos questions réussies.\n\nLes questions basculées dans entraînement (provenant des défis solo/duo ou d’un concours) vous rapportent un deuxième point d’assiduité si vous y répondez à nouveau.\n\nLes AwardPoints représentent donc vos performances et votre assiduité. Dans les défis et les concours vous pourrez gagner des AwardPoints Bonus.\n\nVous pouvez également consulter l’échéance (concours/examen/partiels) fixée par votre établissement (date et nombre de semaines restantes).\n\nPour personnaliser la couleur de votre badge, touchez simplement sur vos initiales puis touchez à nouveau sur la couleur de votre choix.",
        
        //6- Aide marquages
        "Retrouvez ici toutes les questions que vous avez marqué dans l'app. Appuyez sur i pour afficher la question et sa correction ou touchez pour envoyer une question à votre professeur. Sur une ligne, glissez vers la gauche pour enlever le marquage d'une question.",
        
        //7- Aide classement
        "Situez-vous dans votre établissement avec notre classement Prep'App grâce aux AwardPoints. Glissez vers le bas pour actualiser votre classement.\n\nLes classements des concours sont publiés dans la section \"Concours\" après que l'évènement soit terminé.",
        
        //8- Aide suggestions
        " Faîtes nous directement parvenir vos remarques ou suggestions concernant l'application. Vos retours nous sont précieux afin de proposer un service adapté à votre expérience d’utilisateur. Choisissez un sujet et tapez simplement votre message. Nous récupèrerons votre adresse email afin d’éventuellement  vous répondre  pour des informations complémentaires. Les remarques les plus pertinentes seront récompensées. ",
        
        
        //9- Aide réglages
        "Dans cette section vous pouvez changer votre mot de passe, activer la protection Touch ID si disponible et activer/désactiver les bruitages dans Prep'App. Si votre établissement le permet, vous pourrez modifier votre pseudonyme qui paraîtra dans le classement Prep'App et dans les listes d'amis pour le défi duo. Si vous ne voulez pas être anonyme, vous pourrez toujours mettre votre prénom et nom en tant que pseudonyme.",
        
        
        //10- Mentions légales
        "©Prep'App est une société par actions simplifiées au capital social de 10000€. Cette app a été développée en Swift à l'aide de ©Realm (base de donnée locale orientée objets), du framework ios-charts, de SWRevealViewController et de SwiftSpinner.\n\n\n\n Mentions légales de Realm : Realm Objective-C & Realm Swift are published under the Apache 2.0 license. The underlying core is available under the Realm Core Binary License while we work to open-source it under the Apache 2.0 license. This product is not being made available to any person located in Cuba, Iran, North Korea, Sudan, Syria or the Crimea region, or to any other person that is not eligible to receive the product under U.S. law.\n\n Mentions légales de ios-charts : Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda. Licensed under the Apache License, Version 2.0 (the \"License\"); you may not use this file except in compliance with the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an \"AS IS\" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.\n\n Mentions légales SWRevealViewController : Copyright (c) 2013 Joan Lluch joan.lluch@sweetwilliamsl.com Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.\n\nMentions légales SwiftSpinner : Copyright (c) 2015 Marin Todorov <touch-code-magazine@underplot.com> Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sellcopies of the Software, and to permit persons to whom the  Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE."]
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var roundCircle: UILabel!
    @IBOutlet weak var helpImage: UIImageView!
    @IBOutlet weak var helpText: UITextView!
    @IBOutlet weak var helpTitle: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBAction func changePage(sender: AnyObject) {
        self.selectedHelp = self.pageControl.currentPage
        Sound.playTrack("next")
        self.displayHelp()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if( traitCollection.forceTouchCapability == .Available){
            self.helpTexts[0] += "\n\nUtilisez 3D Touch sur votre iPhone 6S avec Peek & Pop ! Dans l'accueil et le fil d'actualités, appuyez d’une légère pression (Peek) pour afficher l’aperçu de vos statistiques ou d’une actualité. Relachez pour faire disparaître l'aperçu ou appuyez plus fermement (Pop) pour rentrer dans les statisques ou dans l'actualité sélectionnée."
            self.helpTexts[6] += "\n\nUtilisez 3D Touch sur votre iPhone 6S avec Peek & Pop ! Appuyez d’une légère pression (Peek) pour afficher l’aperçu de la question marquée. Relachez pour faire disparaître l'aperçu ou appuyez plus fermement (Pop) pour rentrer dans la question marquée et accèder à sa correction si disponible."
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "logout", name: "failed", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "update", name: "update", object: nil)
        self.navigationController!.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Segoe UI", size: 20)!]
        self.navigationController!.navigationBar.tintColor = Colors.greenLogo
        self.title = "Aide"
        if self.revealViewController() != nil {
            self.menuButton.target = self.revealViewController()
            self.menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        //sync
        FactoryHistory.getHistory().sync()
        self.view!.backgroundColor = Colors.greyBackground
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "update", name: "update", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "logout", name: "failed", object: nil)
        //handling swipe gestures
        let swipeRight = UISwipeGestureRecognizer(target: self, action: "swiped:")
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRight)
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: "swiped:")
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(swipeLeft)
        //load help
        self.displayHelp()
        //designing...
        self.navigationController!.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Segoe UI", size: 20)!]
        self.navigationController!.navigationBar.tintColor = Colors.greenLogo
        self.roundCircle.layer.cornerRadius = 50
        self.roundCircle.backgroundColor = UIColor.clearColor()
        self.roundCircle.layer.borderColor = Colors.greenLogo.CGColor
        self.roundCircle.layer.borderWidth = 3.0

    }
    
    override func viewDidAppear(animated: Bool) {
        self.helpText.setContentOffset(CGPointZero, animated: true)
        self.helpText.scrollRangeToVisible(NSRange(location: 0, length: 0))
    }
    
    func logout() {
        print("logging out")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func update() {
        // create alert controller
        let myAlert = UIAlertController(title: "Une mise à jour des questions est disponible", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        myAlert.view.tintColor = Colors.green
        // add "later" button
        myAlert.addAction(UIAlertAction(title: "Plus tard", style: UIAlertActionStyle.Cancel, handler: nil))
        // add "update" button
        myAlert.addAction(UIAlertAction(title: "Mettre à jour maintenant", style: UIAlertActionStyle.Destructive, handler: { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        // show the alert
        self.presentViewController(myAlert, animated: true, completion: nil)
    }
    
    func swiped(gesture : UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            switch swipeGesture.direction {
                
            case UISwipeGestureRecognizerDirection.Left:
                self.selectedHelp = (self.selectedHelp == 10) ? 0 : ++self.selectedHelp
                
            case UISwipeGestureRecognizerDirection.Right:
                self.selectedHelp = (self.selectedHelp == 0) ? 10 : --self.selectedHelp
                
            default:
                print("error")
                break
            }
            
        }
        Sound.playTrack("next")
        self.displayHelp()
    }
    
    func displayHelp() {
        self.pageControl.currentPage = self.selectedHelp
        self.pageControl.updateCurrentPageDisplay()
        self.helpImage.image = UIImage(named: self.helpPics[self.selectedHelp])
        self.helpTitle.text = self.helpTopics[self.selectedHelp].uppercaseString
        self.helpText.text = self.helpTexts[self.selectedHelp]
        self.helpText.textColor = UIColor.blackColor()
        self.helpText.font = UIFont(name: "Segoe UI", size: 16)
        self.helpText.setContentOffset(CGPointZero, animated: true)
        self.helpText.scrollRangeToVisible(NSRange(location: 0, length: 0))
        self.helpText.textAlignment = NSTextAlignment.Justified
        SwiftSpinner.hide()
    }


}
