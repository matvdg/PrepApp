//
//  SyncViewController.swift
//  PrepApp
//
//  Created by Mathieu Vandeginste on 02/05/15.
//  Copyright (c) 2015 PrepApp. All rights reserved.
//

import UIKit

class SyncViewController: UIViewController {
	
    static var widthImage: CGFloat = 300

	var timer = NSTimer()
    var waiter = NSTimer()
    var nbrFrame: Int = 0
    var percentage: Int = 0
	let frames = 350
    var blurAnimate = true
    //var sentences = ["Prep'App est la clef de votre réussite ! ","Entraînez-vous contre la montre dans défi solo...","...ou affrontez d'autres étudiants dans défi duo !","Evaluez-vous grâce aux concours !" ]
    
    @IBOutlet weak var progression: UILabel!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var tryAgainButton: UIButton!
    @IBOutlet weak var blur: UIVisualEffectView!
    
    @IBAction func tryAgain(sender: AnyObject) {
        self.progression.hidden = false
        self.tryAgainButton.hidden = true
        self.logo.image = UIImage(named: "l0")
        self.percentage = 0
        self.nbrFrame = 0
        Factory.errorNetwork = false
        self.sync()
    }

	override func viewDidLoad() {
        
        SyncViewController.widthImage = self.view.frame.width - 20
		super.viewDidLoad()
        self.blur.alpha = 0
        self.tryAgainButton.layer.cornerRadius = 6
        self.tryAgainButton.hidden = true
	}
    
    override func viewDidAppear(animated: Bool) {
        if User.authenticated == false {
            println("didAppear")
            self.progression.text = "Déconnexion..."
            NSUserDefaults.standardUserDefaults().removeObjectForKey("user")
            NSUserDefaults.standardUserDefaults().synchronize()
            self.dismissViewControllerAnimated(true, completion: nil)
        } else {
            self.sync()
        }
        
    }
    
    func sync(){
        if Factory.production {
            Factory.sync()
            timer = NSTimer.scheduledTimerWithTimeInterval(0.030, target: self, selector: Selector("result"), userInfo: nil, repeats: true)
        } else {
            self.performSegueWithIdentifier("syncDidFinish", sender: self)
        }
        
    }
	

    
	func result(){
        
        //handling network errors or bad network
        if Factory.errorNetwork {
            self.blur.hidden = true
            timer.invalidate()
            Sound.playTrack("error")
            // create alert controller
            let myAlert = UIAlertController(title: "Erreur de téléchargement", message: "Veuillez vérifier que vous êtes connecté à internet avec une bonne couverture cellulaire ou WiFi, puis réessayez.", preferredStyle: UIAlertControllerStyle.Alert)
            // add an "OK" button
            myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                self.progression.hidden = true
                self.tryAgainButton.hidden = false
                self.logo.image = UIImage(named: "l350")
                
            }))
            // show the alert
            self.presentViewController(myAlert, animated: true, completion: nil)
            
            
        } else { //progression of sync
            
            var name = ""
            //computing percentage progression for Questions DB & Images (We neglect to take into account the chapters or materials, as they are very light.)
            
            if (Factory.getImageManager().sizeToDownload != -1 && Factory.getQuestionManager().sizeToDownload != -1 ) {
                //println("both sizes computed (≠-1)")
                self.blur.hidden = true
                
                
                if Factory.getQuestionManager().questionsToSave != 0 {
                    self.percentage = ((Factory.getQuestionManager().questionsSaved) * 100) / (Factory.getQuestionManager().questionsToSave)
                    self.nbrFrame = (self.percentage * self.frames) / 200 + (self.frames / 2)
                    name = "l\(self.nbrFrame)"
                    self.logo.image = UIImage(named: name)
                    self.progression.text = "Traitement des questions en cours...\n \(self.percentage)%"
                    
                } else if Factory.getImageManager().sizeToDownload + Factory.getQuestionManager().sizeToDownload != 0 {
                    self.percentage = ((Factory.getImageManager().sizeDownloaded + Factory.getQuestionManager().sizeDownloaded) * 100) / (Factory.getImageManager().sizeToDownload + Factory.getQuestionManager().sizeToDownload)
                    self.nbrFrame = (self.percentage * self.frames) / 200
                    name = "l\(self.nbrFrame)"
                    self.logo.image = UIImage(named: name)
                    self.progression.text = "Téléchargement du contenu en cours...\n \(self.percentage)%"

                }
                //println("Downloading... \((Factory.getImageManager().sizeDownloaded + Factory.getQuestionManager().sizeDownloaded)/1000) KB/\((Factory.getImageManager().sizeToDownload + Factory.getQuestionManager().sizeToDownload)/1000) KB")
                
                
                //the end...
                if  (Factory.getImageManager().hasFinishedSync == true && Factory.getQuestionManager().hasFinishedSync == true) {
                    //go to main menu
                    timer.invalidate()
                    self.performSegueWithIdentifier("syncDidFinish", sender: self)
                    self.logo.image = UIImage(named: "l350")
                    self.progression.text = ""
                    //println("syncFinished")
                }
            
            
            } else { //waiting for server's answer
                self.blur.hidden = false
                //before getting sizes, waiting for server response
                self.progression.text = "Connexion au serveur Prep'App.\n Veuillez patienter..."
                self.logo.image = UIImage(named: "l350")
                if self.blurAnimate {
                    self.blur.alpha += 0.02
                    if self.blur.alpha >= 0.8 {
                        self.blurAnimate = false
                    }
                } else {
                    self.blur.alpha -= 0.02
                    if self.blur.alpha <= 0 {
                        self.blurAnimate = true
                    }
                }
            }
        }
	}
	
	
}

