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
    
    @IBOutlet weak var progression: UILabel!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var tryAgainButton: UIButton!
    @IBOutlet weak var blur: UIVisualEffectView!
    
    @IBAction func tryAgain(sender: AnyObject) {
        self.progression.hidden = false
        self.tryAgainButton.hidden = true
        self.logo.image = UIImage(named: "l0")
        Factory.errorNetwork = false
        self.sync()
    }

	override func viewDidLoad() {
        println(self.view.frame.width)
        SyncViewController.widthImage = self.view.frame.width - 20
		super.viewDidLoad()
        self.blur.alpha = 0
        self.tryAgainButton.layer.cornerRadius = 6
        self.tryAgainButton.hidden = true
        self.sync()
    
	}
    
    override func viewDidAppear(animated: Bool) {
        if User.authenticated == false {
            NSUserDefaults.standardUserDefaults().removeObjectForKey("user")
            NSUserDefaults.standardUserDefaults().synchronize()
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func sync(){
        Factory.sync()
        timer = NSTimer.scheduledTimerWithTimeInterval(0.030, target: self, selector: Selector("result"), userInfo: nil, repeats: true)
    }
	
	func result(){
        
        //computing percentage progression for Questions DB & Images (We neglect to take into account the chapters or materials, as they are very light.)
        if (Factory.getImageManager().sizeToDownload != 0 || Factory.getQuestionManager().sizeToDownload != 0 ) {
            self.blur.hidden = true
            self.nbrFrame = (Factory.getImageManager().sizeDownloaded + Factory.getQuestionManager().sizeDownloaded) * frames / (Factory.getImageManager().sizeToDownload + Factory.getQuestionManager().sizeToDownload)
            self.percentage = self.nbrFrame * 100 / self.frames
            //println("Downloading... \((Factory.getImageManager().sizeDownloaded + Factory.getQuestionManager().sizeDownloaded)/1000) KB/\((Factory.getImageManager().sizeToDownload + Factory.getQuestionManager().sizeToDownload)/1000) KB")
        } else {
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
            
            
        } else {
            
            var sentences = ["Prep'App est la clef de votre réussite ! ","Entraînez-vous contre la montre dans défi solo...","...ou affrontez d'autres étudiants dans défi duo !","Evaluez-vous grâce aux concours !" ]
            
            if  (Factory.getImageManager().hasFinishedSync == false || Factory.getQuestionManager().hasFinishedSync == false) {
                if self.nbrFrame != 0 {
                    var name = "l\(self.nbrFrame)"
                    self.logo.image = UIImage(named: name)
                    if self.nbrFrame < 200 {
                        self.progression.text = "Téléchargement du contenu en cours...\n \(self.percentage)%"
                    } else if (self.nbrFrame < 320) {
                        self.progression.text = "Veuillez patienter \n \(self.percentage)%"
                    } else {
                        self.progression.text = "Plus que quelques instants !\n \(self.percentage)%"
                    }
                }
                
            } else {
                //go to main menu
                timer.invalidate()
                self.performSegueWithIdentifier("syncDidFinish", sender: self)
            }
        }
		
		
	}
	
	
	
	
}

