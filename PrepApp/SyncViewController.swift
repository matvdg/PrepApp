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
    var version: Int = 0
    //var sentences = ["Prep'App est la clef de votre réussite ! ","Entraînez-vous contre la montre dans défi solo...","...ou affrontez d'autres étudiants dans défi duo !","Evaluez-vous grâce aux concours !" ]
    
    @IBOutlet weak var progression: UILabel!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var tryAgainButton: UIButton!
    
    @IBAction func tryAgain(sender: AnyObject) {
        self.progression.hidden = false
        self.tryAgainButton.hidden = true
        self.logo.image = UIImage(named: "l0")
        self.percentage = 0
        self.nbrFrame = 0
        FactorySync.errorNetwork = false
        self.sync()
    }

	override func viewDidLoad() {
        
        SyncViewController.widthImage = self.view.frame.width - 20
		super.viewDidLoad()
        self.tryAgainButton.layer.cornerRadius = 6
        self.tryAgainButton.hidden = true
	}
    
    override func viewDidAppear(animated: Bool) {
        FactorySync.getImageManager().hasFinishedSync = false
        FactorySync.getQuestionManager().hasFinishedSync = false
        FactorySync.getQuestionManager().hasFinishedComputeSize = false
        if User.authenticated == false {
            self.progression.text = "Déconnexion..."
            NSUserDefaults.standardUserDefaults().removeObjectForKey("user")
            NSUserDefaults.standardUserDefaults().synchronize()
            self.dismissViewControllerAnimated(true, completion: nil)
        } else {
            self.sync()
        }
        
    }
    
    func sync(){
        if FactorySync.production {
            FactorySync.offlineMode = false
            FactorySync.getConfigManager().getLastVersion { (version) -> Void in
                if let versionDB: Int = version { //online mode
                    FactorySync.getConfigManager().saveConfig({ (result) -> Void in
                        if result {
                            print("localVersion = \(FactorySync.getConfigManager().loadVersion()) dbVersion = \(versionDB), ")
                            if FactorySync.getConfigManager().loadVersion() != versionDB { //syncing...
                                FactorySync.sync()
                                println("syncing")
                                self.timer = NSTimer.scheduledTimerWithTimeInterval(0.030, target: self, selector: Selector("result"), userInfo: nil, repeats: true)
                                self.version = versionDB
                            } else { //no sync needed
                                println("no need to sync")
                                self.performSegueWithIdentifier("syncDidFinish", sender: self)
                            }
                        } else {
                            Sound.playTrack("error")
                            // create alert controller
                            let myAlert = UIAlertController(title: "Erreur de téléchargement", message: "Veuillez vérifier que vous êtes connecté à internet avec une bonne couverture cellulaire ou WiFi, puis réessayez.", preferredStyle: UIAlertControllerStyle.Alert)
                            myAlert.view.tintColor = colorGreenAppButtons
                            // add an "OK" button
                            myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                                self.progression.hidden = true
                                self.tryAgainButton.hidden = false
                                self.logo.image = UIImage(named: "l350")
                                
                            }))
                            // show the alert
                            self.presentViewController(myAlert, animated: true, completion: nil)
                        }
                    })
                    
                } else { //offline mode
                    if FactorySync.getConfigManager().loadVersion() == 0 { //if the app has never synced, can't run the app
                        Sound.playTrack("error")
                        // create alert controller
                        let myAlert = UIAlertController(title: "Erreur de téléchargement", message: "Veuillez vérifier que vous êtes connecté à internet avec une bonne couverture cellulaire ou WiFi, puis réessayez.", preferredStyle: UIAlertControllerStyle.Alert)
                        myAlert.view.tintColor = colorGreenAppButtons
                        // add an "OK" button
                        myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                            self.progression.hidden = true
                            self.tryAgainButton.hidden = false
                            self.logo.image = UIImage(named: "l350")
                            
                        }))
                        // show the alert
                        self.presentViewController(myAlert, animated: true, completion: nil)

                        
                    } else { //run the app in offline mode
                        FactorySync.offlineMode = true
                        println("offline mode")
                        self.performSegueWithIdentifier("syncDidFinish", sender: self)
                    }
                }
            }
        } else {
            self.performSegueWithIdentifier("syncDidFinish", sender: self)
        }
    }
    
	func result(){
      
        //handling network errors or bad network
        if FactorySync.errorNetwork {
            timer.invalidate()
            Sound.playTrack("error")
            // create alert controller
            let myAlert = UIAlertController(title: "Erreur de téléchargement", message: "Veuillez vérifier que vous êtes connecté à internet avec une bonne couverture cellulaire ou WiFi, puis réessayez.", preferredStyle: UIAlertControllerStyle.Alert)
            myAlert.view.tintColor = colorGreenAppButtons
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
            
            if (FactorySync.getImageManager().sizeToDownload != -1 && FactorySync.getQuestionManager().sizeToDownload != -1 ) {
                //println("both sizes computed (≠-1)")
                
                
                if FactorySync.getQuestionManager().questionsToSave != 0 {
                    self.percentage = ((FactorySync.getQuestionManager().questionsSaved) * 100) / (FactorySync.getQuestionManager().questionsToSave)
                    self.nbrFrame = (self.percentage * self.frames) / 200 + (self.frames / 2)
                    name = "l\(self.nbrFrame)"
                    self.logo.image = UIImage(named: name)
                    self.progression.text = "Traitement des questions en cours...\n \(self.percentage)%"
                    
                } else if FactorySync.getImageManager().sizeToDownload + FactorySync.getQuestionManager().sizeToDownload != 0 {
                    self.percentage = ((FactorySync.getImageManager().sizeDownloaded + FactorySync.getQuestionManager().sizeDownloaded) * 100) / (FactorySync.getImageManager().sizeToDownload + FactorySync.getQuestionManager().sizeToDownload)
                    self.nbrFrame = (self.percentage * self.frames) / 200
                    name = "l\(self.nbrFrame)"
                    self.logo.image = UIImage(named: name)
                    self.progression.text = "Téléchargement du contenu en cours...\n \(self.percentage)%"

                }
                //println("Downloading... \((FactorySync.getImageManager().sizeDownloaded + FactorySync.getQuestionManager().sizeDownloaded)/1000) KB/\((FactorySync.getImageManager().sizeToDownload + FactorySync.getQuestionManager().sizeToDownload)/1000) KB")
                
                
                //the end...
                if  (FactorySync.getImageManager().hasFinishedSync == true && FactorySync.getQuestionManager().hasFinishedSync == true) {
                    //go to main menu
                    timer.invalidate()
                    FactorySync.getConfigManager().saveVersion(self.version)
                    self.performSegueWithIdentifier("syncDidFinish", sender: self)
                    self.logo.image = UIImage(named: "l350")
                    self.progression.text = ""
                    //println("syncFinished")
                }
            
            
            } else { //waiting for server's answer
                //before getting sizes, waiting for server response
                self.progression.text = "Connexion au serveur Prep'App.\n Veuillez patienter..."
                self.logo.image = UIImage(named: "l350")
            }
        }
	}
	
	
}

